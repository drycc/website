---
title: Configuring Object Storage
linkTitle: Configuring Object Storage
description: A variety of Drycc Workflow components rely on an object storage system to do their work including storing application slugs, Container images and database logs.
weight: 4
---

Drycc Workflow ships with [Storage][storage] by default, which provides in-cluster storage.

## Configuring off-cluster Object Storage

Every component that relies on object storage uses two inputs for configuration:

1. Access credentials stored as a Kubernetes secret.
2. You must use object storage services that are compatible with the S3 API.

The Helm chart for Drycc Workflow can be easily configured to connect Workflow components to off-cluster object storage. Drycc Workflow currently supports Google Cloud Storage, Amazon S3, [Azure Blob Storage][], and OpenStack Swift Storage.

### Step 1: Create storage buckets

Create storage buckets for each of the Workflow subsystems: `builder` and `registry`.

Depending on your chosen object storage, you may need to provide globally unique bucket names. If you are using S3, use hyphens instead of periods in the bucket names. Using periods in the bucket name will cause an [SSL certificate validation issue with S3](https://forums.aws.amazon.com/thread.jspa?threadID=105357).

If you provide credentials with sufficient access to the underlying storage, Workflow components will create the buckets if they do not exist.

### Step 2: Generate storage credentials

If applicable, generate credentials that have create and write access to the storage buckets created in Step 1.

If you are using AWS S3 and your Kubernetes nodes are configured with appropriate [IAM][aws-iam] API keys via Instance Roles, you do not need to create API credentials. However, validate that the Instance Role has appropriate permissions to the configured buckets!

### Step 3: Configure Workflow Chart

Operators should configure object storage by editing the Helm values file before running `helm install`. To do so:

* Fetch the Helm values by running `helm inspect values oci://registry.drycc.cc/drycc/charts/workflow > values.yaml`
* Update the `builder/storage` and `registry/storage` parameters to reference the platform you are using.
* Find the corresponding section for your storage type and provide appropriate values including region, bucket names, and access credentials.
* Save your changes.

{{% alert title="Note" color="info" %}}
Assume we are using MinIO's play for storage, noting that it is only a test server and should not be used in production environments:

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

You are now ready to run `helm install drycc oci://registry.drycc.cc/drycc/charts/workflow --namespace drycc -f values.yaml` using your desired object storage.


[storage]: ../understanding-workflow/components.md#object-storage
[aws-iam]: http://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html
[Azure Blob Storage]: https://azure.microsoft.com/en-us/services/storage/blobs/
