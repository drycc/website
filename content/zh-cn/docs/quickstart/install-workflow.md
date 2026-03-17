---
title: 安装 Workflow
linkTitle: 安装 Workflow
description: 在纯主机上安装 Workflow，它可以是云服务器、裸机服务器、虚拟机，甚至您的笔记本电脑。
weight: 2
---

如果您有一个纯主机，它可以是云服务器、裸机服务器、虚拟机，甚至您的笔记本电脑。那么本章非常适合您。

## 操作系统

Drycc 预计可以在大多数现代 Linux 系统上运行。一些 OSS 有特定要求：

* (Red Hat/CentOS) Enterprise Linux，它们通常使用 RPM 包管理。
* Ubuntu (Desktop/Server/Cloud) Linux，一个非常流行的发行版。
* Debian GNU Linux，一个非常纯净的开源软件发行版。

如果您想添加更多 Linux 发行版支持，请在 GitHub 上提交 issue 或直接提交 PR。

## 系统软件

在安装 drycc workflow 之前，需要安装一些基本软件。

### OS 配置

K8s 需要大量端口。如果您不确定它们是什么，请关闭本地防火墙或打开这些端口。
同时，因为 k8s 需要系统时间，您需要确保系统时间正确。

### 安装 NFSv4 客户端

安装 NFSv4 客户端的命令因 Linux 发行版而异。

对于 Debian 和 Ubuntu，使用此命令：

```
$ apt-get install nfs-common
```

对于 RHEL、CentOS 和 EKS 与 AmazonLinux2 镜像的 EKS Kubernetes Worker AMI，使用此命令：

```
$ yum install nfs-utils
```

### 安装 curl

对于 Debian 和 Ubuntu，使用此命令：

```
$ apt-get install curl
```

对于 RHEL、CentOS 和 EKS 与 AmazonLinux2 镜像的 EKS Kubernetes Worker AMI，使用此命令：

```
$ yum install curl
```

### 安装 zstd

对于 Debian 和 Ubuntu，使用此命令：

```
$ apt-get install zstd
```

对于 RHEL、CentOS 和 EKS 与 AmazonLinux2 镜像的 EKS Kubernetes Worker AMI，使用此命令：

```
$ yum install zstd
```

## 硬件

硬件要求基于您的部署规模而扩展。最低推荐在这里概述。

* RAM：1G 最低（我们推荐至少 2GB）
* CPU：1 最低

此配置仅包含满足操作的最低要求。

## 磁盘

Drycc 性能取决于数据库的性能。为了确保最佳速度，我们推荐尽可能使用 SSD。磁盘性能在利用 SD 卡或 eMMC 的 ARM 设备上会有所不同。

## 域名

Drycc 需要一个完全由您控制的根域名，并将此域名指向要安装的服务器。
假设有一个通配符域名指向当前安装 drycc 的服务器，即名称 `*.dryccdoman.com`。
我们需要在安装前设置 `PLATFORM_DOMAIN` 环境变量。

```
$ export PLATFORM_DOMAIN=dryccdoman.co
```

当然，如果是测试环境，我们也可以使用 `nip.io`，一个 IP 到域名的服务。
例如，您的主机 IP 是 `59.46.3.190`，我们将获得以下域名 `59.46.3.190.nip.io`

```
$ export PLATFORM_DOMAIN=59.46.3.190.nip.io
```

## 安装

在安装之前，请确保您的安装环境是否是公网。
如果是内网环境且没有公网 IP，您需要禁用自动证书。

```
$ export CERT_MANAGER_ENABLED=false
```

然后您可以使用 https://www.drycc.cc/install.sh 上的安装脚本在基于 systemd 和 openrc 的系统上将 drycc 安装为服务。

```
$ curl -sfL https://www.drycc.cc/install.sh | bash -
```

如果需要安装测试版，请使用如下脚本安装。


```
$ export CHANNEL=testing
$ curl -sfL https://drycc-mirrors.drycc.cc/drycc/workflow/raw/refs/heads/main/install.sh | bash -
```

