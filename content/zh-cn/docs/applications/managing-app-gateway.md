---
title: 关于应用的网关
linkTitle: 管理应用网关
description: Gateway 描述了如何将流量转换为集群内的服务。
weight: 9
---

[Gateway][gateway api] 描述了如何将流量转换为集群内的服务。也就是说，它定义了一种将流量从不知道 Kubernetes 的地方转换为知道的地方的方式。例如，由云负载均衡器、集群内代理或外部硬件负载均衡器发送到 Kubernetes 服务的流量。虽然许多用例的客户端流量源于"集群外部"，但这不是必需的。

## 为应用创建网关

网关是一种对外暴露服务的方式，它生成一个外部 IP 地址来连接路由和服务。部署后，网关会自动创建。

列出网关：

```
$ drycc gateways
NAME                      PORT     PROTOCOL    ADDRESSES
python-getting-started    80       HTTP        101.65.132.51
```

### 网关 TOML 格式

通过应用 TOML 文件来管理网关，结构如下：

| 字段 | 说明 |
|------|------|
| `name` | 网关名称（必填） |
| `ports` | 网关监听的端口列表（必填） |
| `ports[].port` | 网络端口号（1-65535） |
| `ports[].protocol` | 网络协议：`HTTP`、`HTTPS`、`TCP`、`UDP`、`TLS` |

### 应用网关

通过应用 TOML 文件创建或更新网关：

```
$ cat gateway.toml
name = "python-getting-started"

[[ports]]
port = 80
protocol = "HTTP"

[[ports]]
port = 443
protocol = "HTTPS"

$ drycc gateways apply gateway.toml
Applying gateway python-getting-started to python-getting-started... done
```

每个 `[[ports]]` 表头声明端口列表中的一项。应用网关会整体替换其端口列表。

### 查看网关详情

`drycc gateways info` 以 TOML 格式输出网关，包含 `addresses` 等只读字段：

```
$ drycc gateways info python-getting-started
name = "python-getting-started"

[[ports]]
  port = 80
  protocol = "HTTP"

[[addresses]]
  type = "IPAddress"
  value = "101.65.132.51"
```

您可以将该输出保存到文件，编辑 `[[ports]]` 条目后再次应用以更新网关。`app`、`addresses` 等只读字段在应用时会被忽略。

## 为应用创建服务

Service 用于在集群内暴露一组 Pod。`name` 既是资源身份，也是 Route `backend_refs` 引用的 Kubernetes Service 名称；`ptype` 只负责选择 Pod。多个 Service 可以使用相同的 ptype，但采用不同的名称和端口。

系统会自动创建默认 web Service，其名称为应用名称。列出 Service：

```
$ drycc services
NAME                         PTYPE    PORT    PROTOCOL    TARGET PORT    DOMAIN
python-getting-started       web      80      TCP         8000           python-getting-started.python-getting-started.svc
```

### Service TOML 格式

通过应用 TOML 文件来管理 Service，结构如下：

| 字段 | 说明 |
|------|------|
| `name` | Service 名称及 Kubernetes `metadata.name`（必填） |
| `ptype` | Service 选择的进程类型（必填） |
| `ports` | Service 暴露的端口列表（必填） |
| `ports[].port` | Service 端口号（1-65535） |
| `ports[].protocol` | 网络协议：`TCP`、`UDP`、`SCTP` |
| `ports[].target_port` | 流量转发到的 Pod 端口（1-65535） |

### 应用 Service

通过应用 TOML 文件创建或更新 Service：

```
$ cat service.toml
name = "python-getting-started-sleep"
ptype = "sleep"

[[ports]]
port = 8001
protocol = "TCP"
target_port = 8001

$ drycc services apply service.toml
Applying service python-getting-started-sleep to python-getting-started... done
```

每个 `[[ports]]` 表头声明端口列表中的一项。应用 Service 会整体替换端口列表，但名称保持稳定，因此已有 Route 后端引用无需修改。

### 查看 Service 详情

`drycc services info` 以 TOML 格式输出 Service：

