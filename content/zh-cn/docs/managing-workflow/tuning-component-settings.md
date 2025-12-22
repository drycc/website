---
title: 调整组件设置
linkTitle: 调整组件设置
description: Helm Charts 是一组 Kubernetes 清单，反映了在 Kubernetes 上部署应用程序或服务的最佳实践。
weight: 1
---

在添加 Drycc Chart Repository 后，您可以在使用 `helm install` 完成安装之前，使用 `helm inspect values drycc/workflow > values.yaml` 来自定义图表。

有几种方法可以自定义相应组件：

 - 如果值在上面派生的 `values.yaml` 文件中暴露，可以修改组件的部分来调整这些设置。修改的值将在图表安装或发布升级时通过以下两个相应命令之一生效：

        $ helm install drycc oci://registry.drycc.cc/charts/workflow \
            -n drycc \
            --namespace drycc \
            -f values.yaml
        $ helm upgrade drycc oci://registry.drycc.cc/charts/workflow \
            -n drycc \
            --namespace drycc \
            -f values.yaml

 - 如果值尚未在 `values.yaml` 文件中暴露，可以编辑组件部署以调整设置。这里我们编辑 `drycc-controller` 部署：

        $ kubectl --namespace drycc edit deployment drycc-controller

    在 `env` 部分下通过适当的环境变量和值添加/编辑设置并保存。更新后的部署将使用新的/修改的设置重新创建组件 pod。

 - 最后，可以获取并编辑版本控制/图表仓库本身提供的图表：

        $ helm fetch oci://registry.drycc.cc/charts/workflow --untar
        $ $EDITOR workflow/charts/controller/templates/controller-deployment.yaml

    然后运行 `helm install ./workflow --namespace drycc --name drycc` 来应用更改，或者如果集群已经在运行，则运行 `helm upgrade drycc ./workflow`。

## 设置资源限制

您可以通过修改之前获取的 values.yaml 文件来为 Workflow 组件设置资源限制。此文件为每个 Workflow 组件都有一个部分。要为任何 Workflow 组件设置限制，只需在部分中添加 `resources` 并将其设置为适当的值。

以下是设置了 CPU 和内存限制的 `values.yaml` 中 builder 部分的样子示例：

```
builder:
  imageOrg: "drycc"
  imagePullPolicy: "Always"
  imageTag: "canary"
  resources:
    limits:
      cpu: 1000m
      memory: 2048Mi
    requests:
      cpu: 500m
      memory: 1024Mi
```

## 自定义 Builder

[Builder][] 组件可以调整以下环境变量：

设置 | 描述
--------------------------- | ---------------------------------
DEBUG                       | 启用调试日志输出（默认：false）
BUILDER_POD_NODE_SELECTOR   | builder 作业的节点选择器设置。由于它有时会消耗大量节点资源，您可能希望给定的 builder 作业仅在特定节点上运行，这样就不会影响关键节点。例如 `pool:testing,disk:magnetic`

## 自定义 Controller

[Controller][] 组件可以调整以下环境变量：