{{% alert title="Note" color="danger" %}}
如果您在中国，需要使用镜像加速：

```
$ curl -sfL https://www.drycc.cc/install.sh | INSTALL_DRYCC_MIRROR=cn bash -
```
{{% /alert %}}

### 安装节点

节点可以是简单的代理或服务器；服务器具有代理的功能。多个服务器具有高可用性，但服务器数量最多不应超过 7 个。代理数量没有限制。

* 首先，检查主节点的集群令牌。

```
$ cat /var/lib/rancher/k3s/server/node-token
K1078e7213ca32bdaabb44536f14b9ce7926bb201f41c3f3edd39975c16ff4901ea::server:33bde27f-ac49-4483-b6ac-f4eec2c6dbfa
```

我们假设集群主节点的 IP 地址是 `192.168.6.240`，那样的话。

* 然后，设置环境变量：

```
$ export K3S_URL=https://192.168.6.240:6443
$ export K3S_TOKEN="K1078e7213ca32bdaabb44536f14b9ce7926bb201f41c3f3edd39975c16ff4901ea::server:33bde27f-ac49-4483-b6ac-f4eec2c6dbfa"
```

{{% alert title="Note" color="danger" %}}
如果您在中国，需要使用镜像加速：

```
$ export INSTALL_DRYCC_MIRROR=cn
```
{{% /alert %}}

* 以服务器身份加入集群：

```
$ curl -sfL https://www.drycc.cc/install.sh | bash -s - install_k3s_server
```

* 以代理身份加入集群：

```
$ curl -sfL https://www.drycc.cc/install.sh | bash -s - install_k3s_agent
```

### 安装选项

使用此方法安装 drycc 时，可以使用以下环境变量来配置安装：

