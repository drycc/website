---
title: 升级 Workflow
linkTitle: 升级 Workflow
description: Drycc Workflow 版本可以就地升级，最小化停机时间。
weight: 6
---

此升级过程需要：

* Helm 版本 [2.1.0 或更新](https://github.com/kubernetes/helm/releases/tag/v2.1.0)
* 配置的集群外存储

## 升级过程

{{% alert title="Note" color="info" %}}
如果从 [Helm Classic](https://github.com/helm/helm-classic) 安装升级，您需要将集群迁移到 [Kubernetes Helm](https://github.com/kubernetes/helm) 安装。请参阅 [Workflow-Migration][] 获取步骤。
{{% /alert %}}

### 步骤 1：应用 Workflow 升级

Helm 将从之前的版本中移除所有组件。通过 Workflow 部署的应用程序流量将在升级期间继续流动。不应发生服务中断。

如果 Workflow 未配置为使用集群外 Postgres，Workflow API 将在数据库从备份恢复时经历短暂的停机时间。

首先，使用 `helm ls` 查找 helm 给您的部署的版本名称，然后运行

```
$ helm upgrade <release-name> oci://registry.drycc.cc/drycc/charts/workflow
```

**注意：** 如果使用 [gcs](https://cloud.google.com/storage/) 上的集群外对象存储和/或使用 [gcr](https://cloud.google.com/container-registry/) 的集群外注册表，并打算从 pre-`v2.10.0` 图表升级到 `v2.10.0` 或更高版本，现在需要预先 base64 编码 `key_json` 值。因此，假设其余的自定义/集群外值在用于之前安装的现有 `values.yaml` 中定义，可以运行以下命令：

```
$ B64_KEY_JSON="$(cat ~/path/to/key.json | base64 -w 0)"
$ helm upgrade <release_name> drycc/workflow -f values.yaml --set gcs.key_json="${B64_KEY_JSON}",registry-token-refresher.gcr.key_json="${B64_KEY_JSON}"
```

或者，只需在 values.yaml 中替换适当的值，而不使用 `--set` 参数。确保用单引号包装，因为双引号会在升级时给出解析器错误。

### 步骤 2：验证升级

验证所有组件已启动并通过了就绪检查：

```
$ kubectl --namespace=drycc get pods
NAME                                     READY     STATUS    RESTARTS   AGE
drycc-builder-2448122224-3cibz            1/1       Running   0          5m
drycc-controller-1410285775-ipc34         1/1       Running   3          5m
drycc-controller-celery-694f75749b-cmxxn  3/3       Running   0          5m
drycc-database-e7c5z                      1/1       Running   0          5m
drycc-fluentbit-45h7j                     1/1       Running   0          5m
drycc-fluentbit-4z7lw                     1/1       Running   0          5m
drycc-fluentbit-k2wsw                     1/1       Running   0          5m
drycc-fluentbit-skdw4                     1/1       Running   0          5m
drycc-valkey-8nazu                        1/1       Running   0          5m
drycc-grafana-tm266                       1/1       Running   0          5m
drycc-registry-1814324048-yomz5           1/1       Running   0          5m
drycc-registry-proxy-4m3o4                1/1       Running   0          5m
drycc-registry-proxy-no3r1                1/1       Running   0          5m
drycc-registry-proxy-ou8is                1/1       Running   0          5m
drycc-registry-proxy-zyajl                1/1       Running   0          5m
```

### 步骤 3：升级 Drycc 客户端

Drycc Workflow 的用户现在应该升级他们的 drycc 客户端，以避免收到 `WARNING: Client and server API versions do not match. Please consider upgrading.` 警告。

```
curl -sfL https://www.drycc.cc/install-cli.sh | bash - && sudo mv drycc $(which drycc)
```

[Configuring Object Storage]: ../installing-workflow/configuring-object-storage.md
[Workflow-Migration]: https://github.com/drycc/workflow-migration/blob/main/README.md
