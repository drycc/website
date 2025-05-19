---
title:  Platform Monitoring
linkTitle: Platform Monitoring
description: Platform monitoring to your apps to spot issues in advance and respond to incidents quickly.

weight: 5
---

## Description

We now include a monitoring stack for introspection on a running Kubernetes cluster. The stack includes 4 components:

* [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics), kube-state-metrics (KSM) is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.
* [Node Exporter](http://github.com/prometheus/node_exporter), Prometheus exporter for hardware and OS metrics exposed by *NIX kernels.
* [Victoriametrics](https://victoriametrics.com/), a [Cloud Native Computing Foundation](https://cncf.io/) project, is a systems and service monitoring system.
* [Grafana](http://grafana.org/), Graphing tool for time series data

## Architecture Diagram

```
┌────────────────┐                                                        
│ HOST           │                                                        
│  node-exporter │◀──┐                          ┌──────────────────┐         
└────────────────┘   │                          │kube-state-metrics│         
                     │                          └──────────────────┘         
┌────────────────┐   │                                    ▲                    
│ HOST           │   │    ┌─────────────────┐             │                    
│  node-exporter │◀──┼────│ victoriametrics │─────────────┘                    
└────────────────┘   │    └─────────────────┘                                  
                     │             ▲                                         
┌───────────────┐    │             │                                         
│ HOST          │    │             ▼                                         
│  node-exporter│◀───┘       ┌──────────┐                                    
└───────────────┘            │ Grafana  │                                    
                             └──────────┘                                    
```

## [Grafana](https://grafana.com/)
Grafana allows users to create custom dashboards that visualize the data captured to the running VictoriaMetrics component. By default Grafana is exposed using a [service annotation](https://github.com/drycc/router#how-it-works) through the router at the following URL: `http://grafana.mydomain.com`. The default login is `admin/admin`. If you are interested in changing these values please see [Tuning Component Settings][].

Grafana will preload several dashboards to help operators get started with monitoring Kubernetes and Drycc Workflow.
These dashboards are meant as starting points and don't include every item that might be desirable to monitor in a
production installation.

Drycc Workflow monitoring by default does not write data to the host filesystem or to long-term storage. If the Grafana instance fails, modified dashboards are lost.

### Production Configuration
A production install of Grafana should have the following configuration values changed if possible:

* Change the default username and password from `admin/admin`. The value for the password is passed in plain text so it is best to set this value on the command line instead of checking it into version control.
* Enable persistence
* Use a supported external database such as mysql or postgres. You can find more information [here](https://github.com/drycc/monitor/blob/main/grafana/rootfs/usr/share/grafana/grafana.ini.tpl#L62)


### On Cluster Persistence
Enabling persistence will allow your custom configuration to persist across pod restarts. This means that the default sqllite database (which stores things like sessions and user data) will not disappear if you upgrade the Workflow installation.

If you wish to have persistence for Grafana you can set `enabled` to `true` in the `values.yaml` file before running `helm install`.

```
 grafana:
   # Configure the following ONLY if you want persistence for on-cluster grafana
   # GCP PDs and EBS volumes are supported only
   persistence:
     enabled: true # Set to true to enable persistence
     size: 5Gi # PVC size
```

### Off Cluster Grafana

If you wish to provide your own Grafana instance you can set `grafana.enabled` in the `values.yaml` file before running `helm install`.

## [VictoriaMetrics](https://victoriametrics.com/)
VictoriaMetrics is a fast and scalable open source time series database and monitoring solution that lets users build a monitoring platform without scalability issues and minimal operational burden, it is fully compatible with the prometheus format.

### On Cluster Persistence
You can set `node-exporter` and `kube-state-metrics` to `true` or `false` in the `values.yaml`.
-If you wish to have persistence for VictoriaMetrics you can set `enabled` to `true` in the `values.yaml` file before running `helm install`.

```
victoriametrics:
  vmstorage:
    replicas: 3
    extraArgs:
    - --retentionPeriod=30d
    temporary:
      enabled: true
      size: 5Gi
      storageClass: "toplvm-ssd"
    persistence:
      enabled: true
      size: 10Gi
      storageClass: "toplvm-hdd"
  node-exporter:
    enabled: true
  kube-state-metrics:
    enabled: true
```

### Off Cluster VictoriaMetrics

To use false VictoriaMetrics, please provide the following values in the `values.yaml` file before running `helm install`.

* `victoriametrics.enabled=false`
* `grafana.prometheusUrl="http://my.prometheus.url:9090"`
* `controller.prometheusUrl="http://my.prometheus.url:9090"`
