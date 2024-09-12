---
title: About gateway for an Application
linkTitle: Managing App Gateway
description: A Gateway describes how traffic can be translated to Services within the cluster.
weight: 9
---


A [Gateway][gateway api] describes how traffic can be translated to Services within the cluster. That is, it defines a request for a way to translate traffic from somewhere that does not know about Kubernetes to somewhere that does. For example, traffic sent to a Kubernetes Service by a cloud load balancer, an in-cluster proxy, or an external hardware load balancer. While many use cases have client traffic originating “outside” the cluster, this is not a requirement.

## Create Gateway for an Application

Gateway is a way of exposing services externally, which generates an external IP address to connect route and service.
After deploy, the gateway has been created.

List the containers:
```
# drycc gateways
NAME                      LISENTER       PORT     PROTOCOL    ADDRESSES      
python-getting-started    tcp-80-0       80       HTTP        101.65.132.51     
```

You can also add a port in this gateway or create a one.
```
# drycc gateways:add python-getting-started --port=443 --protocol=HTTPS
Adding gateway python-getting-started to python-getting-started... done     
```

## Create service for an Application

Service is a way of exposing services internally, creating a service generates an internal DNS that can access `ptype`.
the web process type has been created, for others types, you should add as needed.

List the services:
```
$ drycc services
PTYPE      PORT    PROTOCOL    TARGET-PORT    DOMAIN                                    
web        80      TCP         8000           python-getting-started.python-getting-started.svc.cluster.local  
```

Add a new service for process type
```
# drycc services:add --help
# drycc services:add sleep 8001:8001
```

## Create Route for an Application

A Gateway may be attached to one or more Route references which serve to direct traffic for a subset of traffic to a specific service.
Same as the above， the web process type already bind the gateway and servies.

```
# drycc routes
NAME                           OWNER        PTYPE      KIND         SERVICE-PORT    GATEWAY                           LISTENER-PORT             
python-getting-started         demo         web        HTTPRoute    80              python-getting-started            80  
```

create a new route and attach gateway.
```
drycc routes:create sleep --ptype=sleep --kind=HTTPRoute --port=8001
drycc routes:attach sleep --gateway=python-getting-started --port=80
```


[gateway api]: https://gateway-api.sigs.k8s.io/
