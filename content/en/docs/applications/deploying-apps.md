---
title: Deploying an Application
linkTitle: Deploying Apps
description: Learn how to deploy applications to Drycc using git push or the drycc client.
weight: 1
---

Deploy applications to Drycc using `git push` or the `drycc` client. An [Application][] runs inside containers and can scale horizontally if it follows the [Twelve-Factor App][] methodology.

## Supported Applications

Drycc Workflow deploys any application or service that runs in a container. To scale horizontally, applications must store state in external backing services rather than the local filesystem.

For example, content management systems like WordPress and Drupal that persist data to the local filesystem cannot scale horizontally using `drycc scale`. However, most modern applications feature stateless application tiers that scale well on Drycc.

## Login to the Controller

{{% alert title="Note" color="danger" %}}
Install the client and register before deploying applications. See [client installation][install client] and [user registration](../users/registration.md).
{{% /alert %}}

Authenticate against the Drycc [Controller][] using the URL provided by your administrator:

```
$ drycc login http://drycc.example.com
Opening browser to http://drycc.example.com/v2/login/drycc/?key=4ccc81ee2dce4349ad5261ceffe72c71
Waiting for login... .o.Logged in as admin
Configuration file written to /root/.drycc/client.json
```

Alternatively, log in with username and password:

```
$ drycc login http://drycc.example.com --username=demo --password=demo
Configuration file written to /root/.drycc/client.json
```

## Select a Build Process

Drycc Workflow supports three build methods:

### Buildpacks

Use Cloud Native Buildpacks to build applications following [CNB documentation](https://buildpacks.io/docs/).

Learn more: [Deploying with Buildpacks](../applications/using-buildpacks.md)

### Dockerfiles

Define portable execution environments using Dockerfiles built on your chosen base OS.

Learn more: [Deploying with Dockerfiles](../applications/using-dockerfiles.md)

### Container Images

Deploy container images from public or private registries, ensuring identical images across development, CI, and production.

Learn more: [Deploying with Container Images](../applications/using-container-images.md)

## Tune Application Settings

Configure application-specific settings using `drycc config:set`. These override global defaults:

| Setting | Description |
|---------|-------------|
| `DRYCC_DISABLE_CACHE` | Disable the [imagebuilder cache][] (default: not set) |
| `DRYCC_DEPLOY_BATCHES` | Number of pods to bring up/down sequentially during scaling (default: number of available nodes) |
| `DRYCC_DEPLOY_TIMEOUT` | Deploy timeout in seconds per batch (default: 120) |
| `IMAGE_PULL_POLICY` | Kubernetes [image pull policy][pull-policy] (default: "IfNotPresent"; allowed: "Always", "IfNotPresent") |
| `KUBERNETES_DEPLOYMENTS_REVISION_HISTORY_LIMIT` | Number of [deployment revisions][kubernetes-deployment-revision] Kubernetes retains (default: all) |
| `KUBERNETES_POD_TERMINATION_GRACE_PERIOD_SECONDS` | Seconds Kubernetes waits for pod termination after SIGTERM (default: 30) |

### Deploy Timeout

The deploy timeout setting behaves differently depending on the deployment method.

#### Deployments (Current Method)

Kubernetes handles rolling updates server-side. The base timeout multiplies with `DRYCC_DEPLOY_BATCHES` for the total timeout. For example: 240 seconds × 4 batches = 960 seconds total.

#### ReplicationController Deploy (Legacy)

This timeout defines how long to wait for each batch to complete within `DRYCC_DEPLOY_BATCHES`.

#### Timeout Extensions

The base timeout extends for:
- Health checks using `initial_delay_seconds` on liveness/readiness probes (uses the larger value)
- Slow image pulls (adds 10 minutes when pulls exceed 1 minute)

### Deployments

Drycc Workflow uses [Kubernetes Deployments][] for deployments. Previous versions used ReplicationControllers (enable with `DRYCC_KUBERNETES_DEPLOYMENTS=1`).

Benefits of Deployments include:
- Server-side rolling updates in Kubernetes
- Continued deployments even if CLI connection interrupts
- Better pod management

Each deployment creates:
- One Deployment object per process type
- Multiple ReplicaSets (one per release)
- ReplicaSets manage running pods

The CLI behavior remains the same. The only visible difference is in `drycc ps` output showing different pod names.

[slugbuilder cache]: ./managing-app-configuration.md#slugbuilder-cache
[install client]: ../users/cli.md#installation
[application]: ../reference-guide/terms.md#application
[controller]: ../understanding-workflow/components.md#controller
[Twelve-Factor App]: http://12factor.net/
[Deployments]: http://kubernetes.io/docs/user-guide/deployments/
[kubernetes-deployment-revision]: http://kubernetes.io/docs/user-guide/deployments/#revision-history-limit
[ReplicationControllers]: http://kubernetes.io/docs/user-guide/replication-controller/
