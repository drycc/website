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
NAME                      PORT     PROTOCOL    ADDRESSES
python-getting-started    80       HTTP        101.65.132.51
```

### Gateway TOML Format

Gateways are managed by applying a TOML file with the following structure:

| Field | Description |
|-------|-------------|
| `name` | Gateway name (required) |
| `ports` | List of ports the gateway listens on (required) |
| `ports[].port` | Network port number (1-65535) |
| `ports[].protocol` | Network protocol: `HTTP`, `HTTPS`, `TCP`, `UDP`, `TLS` |

### Applying a Gateway

Create or update a gateway by applying a TOML file:

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

Each `[[ports]]` header declares one entry of the port list. Applying a gateway replaces its entire port list.

### Viewing Gateway Details

`drycc gateways info` prints the gateway as TOML, including read-only fields such as `addresses`:

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

You can save this output to a file, edit the `[[ports]]` entries, and apply it again to update the gateway. Read-only fields such as `app` and `addresses` are ignored when applying.

## Create a Service for an Application

A Service exposes a set of Pods inside the cluster. Its `name` is both the resource identity and the Kubernetes Service name used by Route `backend_refs`. The `ptype` only selects Pods; multiple Services can use the same ptype with different names and ports.

The default web Service is created automatically with the application name. List the Services:

```
$ drycc services
NAME                         PTYPE    PORT    PROTOCOL    TARGET PORT    DOMAIN
python-getting-started       web      80      TCP         8000           python-getting-started.python-getting-started.svc
```

### Service TOML Format

Services are managed by applying a TOML file with the following structure:

| Field | Description |
|-------|-------------|
| `name` | Service name and Kubernetes `metadata.name` (required) |
| `ptype` | Process type selected by the Service (required) |
| `ports` | List of ports exposed by the Service (required) |
| `ports[].port` | Service port number (1-65535) |
| `ports[].protocol` | Network protocol: `TCP`, `UDP`, `SCTP` |
| `ports[].target_port` | Pod port to which traffic is forwarded (1-65535) |

### Applying a Service

Create or update a Service by applying a TOML file:

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

Each `[[ports]]` header declares one entry of the port list. Applying a Service replaces its entire port list but keeps its name stable, so existing Route backend references do not need to change.

### Viewing Service Details

`drycc services info` prints the Service as TOML:

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

You can save this output, edit the ptype or ports, and apply it again. Use the Service `name` in Route `rules.backend_refs[].name`.

### Removing a Service

```
$ drycc services remove python-getting-started-sleep
Removing service python-getting-started-sleep from python-getting-started... done
```

## Create a Route for an Application

A gateway may be attached to one or more route references which serve to direct traffic for a subset of traffic to a specific service. The web process type is already bound to the gateway and service.

List the routes:

```
$ drycc routes
NAME                       KIND        GATEWAYS                          SERVICES
python-getting-started     HTTPRoute   ["python-getting-started:80"]     ["python-getting-started:80"]
```

### Route TOML Format

Routes are managed by applying a TOML file with the following structure:

| Field | Description |
|-------|-------------|
| `name` | Route name (required) |
| `kind` | Route kind: `HTTPRoute`, `TCPRoute`, `UDPRoute`, `GRPCRoute`, `TLSRoute` (required, cannot be changed after creation) |
| `parent_refs` | List of parent gateways to attach this route to (required) |
| `parent_refs[].name` | Gateway name |
| `parent_refs[].port` | Gateway port |
| `rules` | List of routing rules (required) |
| `rules[].matches` | List of match conditions (path, headers, etc.) |
| `rules[].backend_refs` | List of backend services to route traffic to |
| `rules[].backend_refs[].kind` | Backend kind (typically `Service`) |
| `rules[].backend_refs[].name` | Backend service name |
| `rules[].backend_refs[].port` | Backend service port |
| `rules[].backend_refs[].weight` | Traffic weight |

{{% alert title="Note" color="info" %}}
In TOML, the bare `[[rules]]` header is what declares `rules` as a list, so it must be kept even though it holds no values itself. Nested entries such as `[[rules.matches]]` and `[[rules.backend_refs]]` always attach to the most recent `[[rules]]` block.
{{% /alert %}}

### Applying a Route

Create or update a route by applying a TOML file:

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

### Multiple Backends (Traffic Splitting)

You can split traffic between multiple backends using weights:

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

### Viewing Route Details

`drycc routes info` prints the route as TOML, including the read-only `routable` field:

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

### Removing a Route

```
$ drycc routes remove sleep
Removing route sleep from python-getting-started... done
```

[gateway-api]: https://gateway-api.sigs.k8s.io/