设置 | 描述
----------------------------------------------- | ---------------------------------
REGISTRATION_MODE                               | 将注册设置为 "enabled"、"disabled" 或 "admin_only"（默认："admin_only"）
GUNICORN_WORKERS                                | 生成的 [gunicorn][] 工作进程数量，用于处理请求（默认：CPU 核心数 * 4 + 1）
RESERVED_NAMES                                  | 应用程序无法为路由保留的名称的逗号分隔列表（默认："drycc, drycc-builder"）
DRYCC_DEPLOY_HOOK_URLS                          | 发送 [deploy hooks][] 的 URL 逗号分隔列表。
DRYCC_DEPLOY_HOOK_SECRET_KEY                    | 用于计算部署钩子 HMAC 签名的私钥。
DRYCC_DEPLOY_REJECT_IF_PROCFILE_MISSING         | 如果之前的构建有 Procfile 但当前部署缺少它，则拒绝部署。API 中抛出 409。防止意外删除进程类型。（默认："false"，允许值："true"、"false"）
DRYCC_DEPLOY_PROCFILE_MISSING_REMOVE            | 开启时（默认），与之前部署相比，Procfile 中缺少的任何进程类型都会被移除。设置为 false 时，将允许空的 Procfile 通过而不移除缺少的进程类型，请注意，新镜像、配置等将在所有进程类型上更新。（默认："true"，允许值："true"、"false"）
DRYCC_DEFAULT_CONFIG_TAGS                       | 默认情况下为所有应用程序设置标签，例如：'{"role": "worker"}'。（默认：''）
KUBERNETES_NAMESPACE_DEFAULT_QUOTA_SPEC         | 通过设置 [ResourceQuota](http://kubernetes.io/docs/admin/resourcequota/) 规范为应用程序命名空间设置资源配额，例如：`{"spec":{"hard":{"pods":"10"}}}`, 限制应用所有者生成超过 10 个 pod（默认："", 不会对命名空间应用配额）

### LDAP 认证设置

LDAP 认证的配置选项详细说明[此处](https://pythonhosted.org/django-auth-ldap/reference.html)。

[Passport][] 组件中启用用户账户 LDAP 认证的可用环境变量如下：

设置 | 描述
-------------------| ---------------------------------
LDAP_ENDPOINT      | LDAP 服务器的 URI。如果未指定，则不启用 LDAP 认证（默认："", 示例：```ldap://hostname```）。
LDAP_BIND_DN       | 绑定到 LDAP 服务器时使用的可分辨名称（默认：""）
LDAP_BIND_PASSWORD | 与 LDAP_BIND_DN 一起使用的密码（默认：""）
LDAP_USER_BASEDN   | 用户名的搜索基础的可分辨名称（默认：""）
LDAP_USER_FILTER   | 用户搜索基础中的登录字段名称（默认："username"）
LDAP_GROUP_BASEDN  | 用户组名的搜索基础的可分辨名称（默认：""）
LDAP_GROUP_FILTER  | 用户组的过滤器（默认："", 示例：```objectClass=person```）

### 全局和每个应用程序设置

设置 | 描述
----------------------------------------------- | ---------------------------------
DRYCC_DEPLOY_BATCHES                             | 缩放期间顺序启动和停止的 pod 数量（默认：可用节点数量）
DRYCC_DEPLOY_TIMEOUT                             | 每个部署批次的部署超时时间（秒）（默认：120）
IMAGE_PULL_POLICY                               | 应用程序镜像的 kubernetes [镜像拉取策略][pull-policy]（默认："IfNotPresent"）（允许值："Always"、"IfNotPresent"）
KUBERNETES_DEPLOYMENTS_REVISION_HISTORY_LIMIT   | Kubernetes 为给定 Deployment 保留的[修订][kubernetes-deployment-revision]数量（默认：所有修订）
KUBERNETES_POD_TERMINATION_GRACE_PERIOD_SECONDS | 发送 SIGKILL 之前，kubernetes 在 SIGTERM 后等待 pod 完成工作的秒数（默认：30）

有关这些的更多详细信息，请参阅[部署应用][]指南。


## 自定义 Fluentbit

以下值可以在 `values.yaml` 文件中更改，或使用 Helm CLI 的 `--values` 标志。

键 | 描述
------------------| ---------------------------------
config.service    | 服务部分定义服务的全局属性。
config.inputs     | 输入部分定义源（与输入插件相关）。
config.filters    | 过滤器部分定义过滤器（与过滤器插件相关）
config.outputs    | 输出部分指定某些记录在标签匹配后应遵循的目的地。

有关可以设置的各种变量的更多信息，请参阅 [fluentbit](https://github.com/drycc/fluentbit)。

## 自定义监控

### [Grafana](https://grafana.com/)
我们直接在图表中暴露了一些更有用的配置值。这允许使用 `values.yaml` 文件或 Helm CLI 的 `--set` 标志来设置它们。您可以在下面看到这些选项：

设置 | 默认值 | 描述
----------------- | -------------- |------------ |
user   | "admin" | 数据库中创建的第一个用户（此用户具有管理员权限）
password | "admin" | 第一个用户的密码。
allow_sign_up | "true" | 允许用户注册账户。

有关可以使用环境变量设置的其他选项列表，请参阅 Github 中的[配置文件](https://github.com/drycc/monitor/blob/main/grafana/rootfs/usr/share/grafana/grafana.ini.tpl)。

### [Victoriametrics](https://victoriametrics.com/)
您可以在[此处](https://github.com/drycc/victoriametrics)找到可以使用环境变量设置的值列表。

## 自定义注册表

[Registry][] 组件可以通过遵循 [distribution config doc](https://distribution.github.io/distribution/about/configuration/) 来调整。

[Deploying Apps]: ../applications/deploying-apps.md
[builder]: ../understanding-workflow/components.md#builder
[controller]: ../understanding-workflow/components.md#controller
[passport]: ../understanding-workflow/components.md#passport
[database]: ../understanding-workflow/components.md#database
[deploy hooks]: deploy-hooks.md#http-post-hook
[Deployments]: http://kubernetes.io/docs/user-guide/deployments/
[downward-api]: http://kubernetes.io/docs/user-guide/downward-api/
[gunicorn]: http://gunicorn.org/
[kubernetes-deployment-revision]: http://kubernetes.io/docs/user-guide/deployments/#revision-history-limit
[monitor]: ../understanding-workflow/components.md#monitor
[pull-policy]: http://kubernetes.io/docs/user-guide/images/
[registry]: ../understanding-workflow/components.md#registry
[ReplicationControllers]: http://kubernetes.io/docs/user-guide/replication-controller/
