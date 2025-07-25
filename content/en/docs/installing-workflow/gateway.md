---
title: Specify Gateway
linkTitle: Installing Gateway
description: Choose the gateway provider that best suits your needs and platform.
weight: 2
---

## Install Drycc Workflow (Specify gateway)

Now that Helm is installed and the repository has been added, install Workflow with a native gateway by running:

```
$ helm install drycc oci://registry.drycc.cc/charts/workflow \
    --namespace drycc \
    --set global.gatewayClass=istio \
    --set global.platformDomain=drycc.cc \
    --set builder.service.type=LoadBalancer
```

Of course, if you deploy it on a bare machine, you probably do not have Load Balancer. You need to use NodePort:
```
$ helm install drycc oci://registry.drycc.cc/charts/workflow \
    --namespace drycc \
    --set global.gatewayClass=istio \
    --set global.platformDomain=drycc.cc \
    --set builder.service.type=NodePort \
    --set builder.service.nodePort=32222
```

If you want to use Load Balancer on a bare machine, you can look at [metallb](https://github.com/metallb/metallb)

Where `global.platformDomain` is a **required** parameter that is traditionally not required for Workflow that is explained in the next section. In this example we are using `drycc.cc` for `$hostname`.

Helm will install a variety of Kubernetes resources in the `drycc` namespace.
Wait for the pods that Helm launched to be ready. Monitor their status by running:

```
$ kubectl --namespace=drycc get pods
```

You should also notice that several Kubernetes gatewayclass has been installed on your cluster. You can view it by running:

```
$ kubectl get gatewayclass --namespace drycc
```

Depending on the order in which the Workflow components initialize, some pods may restart. This is common during the
installation: if a component's dependencies are not yet available, that component will exit and Kubernetes will
automatically restart it.

Here, it can be seen that the controller, builder and registry all took a few loops waiting for storage before they were able to start:

```
$ kubectl --namespace=drycc get pods
NAME                          READY     STATUS    RESTARTS   AGE
drycc-builder-hy3xv            1/1       Running   5          5m
drycc-controller-g3cu8         1/1       Running   5          5m
drycc-controller-celery-cmxxn  3/3       Running   0          5m
drycc-database-rad1o           1/1       Running   0          5m
drycc-fluentbit-1v8uk          1/1       Running   0          5m
drycc-fluentbit-esm60          1/1       Running   0          5m
drycc-storage-4ww3t            1/1       Running   0          5m
drycc-registry-asozo           1/1       Running   1          5m
```

## Install a Kubernetes Gateway

Now that Workflow has been deployed with the `global.gatewayClass` , we will need a Kubernetes gateway in place to begin routing traffic.

Here is an example of how to use [istio](https://istio.io/) as an gateway for Workflow. Of course, you are welcome to use any controller you wish.

```
$ helm repo add istio https://istio-release.storage.googleapis.com/charts
$ helm repo update
$ kubectl create namespace istio-system
$ helm install istio-base istio/base -n istio-system
$ helm install istiod istio/istiod -n istio-system --wait
$ kubectl create namespace istio-ingress
$ helm install istio-ingress istio/gateway -n istio-ingress --wait
```

## Configure DNS

User must install [drycc](../quickstart/install-workflow.md) and then set up a hostname, and assumes the `*.$host` convention.

We need to point the `*.$host` record to the public IP address of your gateway. You can get the public IP using the following command. A wildcard entry is necessary here as apps will use the same rule after they are deployed.

```
$ kubectl get gateway --namespace drycc
NAME      CLASS   ADDRESS         PROGRAMMED   AGE
gateway   istio   138.91.243.152  True         36d
```

If we were using `drycc.cc` as a hostname, we would need to create the following A DNS records.

| Name                         | Type          | Value          |
| ---------------------------- |:-------------:| --------------:|
| *.drycc.cc                   | A             | 138.91.243.152 |

Once all of the pods are in the `READY` state, and `*.$host` resolves to the external IP found above, the preparation of gateway has been completed!

After installing Workflow, [register a user and deploy an application](../quickstart/deploy-an-app.md).

If your k8s does not provide public network loadblance, you need to install TCP proxy services such as haproxy on machines that can 
access both internal and external networks, and then expose `80` and `443`.