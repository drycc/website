---
title: Platform Logging
linkTitle: Platform Logging
description: Logs are a stream of time-stamped events aggregated from the output streams of all your app’s running processes. Retrieve, filter, or use syslog drains.
weight: 4
---

We’re working with Quickwit to bring you an application log cluster and search interface.

## Architecture Diagram

```
┌───────────┐                   ┌───────────┐                     
│ Container │                   │  Grafana  │
└───────────┘                   └───────────┘
      │                               ^
     log                              |                
      │                               |                
      ˅                               │                
┌───────────┐                   ┌───────────┐     
│ Fluentbit │─────otel/grpc────>│  Quickwit │     
└───────────┘                   └───────────┘     
                                                                          
```

## Default Configuration

Fluent Bit is based in a pluggable architecture where different plugins plays a major role in the data pipeline, more than 70 built-in plugins available.
Please refer to charts [values.yaml](https://github.com/drycc/fluentbit/blob/main/charts/fluentbit/values.yaml) for specific configurations.
