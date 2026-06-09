---
title: 安装 Drycc Workflow
linkTitle: 安装 Workflow
description: 本文档面向那些已经配置了 Kubernetes 集群并想要安装 Drycc Workflow 的人。
weight: 2
---

如果需要有关 Kubernetes 和 Drycc Workflow 入门的帮助，请遵循[快速入门指南](../quickstart/index.md)以获取帮助。

## 先决条件

1. 验证 [Kubernetes 系统要求](system-requirements.md)
1. 安装 [Helm 和 Drycc Workflow CLI](../quickstart/install-cli-tools.md) 工具

## 检查您的设置

检查 `helm` 命令是否可用且版本为 v2.5.0 或更新版本。

```
$ helm version
Client: &version.Version{SemVer:"v2.5.0", GitCommit:"012cb0ac1a1b2f888144ef5a67b8dab6c2d45be6", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.5.0", GitCommit:"012cb0ac1a1b2f888144ef5a67b8dab6c2d45be6", GitTreeState:"clean"}
```

## 选择您的部署策略

Drycc Workflow 包含运行所需的一切。然而，这些默认设置旨在简单而不是生产就绪。Workflow 的生产和暂存部署至少应该使用集群外存储，Workflow 组件使用它来存储和备份关键数据。如果操作员需要完全重新安装 Workflow，所需组件可以从集群外存储恢复。有关更多详细信息，请参阅[配置对象存储](configuring-object-storage.md)的文档。

更严格的安装将受益于对以下内容使用外部来源：
* [Postgres](configuring-postgres.md) - 例如 AWS RDS。
* [Registry](configuring-registry.md) - 这包括 [quay.io](https://quay.io)、[dockerhub](https://hub.docker.com)、[Amazon ECR](https://aws.amazon.com/ecr/) 和 [Google GCR](https://cloud.google.com/container-registry/)。
* [Valkey](../managing-workflow/platform-logging.md#configuring-off-cluster-valkey) - 如 AWS ElastiCache
* [Grafana](../managing-workflow/platform-monitoring.md#off-cluster-grafana)

#### 网关

现在，workflow 要求必须安装网关和 cert-manager。可以使用任何兼容的 Kubernetes 入口控制器。

## 安装 Drycc Workflow

如果 helm 版本为 3.0+；您需要提前创建命名空间：

```
kubectl create ns drycc
```

如果您想更改它，请在使用 helm 时设置变量。

```
$ helm install drycc oci://registry.drycc.cc/drycc/charts/workflow \
    --namespace drycc \
    --set builder.imageRegistry=quay.io \
    --set imagebuilder.imageRegistry=quay.io \
    --set controller.imageRegistry=quay.io \
    --set database.imageRegistry=quay.io \
    --set fluentbit.imageRegistry=quay.io \
    --set valkey.imageRegistry=quay.io \
    --set storage.imageRegistry=quay.io \
    --set grafana.imageRegistry=quay.io \
    --set registry.imageRegistry=quay.io \
    --set global.platformDomain=drycc.cc
```

Helm 将在 `drycc` 命名空间中安装各种 Kubernetes 资源。
等待 Helm 启动的 pod 准备就绪。通过运行以下命令监控其状态：

```
$ kubectl --namespace=drycc get pods
```

如果希望 `kubectl` 在 pod 状态更改时自动更新，请运行（键入 Ctrl-C 停止监视）：

```
$ kubectl --namespace=drycc get pods -w
```

根据 Workflow 组件初始化的顺序，一些 pod 可能会重新启动。这在安装期间很常见：如果组件的依赖项尚不可用，该组件将退出，Kubernetes 将自动重新启动它。

在这里，可以看到控制器、构建器和注册表都花了几次循环才能启动：

```
$ kubectl --namespace=drycc get pods
NAME                                     READY     STATUS    RESTARTS   AGE
drycc-builder-574483744-l15zj             1/1       Running   0          4m
drycc-controller-3953262871-pncgq         1/1       Running   2          4m
drycc-controller-celery-cmxxn             3/3       Running   0          4m
drycc-database-83844344-47ld6             1/1       Running   0          4m
drycc-fluentbit-zxnqb                     1/1       Running   0          4m
drycc-valkey-304849759-1f35p              1/1       Running   0          4m
drycc-storage-676004970-nxqgt             1/1       Running   0          4m
drycc-monitor-grafana-432627134-lnl2h     1/1       Running   0          4m
drycc-monitor-telegraf-wmcmn              1/1       Running   1          4m
drycc-registry-756475849-lwc6b            1/1       Running   1          4m
drycc-registry-proxy-96c4p                1/1       Running   0          4m
```

一旦所有 pod 都处于 `READY` 状态，Drycc Workflow 就启动并运行了！

有关更多安装参数，请检查 workflow 的 [values.yaml](https://github.com/drycc/workflow/blob/main/charts/workflow/values.yaml) 文件。

安装 Workflow 后，[注册用户并部署应用程序](../quickstart/deploy-an-app.md)。

[Kubernetes v1.16.15+]: system-requirements.md#kubernetes-versions

## 配置 DNS

用户必须设置主机名，并采用 `drycc-builder.$host` 约定。

我们需要将 `drycc-builder.$host` 记录指向您的构建器的公共 IP 地址。您可以使用以下命令获取公共 IP。这里需要通配符条目，因为应用程序在部署后将使用相同的规则。

```
$ kubectl get svc drycc-builder --namespace drycc
NAME              CLUSTER-IP   EXTERNAL-IP      PORT(S)                      AGE
drycc-builder     10.0.25.3    138.91.243.152   2222:31625/TCP               33m
```


如果我们使用 `drycc.cc` 作为主机名，我们需要创建以下 A DNS 记录。

| 名称                         | 类型          | 值            |
| ---------------------------- |:-------------:| --------------:|
| drycc-builder.drycc.cc       | A             | 138.91.243.152 |

一旦所有 pod 都处于 `READY` 状态，并且 `drycc-builder.$host` 解析为上面找到的外部 IP，Workflow 就启动并运行了！

安装 Workflow 后，[注册用户并部署应用程序](../quickstart/deploy-an-app.md)。

如果您的 k8s 不提供公共网络负载均衡器，您需要在可以访问内部和外部网络的机器上安装 haproxy 等 TCP 代理服务，然后公开 `80` 和 `443`。
