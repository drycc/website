---
title: 部署应用程序
linkTitle: 部署应用
description: 了解如何将应用程序部署到 Drycc。
weight: 1
---

[应用程序][] 使用 `git push` 或 `drycc` 客户端部署到 Drycc。

## 支持的应用程序

Drycc Workflow 可以部署任何可以在容器中运行的应用程序或服务。为了能够水平扩展，应用程序必须遵循 [Twelve-Factor App][] 方法，并将任何应用程序状态存储在外部后端服务中。

例如，如果您的应用程序将状态持久化到本地文件系统（这在内容管理系统如 WordPress 和 Drupal 中很常见），则无法使用 `drycc scale` 进行水平扩展。

幸运的是，大多数现代应用程序具有无状态的应用程序层，可以在 Drycc 中水平扩展。

## 登录到控制器

{{% alert title="Note" color="danger" %}}
如果您还没有，现在是安装客户端并注册的好时机。
{{% /alert %}}

在部署应用程序之前，用户必须首先使用 Drycc 管理员提供的 URL 对 Drycc [控制器][] 进行身份验证。

```
$ drycc login http://drycc.example.com
Opening browser to http://drycc.example.com/v2/login/drycc/?key=4ccc81ee2dce4349ad5261ceffe72c71
Waiting for login... .o.Logged in as admin
Configuration file written to /root/.drycc/client.json
```

或者您可以使用用户名和密码登录
```
$ drycc login http://drycc.example.com --username=demo --password=demo
Configuration file written to /root/.drycc/client.json
```

## 选择构建过程

Drycc Workflow 支持三种不同的应用程序构建方式：

### Buildpacks

Cloud Native Buildpacks 如果您想遵循 [cnb's docs](https://buildpacks.io/docs/) 来构建应用程序会很有用。

了解如何使用 Buildpacks 部署应用程序。

### Dockerfiles

Dockerfiles 是一种强大的方式，可以定义基于您选择的基础操作系统的可移植执行环境。

了解如何使用 Dockerfiles 部署应用程序。

### 容器镜像

将容器镜像部署到 Drycc 允许您从公共或私有注册表获取容器镜像，并逐位复制，确保您在开发环境或 CI 流水线中运行的镜像与生产环境中的镜像相同。

了解如何使用容器镜像部署应用程序。

## 调整应用程序设置

可以使用 `config:set` 在每个应用程序基础上配置一些[全局可调设置](../applications/managing-app-configuration.md)。

设置                                         | 描述
----------------------------------------------- | ---------------------------------
DRYCC_DISABLE_CACHE                             | 如果设置，将禁用 [imagebuilder 缓存][]（默认：未设置）
DRYCC_DEPLOY_BATCHES                            | 在扩展期间顺序启动和停止的 pod 数量（默认：可用节点数量）
DRYCC_DEPLOY_TIMEOUT                            | 每个部署批次的部署超时时间（秒）（默认：120）
IMAGE_PULL_POLICY                               | 应用程序镜像的 Kubernetes [镜像拉取策略][pull-policy]（默认："IfNotPresent"）（允许值："Always"、"IfNotPresent"）
KUBERNETES_DEPLOYMENTS_REVISION_HISTORY_LIMIT   | Kubernetes 为给定 Deployment 保留的[修订][kubernetes-deployment-revision]数量（默认：所有修订）
KUBERNETES_POD_TERMINATION_GRACE_PERIOD_SECONDS | Kubernetes 在发送 SIGKILL 之前等待 pod 完成工作的秒数（默认：30）

### 部署超时

部署超时（秒）- 有两种部署方法，Deployments（见下文）和 RC（2.4 版本之前），此设置对它们的影响略有不同。

#### Deployments

Deployments 的行为与基于 RC 的部署策略略有不同。

Kubernetes 负责整个部署，在后台进行滚动更新。因此，只有一个整体部署超时，而不是可配置的每批次超时。

基础超时乘以 `DRYCC_DEPLOY_BATCHES` 来创建整体超时。这将是 240（超时）* 4（批次）= 960 秒整体超时。

#### RC 部署

此部署超时定义在 `DRYCC_DEPLOY_BATCHES` 中等待每个批次完成的时长。

#### 基础超时的附加项

基础超时也会通过健康检查使用 `liveness` 和 `readiness` 上的 `initial_delay_seconds` 进行扩展，其中应用较大的那个。
此外，超时系统通过在看到镜像拉取超过 1 分钟时添加额外 10 分钟来考虑慢速镜像拉取。这允许超时值合理，而不必在基础部署超时中考虑镜像拉取的缓慢。

### Deployments

Workflow 使用 [Deployments][] 进行部署。在之前的版本中，使用 [ReplicationControllers][]，可以通过 `DRYCC_KUBERNETES_DEPLOYMENTS=1` 启用 Deployments。

[Deployments][] 的优势是滚动更新将在 Kubernetes 服务器端发生，而不是在 Drycc Workflow Controller 中进行，以及其他一些 Pod 管理相关功能。这允许即使 CLI 连接中断，部署也能继续。

在后台，您的应用程序部署将由每个进程类型的 Deployment 对象组成，每个对象有多个 ReplicaSets（每个发布一个），这些 ReplicaSets 反过来管理运行您的应用程序的 Pods。

Drycc Workflow 的行为在启用或禁用 `DRYCC_KUBERNETES_DEPLOYMENTS` 时相同（仅适用于 2.4 版本之前）。
变化发生在后台。您在使用 CLI 时会看到差异的地方是 `drycc ps:list` 将以不同的方式输出 Pod 名称。

[slugbuilder cache]: ./managing-app-configuration.md#slugbuilder-cache
[install client]: ../users/cli.md#installation
[application]: ../reference-guide/terms.md#application
[controller]: ../understanding-workflow/components.md#controller
[Twelve-Factor App]: http://12factor.net/
[Deployments]: http://kubernetes.io/docs/user-guide/deployments/
[kubernetes-deployment-revision]: http://kubernetes.io/docs/user-guide/deployments/#revision-history-limit
[ReplicationControllers]: http://kubernetes.io/docs/user-guide/replication-controller/