```
$ drycc services info python-getting-started-sleep
domain = "python-getting-started-sleep.python-getting-started.svc"
name = "python-getting-started-sleep"
ptype = "sleep"

[[ports]]
  port = 8001
  protocol = "TCP"
  target_port = 8001
```

您可以保存该输出，修改 ptype 或端口后再次应用。在 Route 的 `rules.backend_refs[].name` 中使用 Service 的 `name`。

### 删除 Service

```
$ drycc services remove python-getting-started-sleep
Removing service python-getting-started-sleep from python-getting-started... done
```

## 为应用创建路由

网关可以附加到一个或多个路由引用，这些路由引用用于将部分流量引导到特定服务。
与上述相同，web 进程类型已经绑定了网关和服务。

列出路由：

```
$ drycc routes
NAME                       KIND        GATEWAYS                          SERVICES
python-getting-started     HTTPRoute   ["python-getting-started:80"]     ["python-getting-started:80"]
```

### 路由 TOML 格式

通过应用 TOML 文件来管理路由，结构如下：

| 字段 | 说明 |
|------|------|
| `name` | 路由名称（必填） |
| `kind` | 路由类型：`HTTPRoute`、`TCPRoute`、`UDPRoute`、`GRPCRoute`、`TLSRoute`（必填，创建后不可修改） |
| `parent_refs` | 要附加此路由的父网关列表（必填） |
| `parent_refs[].name` | 网关名称 |
| `parent_refs[].port` | 网关端口 |
| `rules` | 路由规则列表（必填） |
| `rules[].matches` | 匹配条件列表（路径、请求头等） |
| `rules[].backend_refs` | 后端服务列表，用于路由流量 |
| `rules[].backend_refs[].kind` | 后端类型（通常为 `Service`） |
| `rules[].backend_refs[].name` | 后端服务名称 |
| `rules[].backend_refs[].port` | 后端服务端口 |
| `rules[].backend_refs[].weight` | 流量权重 |

{{% alert title="注意" color="info" %}}
在 TOML 中，`[[rules]]` 空表头是声明 `rules` 为列表的关键，即使它本身没有值也必须保留。`[[rules.matches]]`、`[[rules.backend_refs]]` 等嵌套条目始终归属于最近的一个 `[[rules]]` 块。
{{% /alert %}}

### 应用路由

通过应用 TOML 文件创建或更新路由：

```
$ cat route.toml
name = "sleep"
kind = "HTTPRoute"

[[parent_refs]]
name = "python-getting-started"
port = 80

[[rules]]

[[rules.matches]]
path.type = "PathPrefix"
path.value = "/"

[[rules.backend_refs]]
kind = "Service"
name = "python-getting-started-sleep"
port = 8001
weight = 100

$ drycc routes apply route.toml
Applying route sleep to python-getting-started... done
```

### 多后端（流量分割）

可以使用权重在多个后端之间分割流量：

```toml
name = "canary"
kind = "HTTPRoute"

[[parent_refs]]
name = "python-getting-started"
port = 80

[[rules]]

[[rules.matches]]
path.type = "PathPrefix"
path.value = "/"

[[rules.backend_refs]]
kind = "Service"
name = "python-getting-started"
port = 80
weight = 90

[[rules.backend_refs]]
kind = "Service"
name = "python-getting-started-canary"
port = 80
weight = 10
```

### 查看路由详情

`drycc routes info` 以 TOML 格式输出路由，包含只读的 `routable` 字段：

```
$ drycc routes info sleep
name = "sleep"
kind = "HTTPRoute"
routable = true

[[parent_refs]]
  name = "python-getting-started"
  port = 80

[[rules]]

  [[rules.backend_refs]]
    kind = "Service"
    name = "python-getting-started-sleep"
    port = 8001
    weight = 100

  [[rules.matches]]
    [rules.matches.path]
      type = "PathPrefix"
      value = "/"
```

### 删除路由

```
$ drycc routes remove sleep
Removing route sleep from python-getting-started... done
```


[gateway api]: https://gateway-api.sigs.k8s.io/
