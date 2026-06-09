---
title: 配置 Postgres
linkTitle: 配置 Postgres
description: Drycc Workflow 的控制器和护照组件依赖 PostgreSQL 数据库来存储平台状态。
weight: 5
---

# 配置 Postgres

默认情况下，Drycc Workflow 附带 [database] 组件，它提供集群内 PostgreSQL 数据库，并备份到集群内或集群外 [object storage]。目前，对于对象存储（由_多个_ Workflow 组件使用），在生产环境中仅推荐集群外解决方案，如 S3 或 GCS。经验表明，许多操作员已经选择集群外对象存储，同样更喜欢在集群外托管 Postgres，使用 Amazon RDS 或类似服务。当同时行使这两个选项时，Workflow 安装变得完全无状态，因此在需要时可以更容易地恢复或重建。

## 提供集群外 Postgres

首先，使用您选择的云提供商或其他基础设施提供 PostgreSQL RDBMS。请注意确保安全组或其他防火墙规则将允许从您的 Kubernetes 工作节点连接，任何节点都可能托管 Workflow 控制器组件。

记下以下内容：

1. 您的 PostgreSQL RDBMS 的主机名或公共 IP
2. 您的 PostgreSQL RDBMS 运行的端口 - 通常为 5432

在集群外 RDBMS 中，手动提供以下内容：

1. 数据库用户（记下用户名和密码）
2. 该用户拥有的数据库（记下其名称）

如果您能够以超级用户或具有适当权限的用户身份登录 RDBMS，此过程通常如下所示：

```
$ psql -h <host> -p <port> -d postgres -U <"postgres" 或您自己的用户名>
> create user <drycc 用户名；通常为 "drycc"> with password '<password>';
> create database <数据库名称；通常为 "drycc"> with owner <drycc 用户名>;
> \q
```

## 配置 Workflow

Drycc Workflow 的 Helm chart 可以轻松配置以将 Workflow 控制器组件连接到集群外 PostgreSQL 数据库。

* **步骤 1：** 如果您尚未获取 values，请使用 `helm inspect values drycc/workflow > values.yaml` 获取
* **步骤 2：** 通过修改 `values.yaml` 更新数据库连接详细信息：
    * 将 `database.enabled` 参数更新为 `false`。
    * 更新 `[database]` 配置部分中的值以正确反映所有连接详细信息。
    * 更新 `[controller]` 配置部分中的值以正确反映 platformDomain 详细信息。
    * 保存您的更改。
    * 注意：您不需要（也不必须）对任何值进行 base64 编码，因为 Helm chart 将根据需要自动处理编码。

现在您可以使用 `helm install drycc oci://registry.drycc.cc/drycc/charts/workflow --namespace drycc -f values.yaml` [照常][installing]安装。

[database]: ../understanding-workflow/components.md#database
[object storage]: configuring-object-storage.md
[installing]: ../installing-workflow/index.md
