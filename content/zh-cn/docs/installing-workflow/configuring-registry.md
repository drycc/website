---
title: 配置注册表
linkTitle: 配置注册表
description: Drycc Workflow 的构建器组件依赖注册表来存储应用程序容器镜像。
weight: 5
---

Drycc Workflow 默认附带 [registry][registry] 组件，它提供集群内容器注册表，由平台配置的 [object storage][storage] 支持。操作员可能出于性能或安全原因想要使用集群外注册表。

## 配置集群外私有注册表

每个依赖注册表的组件使用两个输入进行配置：

1. 名为 `DRYCC_REGISTRY_LOCATION` 的注册表位置环境变量
2. 访问凭据存储为名为 `registry-secret` 的 Kubernetes secret

Drycc Workflow 的 Helm chart 可以轻松配置以将 Workflow 组件连接到集群外注册表。Drycc Workflow 支持外部注册表，这些注册表提供仅在指定时间内有效的短期令牌或永久有效的长期令牌（基本用户名/密码）来进行身份验证。对于那些提供短期令牌进行身份验证的注册表，Drycc Workflow 将生成并刷新它们，以便部署的应用程序只能访问短期令牌，而不是注册表的实际凭据。

使用私有注册表时，容器镜像不再由 Drycc Workflow Controller 拉取，而是由 [Kubernetes][] 管理。这将提高安全性和整体速度，但是 `port` 信息不再能够被发现。相反，可以通过在部署应用程序之前使用 `drycc config set PORT=<port>` 设置 `port` 信息。

Drycc Workflow 目前支持：

  1. 集群外：任何支持长期用户名/密码身份验证的提供商，如 [Azure Container Registry][acr]、[Docker Hub][dockerhub]、[quay.io][quay] 或自托管容器注册表。

## 配置

  1. 如果您尚未获取 values 文件，请使用 `helm inspect values drycc/workflow > values.yaml` 获取
  1. 通过修改 values 文件更新注册表位置详细信息：
    * 将 `registry.enabled` 参数更新为引用您使用的注册表位置：`true`、`false`
    * 更新与您的注册表位置类型对应的部分中的值。

现在您可以使用所需的注册表运行 `helm install drycc oci://registry.drycc.cc/drycc/charts/workflow --namespace drycc -f values.yaml`。

## 示例
在这里，我们展示了获取的 `values.yaml` 文件的相关部分在为特定集群外注册表配置后可能的样子：

### [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry/) (ACR)

按照 [docs](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli) 创建注册表后，例如 `myregistry`，其对应的登录服务器为 `myregistry.azurecr.io`，应提供以下值：

```
builder:
  registryHost: "myregistry.azurecr.io"
  registryUsername: "xxxx"
  registryPassword: "xxxx"
  registryOrganization: "xxxx"
registry:
  enabled: false
```

**注意：** 强制性组织字段（此处为 `myorg`）将在 ACR 仓库中创建，如果它尚不存在。

### Quay.io

```
builder:
  registryHost: "quay.io"
  registryUsername: "xxxx"
  registryPassword: "xxxx"
  registryOrganization: "xxxx"
registry:
  enabled: false
```

[registry]: ../understanding-workflow/components.md#registry
[storage]: configuring-object-storage
[acr]: https://docs.microsoft.com/en-us/azure/container-registry/
[dockerhub]: https://hub.docker.com/
[quay]: https://quay.io/
[srvAccount]: https://support.google.com/cloud/answer/6158849#serviceaccounts
[Kubernetes]: https://kubernetes.io
