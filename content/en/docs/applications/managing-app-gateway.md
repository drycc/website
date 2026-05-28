---
title: Managing App Gateway
linkTitle: Managing App Gateway
description: Learn how to manage gateways, services, and routes for Drycc applications to control traffic flow and service exposure.
weight: 9
---

A [Gateway][gateway-api] describes how traffic can be translated to services within the cluster. It defines a request for a way to translate traffic from outside the cluster to Kubernetes services. For example, traffic sent to a Kubernetes service by a cloud load balancer, an in-cluster proxy, or an external hardware load balancer. While many use cases have client traffic originating "outside" the cluster, this is not a requirement.

## Create a Gateway for an Application

A gateway is a way of exposing services externally, which generates an external IP address to connect routes and services. After deployment, the gateway is automatically created.

List the gateways:

```
$ drycc gateways
NAME                      LISTENER       PORT     PROTOCOL    ADDRESSES
python-getting-started    tcp-80-0       80       HTTP        101.65.132.51
```

You can also update this gateway by applying a YAML file in K8s-style format:

```
$ cat gateway.yaml
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

$ drycc gateways apply gateway.yaml
Applying gateway python-getting-started to python-getting-started... done
```

`drycc gateways info` prints the gateway in K8s-style format, including `status` fields returned by the controller or cluster, similar to `kubectl get -o yaml`.

## Create a Service for an Application

A service is a way of exposing services internally, creating a service generates an internal DNS that can access process types. The web process type is created automatically; for other types, you should add them as needed.

List the services:

```
$ drycc services
PTYPE      PORT    PROTOCOL    TARGET-PORT    DOMAIN
web        80      TCP         8000           python-getting-started.python-getting-started.svc
```

Add a new service for a process type:

```
$ drycc services add sleep 8001:8001
```

## Create a Route for an Application

A gateway may be attached to one or more route references which serve to direct traffic for a subset of traffic to a specific service. The web process type is already bound to the gateway and service.

List the routes:

```
$ drycc routes
NAME                           OWNER        KIND           GATEWAYS                              SERVICES
python-getting-started         demo         HTTPRoute      ["python-getting-started:80"]         ["python-getting-started:80"]
```

### Route YAML Format

Routes use a K8s-style manifest format with the following structure:

| Field | Description |
|-------|-------------|
| `apiVersion` | API version, e.g. `controller.drycc.cc/v2.3` |
| `kind` | Route type: `HTTPRoute`, `TCPRoute`, `UDPRoute`, `GRPCRoute`, `TLSRoute` |
| `metadata.name` | Route name (required) |
| `spec.parents` | List of parent gateways to attach this route to |
| `spec.parents[].name` | Gateway name |
| `spec.parents[].port` | Gateway port |
| `spec.rules` | List of routing rules |
| `spec.rules[].matches` | List of match conditions (path, headers, etc.) |
| `spec.rules[].backends` | List of backend services to route traffic to |
| `spec.rules[].backends[].kind` | Backend kind (typically `Service`) |
| `spec.rules[].backends[].name` | Backend service name |
| `spec.rules[].backends[].port` | Backend service port |
| `spec.rules[].backends[].weight` | Traffic weight (0-100) |

### Applying a Route

Create or update a route by applying a YAML file:

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

### Multiple Backends (Traffic Splitting)

You can split traffic between multiple backends using weights:

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

### Viewing Route Details

`drycc routes info` prints the route in K8s-style format, including `status` fields such as `routable`, similar to `kubectl get -o yaml`.

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

### Removing a Route

```
$ drycc routes remove sleep
Removing route sleep from python-getting-started... done
```

[gateway-api]: https://gateway-api.sigs.k8s.io/
