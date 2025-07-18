---
title: Upgrading Workflow
linkTitle: Upgrading Workflow
description: Drycc Workflow releases may be upgraded in-place with minimal downtime.
weight: 6
---

This upgrade process requires:

* Helm version [2.1.0 or newer](https://github.com/kubernetes/helm/releases/tag/v2.1.0)
* Configured Off-Cluster Storage

## Upgrade Process

!!! note
    If upgrading from a [Helm Classic](https://github.com/helm/helm-classic) install, you'll need to 'migrate' the cluster to a [Kubernetes Helm](https://github.com/kubernetes/helm) installation.  See [Workflow-Migration][] for steps.

### Step 1: Apply the Workflow upgrade

Helm will remove all components from the previous release. Traffic to applications deployed through
Workflow will continue to flow during the upgrade. No service interruptions should occur.

If Workflow is not configured to use off-cluster Postgres, the Workflow API will experience a brief
period of downtime while the database recovers from backup.

First, find the name of the release helm gave to your deployment with `helm ls`, then run

```
$ helm upgrade <release-name> oci://registry.drycc.cc/charts/workflow
```


**Note:** If using off-cluster object storage on [gcs](https://cloud.google.com/storage/) and/or off-cluster registry using [gcr](https://cloud.google.com/container-registry/) and intending to upgrade from a pre-`v2.10.0` chart to `v2.10.0` or greater, the `key_json` values will now need to be pre-base64-encoded.  Therefore, assuming the rest of the custom/off-cluster values are defined in the existing `values.yaml` used for previous installs, the following may be run:

```
$ B64_KEY_JSON="$(cat ~/path/to/key.json | base64 -w 0)"
$ helm upgrade <release_name> drycc/workflow -f values.yaml --set gcs.key_json="${B64_KEY_JSON}",registry-token-refresher.gcr.key_json="${B64_KEY_JSON}"
```

Alternatively, simply replace the appropriate values in values.yaml and do without the `--set`
parameter. Make sure to wrap it in single quotes as double quotes will give a parser error when
upgrading.

### Step 2: Verify Upgrade

Verify that all components have started and passed their readiness checks:

```
$ kubectl --namespace=drycc get pods
NAME                                     READY     STATUS    RESTARTS   AGE
drycc-builder-2448122224-3cibz            1/1       Running   0          5m
drycc-controller-1410285775-ipc34         1/1       Running   3          5m
drycc-controller-celery-694f75749b-cmxxn  3/3       Running   0          5m
drycc-database-e7c5z                      1/1       Running   0          5m
drycc-fluentbit-45h7j                     1/1       Running   0          5m
drycc-fluentbit-4z7lw                     1/1       Running   0          5m
drycc-fluentbit-k2wsw                     1/1       Running   0          5m
drycc-fluentbit-skdw4                     1/1       Running   0          5m
drycc-valkey-8nazu                        1/1       Running   0          5m
drycc-grafana-tm266                       1/1       Running   0          5m
drycc-registry-1814324048-yomz5           1/1       Running   0          5m
drycc-registry-proxy-4m3o4                1/1       Running   0          5m
drycc-registry-proxy-no3r1                1/1       Running   0          5m
drycc-registry-proxy-ou8is                1/1       Running   0          5m
drycc-registry-proxy-zyajl                1/1       Running   0          5m
```

### Step 3: Upgrade the Drycc Client

Users of Drycc Workflow should now upgrade their drycc client to avoid getting `WARNING: Client and server API versions do not match. Please consider upgrading.` warnings.

```
curl -sfL https://www.drycc.cc/install-cli.sh | bash - && sudo mv drycc $(which drycc)
```

[Configuring Object Storage]: ../installing-workflow/configuring-object-storage.md
[Workflow-Migration]: https://github.com/drycc/workflow-migration/blob/main/README.md
