---
title: Components
description: Workflow is comprised of a number of small, independent services that combine to create a distributed CaaS.
weight: 3
---

All Workflow components are deployed as services (and associated controllers) in your Kubernetes cluster.
If you are interested we have a more detailed exploration of the [Workflow architecture][architecture].

All of the componentry for Workflow is built with composability in mind. If you
need to customize one of the components for your specific deployment or need
the functionality in your own project we invite you to give it a shot!

## Controller

**Project Location:** [drycc/controller](https://github.com/drycc/controller)

The controller component is an HTTP API server which serves as the endpoint for
the `drycc` CLI. The controller provides all of the platform functionality as
well as interfacing with your Kubernetes cluster. The controller persists all
of its data to the database component.

## Passport

**Project Location:** [drycc/passport](https://github.com/drycc/passport)

The passport component exposes a web API and provide OAuth2 authentication.

## Database

**Project Location:** [drycc/postgres](https://github.com/drycc/postgres)

The database component is a managed instance of [PostgreSQL][] which holds a
majority of the platforms state. Backups and WAL files are pushed to object
storage via [WAL-E][]. When the database is restarted, backups are fetched and
replayed from object storage so no data is lost.

## Builder

**Project Location:** [drycc/builder](https://github.com/drycc/builder)


The builder component is responsible for accepting code pushes via [Git][] and
managing the build process of your [Application][]. The builder process is:

1. Receives incoming `git push` requests over SSH
2. Authenticates the user via SSH key fingerprint
3. Authorizes the user's access to push code to the Application
4. Starts the Application Build phase (see below)
5. Triggers a new [Release][] via the Controller

Builder currently supports both buildpack and Dockerfile based builds.

**Project Location:** [drycc/imagebuilder](https://github.com/drycc/imagebuilder)

For Buildpack-based deploys, the builder component will launch a one-shot Job
in the `drycc` namespace. This job runs `imagebuilder` component which handles
default and custom buildpacks (specified by `.packbuilder`). The completed image
is pushed to the managed Container registry on cluster. For more information
about buildpacks see [using buildpacks][using-buildpacks].

Unlike buildpack-based, For Applications which contain a `Dockerfile` in the root
of the repository, it generates a Container image (using the underlying Container engine).
For more information see [using Dockerfiles][using-dockerfiles].

## Object Storage

**Project Location:** [drycc/storage](https://github.com/drycc/storage)

All of the Workflow components that need to persist data will ship them to the
object storage that was configured for the cluster.For example, database ships
its WAL files, registry stores Container images, and slugbuilder stores slugs.

Workflow supports either on or off-cluster storage. For production deployments
we highly recommend that you configure [off-cluster object storage][configure-objectstorage].

To facilitate experimentation, development and test environments, the default charts for
Workflow include on-cluster storage via [storage](https://github.com/drycc/storage).

If you also feel comfortable using Kubernetes persistent volumes you may
configure storage to use persistent storage available in your environment.

## Registry

**Project Location:** [drycc/registry](https://github.com/drycc/registry)

The registry component is a managed container registry which holds application
images generated from the builder component. Registry persists the Container image
images to either local storage (in development mode) or to object storage
configured for the cluster.

## Quickwit

**Project Location:** [drycc/quickwit](https://github.com/drycc/quickwit)

Quickwit is the first engine to execute complex search and analytics queries directly on cloud storage with 
sub-second latency. Powered by Rust and its decoupled compute and storage architecture, it is designed to 
be resource-efficient, easy to operate, and scale to petabytes of data.

Quickwit is a great fit for log management, distributed tracing, and generally immutable data such as 
conversational data (emails, texts, messaging platforms) and event-based analytics.

## Fluentbit

**Project Location:** [drycc/fluentbit](https://github.com/drycc/fluentbit)

Fluent Bit is a fast and lightweight telemetry agent for logs, metrics, and traces for Linux, macOS, Windows, 
and BSD family operating systems. Fluent Bit has been made with a strong focus on performance to allow the 
collection and processing of telemetry data from different sources without complexity.


## Victoriametrics

**Project Location:** [drycc/victoriametrics](https://github.com/drycc/victoriametrics)

Victoriametrics is a system monitoring and alerting system. It was opensourced by SoundCloud in 2012 and is
the second project both to join and to graduate within Cloud Native Computing Foundation after Kubernetes.
Victoriametrics stores all metrics data as time series, i.e metrics information is stored along with the
timestamp at which it was recorded, optional key-value pairs called as labels can also be stored along
with metrics.

## HelmBroker

**Project Location:** [drycc-addons/helmbroker](https://github.com/drycc-addons/helmbroker)

Helm Broker is a Service Broker that exposes Helm charts as Service Classes in Service Catalog.
To do so, Helm Broker uses the concept of addons. An addon is an abstraction layer over a Helm chart
which provides all information required to convert the chart into a Service Class.

## Victoriametrics

**Project Location:** [drycc/victoriametrics](https://github.com/drycc/victoriametrics)

Victoriametrics is an open-source systemsmonitoring and alerting toolkit originally built atSoundCloud.

## See Also

* [Workflow Concepts][concepts]
* [Workflow Architecture][architecture]

[Application]: ../reference-guide/terms.md#application
[Config]: ../reference-guide/terms.md#config
[Git]: http://git-scm.com/
[Nginx]: http://nginx.org/
[PostgreSQL]: http://www.postgresql.org/
[WAL-E]: https://github.com/wal-e/wal-e
[architecture]: architecture.md
[concepts]: concepts.md
[configure-objectstorage]: ../installing-workflow/configuring-object-storage.md
[release]: ../reference-guide/terms.md#release
[using-buildpacks]: ../applications/using-buildpacks.md
[using-dockerfiles]: ../applications/using-dockerfiles.md
