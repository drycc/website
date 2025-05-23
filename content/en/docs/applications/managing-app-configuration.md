---
title: Configuring an Application
linkTitle: Managing App Configuration
description: How to store configuration of a Drycc app in the environment, keeping config out of code, making it easy to maintain app or deployment specific configs.
weight: 6
---


# Configuring an Application

A Drycc application [stores config in environment variables][].


## Setting Environment Variables

Use `drycc config` to modify environment variables for a deployed application.

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

When config is changed, a new release is created and deployed automatically.

You can set multiple environment variables with one `drycc config set` command,
or with `drycc config push` and a local .env file.

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

It can modify environment variables for a process type of application.

    $ drycc config set FOO=1 BAR=baz --ptype=web

It can also modify environment variables for a environment group.

    $ drycc config set FOO1=1 BAR1=baz --group=web.env

Then bind this environment variable group to the web.

    $ drycc config attach web web.env

Of course, you can also detach it.

    $ drycc config detach web web.env

## Attach to Backing Services

Drycc treats backing services like databases, caches and queues as [attached resources][].
Attachments are performed using environment variables.

For example, use `drycc config` to set a `DATABASE_URL` that attaches
the application to an external PostgreSQL database.

    $ drycc config set DATABASE_URL=postgres://user:pass@example.com:5432/db
    === peachy-waxworks
    DATABASE_URL: postgres://user:pass@example.com:5432/db

Detachments can be performed with `drycc config unset`.


## Buildpacks Cache

By default, apps using the [Imagebuilder][] will reuse the latest image data.
When deploying applications that depend on third-party libraries that have to be fetched,
this could speed up deployments a lot. In order to make use of this, the buildpack must implement
the cache by writing to the cache directory. Most buildpacks already implement this, but when using
custom buildpacks, it might need to be changed to make full use of the cache.

### Disabling and re-enabling the cache

In some cases, cache might not speed up your application. To disable caching, you can set the
`DRYCC_DISABLE_CACHE` variable with `drycc config set DRYCC_DISABLE_CACHE=1`. When you disable the
cache, Drycc will clear up files it created to store the cache. After having it turned off, run
`drycc config unset DRYCC_DISABLE_CACHE` to re-enable the cache.

### Clearing the cache

Use the following procedure to clear the cache:

    $ drycc config set DRYCC_DISABLE_CACHE=1
    $ git commit --allow-empty -m "Clearing Drycc cache"
    $ git push drycc # (if you use a different remote, you should use your remote name)
    $ drycc config unset DRYCC_DISABLE_CACHE


## Custom Health Checks

By default, Workflow only checks that the application starts in their Container. A health
check may be added by configuring a health check probe for the application. The health
checks are implemented as Kubernetes Container Probes. A 'startupProbe' 'livenessProbe' 
and a 'readinessProbe' can be configured, and each probe can be of type 'httpGet', 'exec' 
or 'tcpSocket' depending on the type of probe the Container requires.

A 'startupProbe' indicates whether the application within the container is started.
All other probes are disabled if a startup probe is provided, until it succeeds.
If the startup probe fails, the container is subjected to its restart policy.

A 'livenessProbe' is useful for applications running for long periods of time, eventually
transitioning to broken states and cannot recover except by restarting them.

Other times, a 'readinessProbe' is useful when the Container is only temporarily unable
to serve, and will recover on its own. In this case, if a Container fails its 'readinessProbe'
, the Container will not be shut down, but rather the Container will stop receiving
incoming requests.

'httpGet' probes are just as it sounds: it performs a HTTP GET operation on the Container.
A response code inside the 200-399 range is considered a pass. 'httpGet' probes accept a
port number to perform the HTTP GET operation on the Container.

'exec' probes run a command inside the Container to determine its health. An exit code of
zero is considered a pass, while a non-zero status code is considered a fail. 'exec'
probes accept a string of arguments to be run inside the Container.

