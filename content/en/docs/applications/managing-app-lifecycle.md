---
title: Managing App Lifecycle
linkTitle: Managing App Lifecycle
description: Learn how to track changes, rollback releases, run administrative tasks, and troubleshoot Drycc applications throughout their lifecycle.
weight: 7
---

## Track Application Changes

Drycc Workflow tracks all changes to your application. Application changes result from either new application code pushed to the platform (via `git push drycc master`), or updates to application configuration (via `drycc config:set KEY=VAL`).

Each time a build or configuration change is made to your application, a new [release][] is created. These release numbers increase monotonically.

You can see a record of changes to your application using `drycc releases`:

```
$ drycc releases
OWNER    STATE      VERSION    CREATED                 SUMMARY
dev      succeed    v3         2023-12-04T10:17:46Z    dev deleted PIP_INDEX_URL, DISABLE_COLLECTSTATIC
dev      succeed    v2         2023-12-01T10:20:22Z    dev added IMAGE_PULL_POLICY, PIP_INDEX_URL, PORT, DISABLE_COLLEC[...]
dev      succeed    v1         2023-11-30T17:54:57Z    dev created initial release
```

## Rollback a Release

Drycc Workflow supports rolling back to previous releases. If buggy code or an errant configuration change is pushed to your application, you may rollback to a previously known good release.

{{% alert title="Note" color="info" %}}
All rollbacks create a new, numbered release but reference the build/code and configuration from the desired rollback point.
{{% /alert %}}

In this example, the application is currently running release v4. Using `drycc rollback v2` tells Workflow to deploy the build and configuration that was used for release v2. This creates a new release named v5 whose contents are the source and configuration from release v2:

```
$ drycc releases
OWNER    STATE      VERSION    CREATED                 SUMMARY
dev      succeed    v3         2023-12-04T10:17:46Z    dev deleted PIP_INDEX_URL, DISABLE_COLLECTSTATIC
dev      succeed    v2         2023-12-01T10:20:22Z    dev added IMAGE_PULL_POLICY, PIP_INDEX_URL, PORT, DISABLE_COLLEC[...]
dev      succeed    v1         2023-11-30T17:54:57Z    dev created initial release

$ drycc rollback v2
Rolled back to v2

$ drycc releases
OWNER    STATE      VERSION    CREATED                 SUMMARY
dev      succeed    v4         2023-12-04T10:20:46Z    dev rolled back to v2
dev      succeed    v3         2023-12-04T10:17:46Z    dev deleted PIP_INDEX_URL, DISABLE_COLLECTSTATIC
dev      succeed    v2         2023-12-01T10:20:22Z    dev added IMAGE_PULL_POLICY, PIP_INDEX_URL, PORT, DISABLE_COLLEC[...]
dev      succeed    v1         2023-11-30T17:54:57Z    dev created initial release
```

To rollback only the web process type:

```
$ drycc rollback v3 web
Rolled back to v3

$ drycc releases
OWNER    STATE      VERSION    CREATED                 SUMMARY
dev      succeed    v5         2023-12-04T10:23:49Z    dev rolled back to v3
dev      succeed    v4         2023-12-04T10:20:46Z    dev rolled back to v2
dev      succeed    v3         2023-12-04T10:17:46Z    dev deleted PIP_INDEX_URL, DISABLE_COLLECTSTATIC
dev      succeed    v2         2023-12-01T10:20:22Z    dev added IMAGE_PULL_POLICY, PIP_INDEX_URL, PORT, DISABLE_COLLEC[...]
dev      succeed    v1         2023-11-30T17:54:57Z    dev created initial release
```

## Run One-off Administration Tasks

Drycc applications [use one-off processes for admin tasks][] like database migrations and other commands that must run against the live application.

Use `drycc run` to execute commands on the deployed application:

    $ drycc run -- 'ls -l'
    Running `ls -l`...

    total 28
    -rw-r--r-- 1 root root  553 Dec  2 23:59 LICENSE
    -rw-r--r-- 1 root root   60 Dec  2 23:59 Procfile
    -rw-r--r-- 1 root root   33 Dec  2 23:59 README.md
    -rw-r--r-- 1 root root 1622 Dec  2 23:59 pom.xml
    -rw-r--r-- 1 root root   25 Dec  2 23:59 system.properties
    drwxr-xr-x 3 root root 4096 Dec  2 23:59 src
    -rw-r--r-- 1 root root   25 Dec  2 23:59 system.properties
    drwxr-xr-x 6 root root 4096 Dec  3 00:00 target

## Manage access with Workspaces

Application collaboration is now managed through workspaces instead of app-level permissions.
Use `drycc workspaces invite` to add users to a workspace, and `drycc workspaces remove` to revoke access.

