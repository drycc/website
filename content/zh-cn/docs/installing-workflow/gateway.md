---
title: 指定网关
linkTitle: 安装网关
description: 选择最适合您需求和平台的网关提供商。
weight: 2
---

## 安装 Drycc Workflow（指定网关）

现在 Helm 已安装并添加了仓库，通过运行以下命令使用原生网关安装 Workflow：

```
$ helm install drycc oci://registry.drycc.cc/drycc/charts/workflow \
    --namespace drycc \
    --set gateway.gatewayClass=istio \
    --set controller.appGatewayClass=istio \
    --set global.platformDomain=drycc.cc \
    --set builder.service.type=LoadBalancer
```

当然，如果您在裸机上部署，您可能没有负载均衡器。您需要使用 NodePort：
```
$ helm install drycc oci://registry.drycc.cc/drycc/charts/workflow \
    --namespace drycc \
    --set gateway.gatewayClass=istio \
    --set controller.appGatewayClass=istio \
    --set global.platformDomain=drycc.cc \
    --set builder.service.type=NodePort \
    --set builder.service.nodePort=32222
```

如果您想在裸机上使用负载均衡器，您可以查看 [metallb](https://github.com/metallb/metallb)

其中 `global.platformDomain` 是一个**必需**参数，对于 Workflow 传统上不是必需的，这在下一节中会解释。在此示例中，我们使用 `drycc.cc` 作为 `$hostname`。

Helm 将在 `drycc` 命名空间中安装各种 Kubernetes 资源。
等待 Helm 启动的 pod 准备就绪。通过运行以下命令监控其状态：

```
$ kubectl --namespace=drycc get pods
```

您还应该注意到您的集群上已安装了几个 Kubernetes gatewayclass。您可以通过运行以下命令查看它：

```
$ kubectl get gatewayclass
```

根据 Workflow 组件初始化的顺序，一些 pod 可能会重新启动。这在安装期间很常见：如果组件的依赖项尚不可用，该组件将退出，Kubernetes 将自动重新启动它。

在这里，可以看到控制器、构建器和注册表都花了几次循环等待存储才能启动：

```
$ kubectl --namespace=drycc get pods
NAME                          READY     STATUS    RESTARTS   AGE
drycc-builder-hy3xv            1/1       Running   5          5m
drycc-controller-g3cu8         1/1       Running   5          5m
drycc-controller-celery-cmxxn  3/3       Running   0          5m
drycc-database-rad1o           1/1       Running   0          5m
drycc-fluentbit-1v8uk          1/1       Running   0          5m
drycc-fluentbit-esm60          1/1       Running   0          5m
drycc-storage-4ww3t            1/1       Running   0          5m
drycc-registry-asozo           1/1       Running   1          5m
```

## 安装 Kubernetes 网关

现在 Workflow 已使用 `gatewayClass` 部署，我们需要安装 Kubernetes 网关来开始路由流量。

以下是如何使用 [istio](https://istio.io/) 作为 Workflow 网关的示例。当然，您可以随意使用任何您希望的控制器。

```
$ helm repo add istio https://istio-release.storage.googleapis.com/charts
$ helm repo update
$ kubectl create namespace istio-system
$ helm install istio-base istio/base -n istio-system
$ helm install istiod istio/istiod -n istio-system --wait
$ kubectl create namespace istio-ingress
$ helm install istio-ingress istio/gateway -n istio-ingress --wait
```

## 配置 DNS

用户必须安装 [drycc](../quickstart/install-workflow.md) 然后设置主机名，并采用 `*.$host` 约定。

我们需要将 `*.$host` 记录指向您的网关的公共 IP 地址。您可以使用以下命令获取公共 IP。这里需要通配符条目，因为应用程序在部署后将使用相同的规则。

```
$ kubectl get gateway --namespace drycc
NAME      CLASS   ADDRESS         PROGRAMMED   AGE
gateway   istio   138.91.243.152  True         36d
```

如果我们使用 `drycc.cc` 作为主机名，我们需要创建以下 A DNS 记录。

| 名称                         | 类型          | 值            |
| ---------------------------- |:-------------:| --------------:|
| *.drycc.cc                   | A             | 138.91.243.152 |

一旦所有 pod 都处于 `READY` 状态，并且 `*.$host` 解析为上面找到的外部 IP，网关的准备就完成了！

安装 Workflow 后，[注册用户并部署应用程序](../quickstart/deploy-an-app.md)。

如果您的 k8s 不提供公共网络负载均衡器，您需要在可以访问内部和外部网络的机器上安装 haproxy 等 TCP 代理服务，然后公开 `80` 和 `443`。