'tcpSocket' probes attempt to open a socket in the Container. The Container is only
considered healthy if the check can establish a connection. 'tcpSocket' probes accept a
port number to perform the socket connection on the Container.

Health checks can be configured on a per-proctype basis for each application using `drycc healthchecks set`. If no type is mentioned then the health checks are applied to default proc type web, whichever is present. To
configure a `httpGet` liveness probe:

```
$ drycc healthchecks set livenessProbe httpGet 80 --ptype web
Applying livenessProbe healthcheck... done

App:             peachy-waxworks
UUID:            afd84067-29e9-4a5f-9f3a-60d91e938812
Owner:           dev
Created:         2023-12-08T10:25:00Z
Updated:         2023-12-08T10:25:00Z
Healthchecks:
                 livenessProbe web http-get headers=[] path=/ port=80 delay=50s timeout=50s period=10s #success=1 #failure=3
```

If the application relies on certain headers being set (such as the `Host` header) or a specific
URL path relative to the root, you can also send specific HTTP headers:

```
$ drycc healthchecks set livenessProbe httpGet 80 \
    --path /welcome/index.html \
    --headers "X-Client-Version:v1.0,X-Foo:bar"
Applying livenessProbe healthcheck... done

App:             peachy-waxworks
UUID:            afd84067-29e9-4a5f-9f3a-60d91e938812
Owner:           dev
Created:         2023-12-08T10:25:00Z
Updated:         2023-12-08T10:25:00Z
Healthchecks:
                 livenessProbe web http-get headers=[X-Client-Version=v1.0] path=/welcome/index.html port=80 delay=50s timeout=50s period=10s #success=1 #failure=3
```

To configure an `exec` readiness probe:

```
$ drycc healthchecks set readinessProbe exec -- /bin/echo -n hello --ptype web
Applying readinessProbe healthcheck... done

App:             peachy-waxworks
UUID:            afd84067-29e9-4a5f-9f3a-60d91e938812
Owner:           dev
Created:         2023-12-08T10:25:00Z
Updated:         2023-12-08T10:25:00Z
Healthchecks:
                 readinessProbe web exec /bin/echo -n hello delay=50s timeout=50s period=10s #success=1 #failure=3
```

You can overwrite a probe by running `drycc healthchecks set` again:

```
$ drycc healthchecks set readinessProbe httpGet 80 --ptype web
Applying livenessProbe healthcheck... done

App:             peachy-waxworks
UUID:            afd84067-29e9-4a5f-9f3a-60d91e938812
Owner:           dev
Created:         2023-12-08T10:25:00Z
Updated:         2023-12-08T10:25:00Z
Healthchecks:
                 livenessProbe web http-get headers=[] path=/ port=80 delay=50s timeout=50s period=10s #success=1 #failure=3
```

Configured health checks also modify the default application deploy behavior. When starting a new
Pod, Workflow will wait for the health check to pass before moving onto the next Pod.


## Autodeploy
By default, Changes the config, limits or healthchecks and so on will trigger deploy.
If you don't want deploy, you can disable.

```
$ drycc autodeploy disable
```

To re-enable autodeploy.
```
drycc autodeploy enable
```

you can deploy by executing the following command.
deploy all ptypes
```
drycc releases deploy

```
deploy web process type, and support `--force` option to force deploy.
```
drycc releases deploy web --force
```

## Autorollback
By default, deployment failures will roll back to the previous successful version.
If you don't want this to happen, you can disable.

```
$ drycc autorollback disable
```

To re-enable autorollback.
```
drycc autorollback enable
```


## Isolate the Application

Workflow supports isolating applications onto a set of nodes using `drycc tags`.

!!! note
    In order to use tags, you must first launch your cluster with the proper node labels. If you do
    not, tag commands will fail. Learn more by reading ["Assigning Pods to Nodes"][pods-to-nodes].

Once your nodes are configured with appropriate label selectors, use `drycc tags set` to restrict
the application ptype to those nodes:

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
