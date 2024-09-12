---
title: Managing Application Metrics
linkTitle: Managing App Metrics
description: Metrics supports basic monitoring capabilities for Pod, providing various monitoring indicators such as CPU, memory, disk, network, etc., to meet the basic monitoring requirements for Pod resources.
weight: 6
---

## Create an authentication token

Create an authentication token using the drycc client.

```
# drycc tokens:add prometheus --password admin --username admin
 !    WARNING: Make sure to copy your token now.
 !    You won't be able to see it again, please confirm whether to continue.
 !    To proceed, type "yes" !

> yes
UUID                                  USERNAME    TOKEN                                                                                              
58176cf1-37a8-4c52-9b27-4c7a47269dfb  admin       1F2c7A802aF640fd9F31dD846AdDf56BcMsay
```

## Add scrape configurations for prometheus

A valid example file can be found here.

The global configuration specifies parameters that are valid in all other configuration contexts. They also serve as defaults for other configuration sections.

```
global:
  scrape_interval:   60s
  evaluation_interval: 60s
scrape_configs:
- job_name: 'drycc'
  scheme: https
  metrics_path: /v2/apps/<appname>/metrics
  authorization:
    type: Token
    credentials: 1F2c7A802aF640fd9F31dD846AdDf56BcMsay
  static_configs:
  - targets: ['drycc.domain.com']
```



