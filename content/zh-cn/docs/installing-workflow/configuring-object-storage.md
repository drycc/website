---
title: 配置对象存储
linkTitle: 配置对象存储
description: 各种 Drycc Workflow 组件依赖对象存储系统来完成工作，包括存储应用程序、容器镜像
---

Drycc Workflow 默认附带 [Storage][storage]，它提供集群内存储。

## 配置集群外对象存储

每个依赖对象存储的组件使用两个输入进行配置：

1. 您必须使用与 S3 API 兼容的对象存储服务。
2. 访问凭据存储在Kubernetes secret之中以保证安全。

Drycc Workflow 的 helm chart 可以轻松配置以将 Workflow 组件连接到集群外对象存储。Drycc Workflow 目前支持 Google Compute Storage、Amazon S3、[Azure Blob Storage][] 和 OpenStack Swift Storage。

### 步骤 1：创建存储桶

为每个 Workflow 子系统创建存储桶：`builder`和`registry`。

根据您选择的对象存储，您可能需要提供全局唯一的桶名称。如果您使用 S3，请在桶名称中使用连字符而不是句点。在桶名称中使用句点会导致 [S3 的 ssl 证书验证问题](https://forums.aws.amazon.com/thread.jspa?threadID=105357)。

如果您提供对底层存储有足够访问权限的凭据，Workflow 组件将在桶不存在时创建它们。

### 步骤 2：生成存储凭据

如果适用，生成对步骤 1 中创建的存储桶具有创建和写入访问权限的凭据。

如果您使用 AWS S3 并且您的 Kubernetes 节点通过 InstanceRoles 配置了适当的 [IAM][aws-iam] API 密钥，您不需要创建 API 凭据。但是，请验证 InstanceRole 对配置的桶具有适当的权限！

### 步骤 3：配置 Workflow Chart

操作员应该在运行 `helm install` 之前通过编辑 Helm values 文件来配置对象存储。为此：

* 通过运行 `helm inspect values oci://registry.drycc.cc/drycc/charts/workflow > values.yaml` 获取 Helm values
* 更新 `builder/storage` 和 `registry/storage` 参数以引用您使用的平台。
* 找到您的存储类型的相应部分，并提供适当的值，包括区域、桶名称和访问凭据。
* 保存您的更改。

{{% alert title="Note" color="info" %}}
假设我们使用 MinIO 的 Play 作为存储，需要注意的是它仅是一个测试服务器，不应在生产环境中使用：

	$ helm install drycc oci://registry.drycc.cc/drycc/charts/workflow \
		--namespace drycc \
		--set global.platformDomain=youdomain.com \
		--set builder.storageBucket=registry \
		--set builder.storageEndpoint=https://play.min.io \
		--set builder.storageAccesskey=Q3AM3UQ867SPQQA43P2F \
		--set builder.storageSecretkey=zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG \
		--set builder.storagePathStyle=auto \
		--set registry.storageBucket=registry \
		--set registry.storageEndpoint=https://play.min.io \
		--set registry.storageAccesskey=Q3AM3UQ867SPQQA43P2F \
		--set registry.storageSecretkey=zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG \
		--set registry.storagePathStyle=auto
{{% /alert %}}

现在您可以使用所需的集群外对象存储运行 `helm install drycc oci://registry.drycc.cc/drycc/charts/workflow --namespace drycc -f values.yaml`。


[storage]: ../understanding-workflow/components.md#object-storage
[aws-iam]: http://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html
[Azure Blob Storage]: https://azure.microsoft.com/en-us/services/storage/blobs/
