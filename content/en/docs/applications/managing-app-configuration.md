---
title: Configuring an Application
linkTitle: Managing App Configuration
description: Store application configuration in environment variables to keep config separate from code.
weight: 6
---

# Configuring an Application

Drycc applications [store configuration in environment variables][] to separate config from code and simplify environment-specific settings.

## Setting Environment Variables

Use `drycc config` to manage environment variables for deployed applications.

    $ drycc help config
    Manage environment variables that define app config

    Usage:
    drycc config [flags]
    drycc config [command]

    Available Commands:
    info        An app config info
    set         Set environment variables for an app
    unset       Unset environment variables for an app
    pull        Pull environment variables to the path
    push        Push environment variables from the path
    attach      Selects environment groups to attach an app ptype
    detach      Selects environment groups to detach an app ptype

    Flags:
    -a, --app string     The uniquely identifiable name for the application
    -g, --group string   The group for which the config needs to be listed
    -p, --ptype string   The ptype for which the config needs to be listed
    -v, --version int    The version for which the config needs to be listed

    Global Flags:
    -c, --config string   Path to configuration file. (default "~/.drycc/client.json")
    -h, --help            Display help information

    Use "drycc config [command] --help" for more information about a command.

Configuration changes trigger automatic deployment of a new release.

Set multiple environment variables in one command or use `drycc config push` with a local .env file:

    $ drycc config set FOO=1 BAR=baz && drycc config pull
    $ cat .env
    FOO=1
    BAR=baz
    $ echo "TIDE=high" >> .env
    $ drycc config push
    Creating config... done, v4

    === yuppie-earthman
    DRYCC_APP: yuppie-earthman
    FOO: 1
    BAR: baz
    TIDE: high

Set environment variables for specific process types:

    $ drycc config set FOO=1 BAR=baz --ptype=web

Or manage environment variable groups:

    $ drycc config set FOO1=1 BAR1=baz --group=web.env

Attach the group to the web process type:

    $ drycc config attach web web.env

Detach the group:

    $ drycc config detach web web.env

## Attach to Backing Services

Drycc treats backing services like databases, caches, and queues as [attached resources][]. Configure connections using environment variables.

For example, attach an application to an external PostgreSQL database:

    $ drycc config set DATABASE_URL=postgres://user:pass@example.com:5432/db
    === peachy-waxworks
    DATABASE_URL: postgres://user:pass@example.com:5432/db

Remove attachments using `drycc config unset`.


## Buildpacks Cache

Applications using [Imagebuilder][] reuse the latest image data by default. This speeds up deployments for applications that fetch third-party libraries. Buildpacks must implement caching by writing to the cache directory.

### Disable and Re-enable Cache

Disable caching by setting `DRYCC_DISABLE_CACHE=1`. Drycc clears cache files when disabled. Re-enable by unsetting the variable.

### Clear Cache

Clear the cache using this procedure:

    $ drycc config set DRYCC_DISABLE_CACHE=1
    $ git commit --allow-empty -m "Clearing Drycc cache"
    $ git push drycc # (use your remote name if different)
    $ drycc config unset DRYCC_DISABLE_CACHE


## Custom Health Checks

By default, Workflow verifies that applications start in their containers. Add health checks by configuring probes for the application. Health checks use Kubernetes Container Probes with three types: `startup_probe`, `liveness_probe`, and `readiness_probe`. Each probe supports `http_get`, `exec`, or `tcp_socket` checks.

### Probe Types

- **startup_probe**: Indicates whether the application has started. Disables other probes until successful. Failure triggers restart policy.

- **liveness_probe**: Useful for long-running applications that may break and need restarting.

- **readiness_probe**: Useful when containers temporarily cannot serve requests but will recover. Failed containers stop receiving traffic but don't restart.

### Check Types

- **http_get**: Performs HTTP GET on the container. Response codes 200-399 pass. Specify port number.

- **exec**: Runs a command in the container. Exit code 0 passes, non-zero fails. Provide command arguments.

- **tcp_socket**: Attempts to open a socket connection. Container is healthy if connection succeeds. Specify port number.

Configure health checks per process type using `drycc healthchecks set`. Defaults to `web` process type if not specified.

Configure an HTTP GET liveness probe:

```
$ drycc healthchecks set liveness_probe http_get 80 --ptype web
Applying liveness_probe healthcheck... done

App:             peachy-waxworks
UUID:            afd84067-29e9-4a5f-9f3a-60d91e938812
Owner:           dev
Created:         2023-12-08T10:25:00Z
Updated:         2023-12-08T10:25:00Z
Healthchecks:
                 liveness_probe web http_get headers=[] path=/ port=80 delay=50s timeout=50s period=10s #success=1 #failure=3
```

Include specific headers or paths:

```
$ drycc healthchecks set liveness_probe http_get 80 \
    --path /welcome/index.html \
    --headers "X-Client-Version:v1.0,X-Foo:bar"
Applying liveness_probe healthcheck... done

App:             peachy-waxworks
UUID:            afd84067-29e9-4a5f-9f3a-60d91e938812
Owner:           dev
Created:         2023-12-08T10:25:00Z
Updated:         2023-12-08T10:25:00Z
Healthchecks:
                 liveness_probe web http_get headers=[X-Client-Version=v1.0] path=/welcome/index.html port=80 delay=50s timeout=50s period=10s #success=1 #failure=3
```

Configure an exec readiness probe:

```
$ drycc healthchecks set readiness_probe exec -- /bin/echo -n hello --ptype web
Applying readiness_probe healthcheck... done

App:             peachy-waxworks
UUID:            afd84067-29e9-4a5f-9f3a-60d91e938812
Owner:           dev
Created:         2023-12-08T10:25:00Z
Updated:         2023-12-08T10:25:00Z
Healthchecks:
                 readiness_probe web exec /bin/echo -n hello delay=50s timeout=50s period=10s #success=1 #failure=3
```

Overwrite probes by running `drycc healthchecks set` again. Health checks modify deployment behavior - Workflow waits for checks to pass before proceeding to the next pod.


## Autodeploy

By default, configuration, limits, and health check changes trigger automatic deployment. Disable autodeploy to prevent automatic deployments:

```
$ drycc autodeploy disable
```

Re-enable autodeploy:

```
$ drycc autodeploy enable
```

Manually deploy all process types:

```
$ drycc releases deploy
```

Deploy specific process types with optional force flag:

```
$ drycc releases deploy web --force
```

## Autorollback

By default, deployment failures automatically rollback to the previous successful version. Disable autorollback:

```
$ drycc autorollback disable
```

Re-enable autorollback:

```
$ drycc autorollback enable
```

## Isolate Applications

Isolate applications to specific nodes using `drycc tags`.

{{% alert title="Note" color="info" %}}
Configure your cluster with proper node labels before using tags. Commands will fail without labels. Learn more: ["Assigning Pods to Nodes"][pods-to-nodes].
{{% /alert %}}

Once nodes have appropriate labels, restrict application process types to those nodes:

```
$ drycc tags set web environ=prod
Applying tags...  done, v4

environ  prod
```


[attached resources]: http://12factor.net/backing-services
[kubernetes-probes]: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
[pods-to-nodes]: http://kubernetes.io/docs/user-guide/node-selection/
[release]: ../reference-guide/terms.md#release
[router]:  ../understanding-workflow/components.md#router
[Slugbuilder]: ../understanding-workflow/components.md#builder-builder-slugbuilder-and-imagebuilder
[stores config in environment variables]: http://12factor.net/config
