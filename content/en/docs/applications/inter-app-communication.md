---
title: Inter-app Communication
linkTitle: Inter-app Communication
description: Enable communication between Drycc applications using DNS service discovery.
weight: 11
---

Multi-process applications often feature one public-facing process supported by background processes that handle scheduled tasks or queue processing. Implement this architecture on Drycc Workflow by enabling DNS-based communication between applications and hiding supporting processes from public access.

## DNS Service Discovery

Workflow creates a default [Kubernetes Service](https://kubernetes.io/docs/user-guide/services/) for the web process type. You can also create named Services for any process type, including multiple Services that select the same process type with different ports.

The default web Service uses the application name and listens on port 80. Custom Services use their configured names and ports. Every Service receives a cluster-internal DNS name in the form `<service-name>.<app-id>.svc`.

For example, an application can connect to the `sleep` Service on `python-getting-started-sleep.python-getting-started.svc:8001`. Use the Service name shown by `drycc services list`; it is also the name used by Route backend references.