环境变量                                      | 描述
----------------------------------------------------------|---------------------------------------------------------------------------------------------
PLATFORM_DOMAIN                                           | 必需项，指定 drycc 的域名
DRYCC_ADMIN_USERNAME                                      | 必需项，指定 drycc 的管理员用户名
DRYCC_ADMIN_PASSWORD                                      | 必需项，指定 drycc 的管理员密码
CERT_MANAGER_ENABLED                                      | 是否使用自动证书。默认是 `false`
CHANNEL                                                   | 默认安装 `stable` 通道。您也可以指定 `testing`
KUBERNETES_SERVICE_HOST                                   | 设置为 kube-apiserver 前面的负载均衡器的 HOST
KUBERNETES_SERVICE_PORT                                   | 设置为 kube-apiserver 前面的负载均衡器的 PORT
METALLB_CONFIG_FILE                                       | metallb 配置文件路径，默认使用 layer 2 网络
LONGHORN_CONFIG_FILE                                      | Longhorn 配置文件路径
INSTALL_DRYCC_MIRROR                                      | 指定加速镜像位置。目前仅支持 `cn`
BUILDER_REPLICAS                                          | 要部署的构建器副本数
CONTROLLER_API_REPLICAS                                   | 要部署的控制器 API 副本数
CONTROLLER_CELERY_REPLICAS                                | 要部署的控制器 celery 副本数
CONTROLLER_METRIC_REPLICAS                                | 要部署的控制器指标副本数
CONTROLLER_MUTATE_REPLICAS                                | 要部署的控制器变异副本数
CONTROLLER_WEBHOOK_REPLICAS                               | 要部署的控制器 webhook 副本数
CONTROLLER_APP_RUNTIME_CLASS                              | RuntimeClass 用于选择容器运行时配置。
CONTROLLER_APP_GATEWAY_CLASS                              | 由 `drycc gateways` 分配的 GatewayClass；默认使用默认 GatewayClass
CONTROLLER_APP_STORAGE_CLASS                              | 由 `drycc volumes` 分配的 StorageClass；默认使用默认 storageClass
VALKEY_PERSISTENCE_SIZE                                   | 分配给 `valkey` 的持久化空间大小，默认是 `5Gi`
VALKEY_PERSISTENCE_STORAGE_CLASS                          | `valkey` 的 StorangeClass；默认使用默认 storangeclass
STORAGE_PERSISTENCE_SIZE                                  | 分配给 `storage` 的持久化空间大小，默认是 `5Gi`
STORAGE_PERSISTENCE_STORAGE_CLASS                         | `storage` 的 StorangeClass；默认使用默认 storangeclass
MONITOR_GRAFANA_PERSISTENCE_SIZE                          | 分配给 `monitor.grafana` 的持久化空间大小，默认是 `5Gi`
MONITOR_GRAFANA_PERSISTENCE_STORAGE_CLASS                 | `monitor` grafana 的 StorangeClass；默认使用默认 storangeclass
DATABASE_PERSISTENCE_SIZE                                 | 分配给 `database` 的持久化空间大小，默认是 `5Gi`
DATABASE_PERSISTENCE_STORAGE_CLASS                        | `database` 的 StorangeClass；默认使用默认 storangeclass
TIMESERIES_REPLICAS                                       | 要部署的时间序列副本数
TIMESERIES_PERSISTENCE_SIZE                               | 分配给 `timeseries` 的持久化空间大小，默认是 `5Gi`
TIMESERIES_PERSISTENCE_STORAGE_CLASS                      | `timeseries` 的 StorangeClass；默认使用默认 storangeclass
PASSPORT_REPLICAS                                         | 要部署的护照副本数
REGISTRY_REPLICAS                                         | 要部署的注册表副本数
HELMBROKER_API_REPLICAS                                   | 要部署的 helmbroker api 副本数
HELMBROKER_CELERY_REPLICAS                                | 要部署的 helmbroker celery 副本数
HELMBROKER_PERSISTENCE_SIZE                               | 分配给 `helmbroker` 的持久化空间大小，默认是 `5Gi`
HELMBROKER_PERSISTENCE_STORAGE_CLASS                      | `helmbroker` 的 StorangeClass；默认使用默认 storangeclass
VICTORIAMETRICS_CONFIG_FILE                               | victoriametrics 配置文件的路径，开启此项，下面的两个不会工作。
VICTORIAMETRICS_VMAGENT_PERSISTENCE_SIZE                  | 分配给 `victoriametrics` vmagent 的持久化空间大小，默认是 `10Gi`
VICTORIAMETRICS_VMAGENT_PERSISTENCE_STORAGE_CLASS         | `victoriametrics` vmagent 的 StorangeClass；默认使用默认 storangeclass
VICTORIAMETRICS_VMSTORAGE_PERSISTENCE_SIZE                | 分配给 `victoriametrics` vmstorage 的持久化空间大小，默认是 `10Gi`
VICTORIAMETRICS_VMSTORAGE_PERSISTENCE_STORAGE_CLASS       | `victoriametrics` vmstorage 的 StorangeClass；默认使用默认 storangeclass
K3S_DATA_DIR                                              | k3s 数据目录的配置；如果未设置，使用默认路径
ACME_SERVER                                               | ACME 服务器 URL，默认使用 letsencrypt
ACME_EAB_KEY_ID                                           | 您的外部账户绑定所索引的密钥 ID
ACME_EAB_KEY_SECRET                                       | 您的外部账户对称 MAC 密钥的密钥 Secret
CLUSTER_CIDR                                              | K3S 用于 Pod IP 的 IPv4/IPv6 网络 CIDR，默认是 `10.42.0.0/16`
SERVICE_CIDR                                              | K3S 用于 Service 的 IPv4/IPv6 网络 CIDR，默认是 `10.43.0.0/16`
CLUSTER_POOL_IPV4_MASK_SIZE                               | Cilium 分配给各个节点用于 IPAM 的 IPv4 CIDR 掩码大小，默认是 `24`

由于安装脚本将安装 k3s，其他环境变量可以参考 k3s 安装 [环境变量](https://rancher.com/docs/k3s/latest/en/installation/install-options/)。

## 卸载

如果您使用安装脚本安装了 drycc，您可以使用此脚本卸载整个 drycc。

```
$ curl -sfL https://www.drycc.cc/uninstall.sh | bash -
```
