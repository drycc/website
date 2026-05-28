---
title: 关于应用的网关
linkTitle: 管理应用网关
description: Gateway 描述了如何将流量转换为集群内的服务。
weight: 9
---

[Gateway][gateway api] 描述了如何将流量转换为集群内的服务。也就是说，它定义了一种将流量从不知道 Kubernetes 的地方转换为知道的地方的方式。例如，由云负载均衡器、集群内代理或外部硬件负载均衡器发送到 Kubernetes 服务的流量。虽然许多用例的客户端流量源于"集群外部"，但这不是必需的。

## 为应用创建网关

网关是一种对外暴露服务的方式，它生成一个外部 IP 地址来连接路由和服务。
部署后，网关已创建。

列出网关：
```
# drycc gateways
NAME                      PORT     PROTOCOL    ADDRESSES
python-getting-started    80       HTTP        101.65.132.51
```

您也可以通过应用 K8s 风格的 YAML 文件来更新网关：
```
# cat gateway.yaml
apiVersion: controller.drycc.cc/v2.3
kind: Gateway
metadata:
  name: python-getting-started
spec:
  ports:
  - port: 80
    protocol: HTTP
  - port: 443
    protocol: HTTPS

# drycc gateways apply gateway.yaml
Applying gateway python-getting-started to python-getting-started... done
```

`drycc gateways info` 会以 K8s 风格格式输出网关，包含 controller 或集群返回的 `status` 等字段，类似 `kubectl get -o yaml`。

## 为应用创建服务

服务是一种对内暴露服务的方式，创建服务会生成一个内部 DNS，可以访问 `ptype`。
web 进程类型已创建，对于其他类型，您应该根据需要添加。

列出服务：
```
$ drycc services
PTYPE      PORT    PROTOCOL    TARGET-PORT    DOMAIN
web        80      TCP         8000           python-getting-started.python-getting-started.svc
```

为进程类型添加新服务
```
# drycc services add --help
# drycc services add sleep 8001:8001
```

## 为应用创建路由

网关可以附加到一个或多个路由引用，这些路由引用用于将部分流量引导到特定服务。
与上述相同，web 进程类型已经绑定了网关和服务。

```
# drycc routes
NAME                           OWNER        KIND           GATEWAYS                              SERVICES
python-getting-started         demo         HTTPRoute      ["python-getting-started:80"]         ["python-getting-started:80"]
```

### 路由 YAML 格式

路由使用 K8s 风格的 manifest 格式，结构如下：

| 字段 | 说明 |
|------|------|
| `apiVersion` | API 版本，例如 `controller.drycc.cc/v2.3` |
| `kind` | 路由类型：`HTTPRoute`、`TCPRoute`、`UDPRoute`、`GRPCRoute`、`TLSRoute` |
| `metadata.name` | 路由名称（必填） |
| `spec.parents` | 要附加此路由的父网关列表 |
| `spec.parents[].name` | 网关名称 |
| `spec.parents[].port` | 网关端口 |
| `spec.rules` | 路由规则列表 |
| `spec.rules[].matches` | 匹配条件列表（路径、请求头等） |
| `spec.rules[].backends` | 后端服务列表，用于路由流量 |
| `spec.rules[].backends[].kind` | 后端类型（通常为 `Service`） |
| `spec.rules[].backends[].name` | 后端服务名称 |
| `spec.rules[].backends[].port` | 后端服务端口 |
| `spec.rules[].backends[].weight` | 流量权重（0-100） |

### 应用路由

通过应用 YAML 文件创建或更新路由：

```
$ cat route.yaml
apiVersion: controller.drycc.cc/v2.3
kind: HTTPRoute
metadata:
  name: sleep
spec:
  parents:
  - name: python-getting-started
    port: 80
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backends:
    - kind: Service
      name: python-getting-started-sleep
      port: 8001
      weight: 100

$ drycc routes apply route.yaml
Applying route sleep to python-getting-started... done
```

### 多后端（流量分割）

可以使用权重在多个后端之间分割流量：

```yaml
apiVersion: controller.drycc.cc/v2.3
kind: HTTPRoute
metadata:
  name: canary
spec:
  parents:
  - name: python-getting-started
    port: 80
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backends:
    - kind: Service
      name: python-getting-started-web
      port: 80
      weight: 90
    - kind: Service
      name: python-getting-started-canary
      port: 80
      weight: 10
```

### 查看路由详情

`drycc routes info` 会以 K8s 风格格式输出路由，包含 `routable` 等 `status` 字段，类似 `kubectl get -o yaml`。

```
$ drycc routes info sleep
apiVersion: controller.drycc.cc/v2.3
kind: HTTPRoute
metadata:
  name: sleep
spec:
  parents:
  - name: python-getting-started
    port: 80
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backends:
    - kind: Service
      name: python-getting-started-sleep
      port: 8001
      weight: 100
status:
  routable: true
```

### 删除路由

```
$ drycc routes remove sleep
Removing route sleep from python-getting-started... done
```


[gateway api]: https://gateway-api.sigs.k8s.io/