```
$ drycc workspaces invite my-workspace user@example.com
Inviting user@example.com to my-workspace... done
```

Use `drycc workspaces update` to change a member's role or alert settings, and `drycc workspaces info` to inspect workspace membership and permissions.

To move an app between workspaces, use `drycc apps transfer`:

```
$ drycc apps transfer peachy-waxworks target-workspace
Transferring peachy-waxworks to target-workspace... done
```

{{% alert title="Note" color="info" %}}
Workspace members are granted access according to their role, not via an app-level owner share. App transfer reassigns the application to another workspace.
{{% /alert %}}

When working with an application that has been shared with you, clone the original repository and add Drycc's git remote entry before attempting to `git push` any changes to Drycc:

```
$ git clone https://github.com/drycc/example-java-jetty.git
Cloning into 'example-java-jetty'... done
$ cd example-java-jetty
$ git remote add -f drycc ssh://git@local3.dryccapp.com:2222/peachy-waxworks.git
Updating drycc
From drycc-controller.local:peachy-waxworks
 * [new branch]      master     -> drycc/master
```

## Application Troubleshooting

Applications deployed on Drycc Workflow [treat logs as event streams][]. Drycc Workflow aggregates `stdout` and `stderr` from every [Container][] making it easy to troubleshoot problems with your application.

Use `drycc grafana` to view the log output from your deployed application:

    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.5]: INFO:oejsh.ContextHandler:started o.e.j.s.ServletContextHandler{/,null}
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.8]: INFO:oejs.Server:jetty-7.6.0.v20120127
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.5]: INFO:oejs.AbstractConnector:Started SelectChannelConnector@0.0.0.0:10005
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.6]: INFO:oejsh.ContextHandler:started o.e.j.s.ServletContextHandler{/,null}
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.7]: INFO:oejsh.ContextHandler:started o.e.j.s.ServletContextHandler{/,null}
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.6]: INFO:oejs.AbstractConnector:Started SelectChannelConnector@0.0.0.0:10006
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.7]: INFO:oejs.AbstractConnector:Started SelectChannelConnector@0.0.0.0:10007
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.8]: INFO:oejs.AbstractConnector:Started SelectChannelConnector@0.0.0.0:10008

[application]: ../reference-guide/terms.md#application
[container]: ../reference-guide/terms.md#container
[release]: ../reference-guide/terms.md#release
[store config in environment variables]: http://12factor.net/config
[decoupled from the application]: http://12factor.net/backing-services
[scale out via the process model]: http://12factor.net/concurrency
[treat logs as event streams]: http://12factor.net/logs
[use one-off processes for admin tasks]: http://12factor.net/admin-processes
[Procfile]: http://ddollar.github.io/foreman/#PROCFILE
[router]: ../understanding-workflow/components.md#router

## Rollback a Release

Drycc Workflow also supports rolling back go previous releases. If buggy code or an errant configuration change is pushed
to your application, you may rollback to a previously known, good release.

{{% alert title="Note" color="info" %}}
All rollbacks create a new, numbered release. But will reference the build/code and configuration from the desired rollback point.
{{% /alert %}}


In this example, the application is currently running release v4. Using `drycc rollback v2` tells Workflow to deploy the
build and configuration that was used for release v2. This creates a new release named v5 whose contents are the source
and configuration from release v2:

```
$ drycc releases
OWNER    STATE      VERSION    CREATED                 SUMMARY
dev      succeed    v3         2023-12-04T10:17:46Z    dev deleted PIP_INDEX_URL, DISABLE_COLLECTSTATIC
dev      succeed    v2         2023-12-01T10:20:22Z    dev added IMAGE_PULL_POLICY, PIP_INDEX_URL, PORT, DISABLE_COLLEC[...]
dev      succeed    v1         2023-11-30T17:54:57Z    dev created initial release

$ drycc rollback v2
Rolled back to v2

$ drycc releases
OWNER    STATE      VERSION    CREATED                 SUMMARY
dev      succeed    v4         2023-12-04T10:20:46Z    dev rolled back to v2
dev      succeed    v3         2023-12-04T10:17:46Z    dev deleted PIP_INDEX_URL, DISABLE_COLLECTSTATIC
dev      succeed    v2         2023-12-01T10:20:22Z    dev added IMAGE_PULL_POLICY, PIP_INDEX_URL, PORT, DISABLE_COLLEC[...]
dev      succeed    v1         2023-11-30T17:54:57Z    dev created initial release
```

Only rollback web process type:
```
$ drycc rollback v3 web
Rolled back to v3

$ drycc releases
OWNER    STATE      VERSION    CREATED                 SUMMARY
dev      succeed    v5         2023-12-04T10:23:49Z    dev rolled back to v3
dev      succeed    v4         2023-12-04T10:20:46Z    dev rolled back to v2
dev      succeed    v3         2023-12-04T10:17:46Z    dev deleted PIP_INDEX_URL, DISABLE_COLLECTSTATIC
dev      succeed    v2         2023-12-01T10:20:22Z    dev added IMAGE_PULL_POLICY, PIP_INDEX_URL, PORT, DISABLE_COLLEC[...]
dev      succeed    v1         2023-11-30T17:54:57Z    dev created initial release
```

## Run One-off Administration Tasks

Drycc applications [use one-off processes for admin tasks][] like database migrations and other commands that must run against the live application.

Use `drycc run` to execute commands on the deployed application.

    $ drycc run -- 'ls -l'
    Running `ls -l`...

    total 28
    -rw-r--r-- 1 root root  553 Dec  2 23:59 LICENSE
    -rw-r--r-- 1 root root   60 Dec  2 23:59 Procfile
    -rw-r--r-- 1 root root   33 Dec  2 23:59 README.md
    -rw-r--r-- 1 root root 1622 Dec  2 23:59 pom.xml
    drwxr-xr-x 3 root root 4096 Dec  2 23:59 src
    -rw-r--r-- 1 root root   25 Dec  2 23:59 system.properties
    drwxr-xr-x 6 root root 4096 Dec  3 00:00 target


## Manage access with Workspaces


Application collaboration is now managed through workspaces instead of app-level permissions.
Use `drycc workspaces invite` to add users to a workspace, and `drycc workspaces remove` to revoke access.

```
$ drycc workspaces invite my-workspace user@example.com
Inviting user@example.com to my-workspace... done
```

Use `drycc workspaces update` to change a member's role or alert settings, and `drycc workspaces info` to inspect workspace membership and permissions.

To move an app between workspaces, use `drycc apps transfer`:

```
$ drycc apps transfer peachy-waxworks target-workspace
Transferring peachy-waxworks to target-workspace... done
```

{{% alert title="Note" color="info" %}}
Workspace members are granted access according to their role, not via an app-level owner share. App transfer reassigns the application to another workspace.
{{% /alert %}}

When working with an application that has been shared with you, clone the original repository and add Drycc' git remote
entry before attempting to `git push` any changes to Drycc.

```
$ git clone https://github.com/drycc/example-java-jetty.git
Cloning into 'example-java-jetty'... done
$ cd example-java-jetty
$ git remote add -f drycc ssh://git@local3.dryccapp.com:2222/peachy-waxworks.git
Updating drycc
From drycc-controller.local:peachy-waxworks
 * [new branch]      master     -> drycc/master
```

## Application Troubleshooting

Applications deployed on Drycc Workflow [treat logs as event streams][]. Drycc Workflow aggregates `stdout` and `stderr`
from every [Container][] making it easy to troubleshoot problems with your application.

Use drycc grafana to view the log output from your deployed application.

    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.5]: INFO:oejsh.ContextHandler:started o.e.j.s.ServletContextHandler{/,null}
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.8]: INFO:oejs.Server:jetty-7.6.0.v20120127
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.5]: INFO:oejs.AbstractConnector:Started SelectChannelConnector@0.0.0.0:10005
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.6]: INFO:oejsh.ContextHandler:started o.e.j.s.ServletContextHandler{/,null}
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.7]: INFO:oejsh.ContextHandler:started o.e.j.s.ServletContextHandler{/,null}
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.6]: INFO:oejs.AbstractConnector:Started SelectChannelConnector@0.0.0.0:10006
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.8]: INFO:oejsh.ContextHandler:started o.e.j.s.ServletContextHandler{/,null}
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.7]: INFO:oejs.AbstractConnector:Started SelectChannelConnector@0.0.0.0:10007
    Dec  3 00:30:31 ip-10-250-15-201 peachy-waxworks[web.8]: INFO:oejs.AbstractConnector:Started SelectChannelConnector@0.0.0.0:10008

[application]: ../reference-guide/terms.md#application
[container]: ../reference-guide/terms.md#container
[release]: ../reference-guide/terms.md#release
[store config in environment variables]: http://12factor.net/config
[decoupled from the application]: http://12factor.net/backing-services
[scale out via the process model]: http://12factor.net/concurrency
[treat logs as event streams]: http://12factor.net/logs
[use one-off processes for admin tasks]: http://12factor.net/admin-processes
[Procfile]: http://ddollar.github.io/foreman/#PROCFILE
[router]: ../understanding-workflow/components.md#router
