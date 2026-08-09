---
title: 配置应用程序
linkTitle: 管理应用配置
description: 如何在环境中存储 Drycc 应用的配置，将配置与代码分离，使其易于维护应用或部署特定的配置。
weight: 6
---


# 配置应用程序

Drycc 应用程序[将配置存储在环境变量中][]。


## 设置环境变量

使用 `drycc config` 修改已部署应用程序的环境变量。

    $ drycc help config
    管理定义应用配置的环境变量

    用法：
    drycc config [flags]
    drycc config [command]

    可用命令：
    info        应用配置信息
    set         为应用设置环境变量
    unset       取消设置应用的环境变量
    pull        将环境变量拉取到路径
    push        从路径推送环境变量
    attach      选择要附加到应用 ptype 的环境组
    detach      选择要从应用 ptype 分离的环境组

    标志：
    -a, --app string     应用程序的唯一可识别名称
    -g, --group string   需要列出配置的组
    -p, --ptype string   需要列出配置的 ptype
    -v, --version int    需要列出配置的版本

    全局标志：
    -c, --config string   配置文件路径。（默认 "~/.drycc/client.json"）
    -h, --help            显示帮助信息

    使用 "drycc config [command] --help" 获取有关命令的更多信息。

当配置更改时，会自动创建并部署新版本。

您可以使用一个 `drycc config set` 命令设置多个环境变量，
或者使用 `drycc config push` 和本地 .env 文件。

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

它可以修改应用程序进程类型的环境变量。

    $ drycc config set FOO=1 BAR=baz --ptype=web

它还可以修改环境组的环境变量。

    $ drycc config set FOO1=1 BAR1=baz --group=web.env

然后将此环境变量组绑定到 web。

    $ drycc config attach web web.env

当然，您也可以分离它。

    $ drycc config detach web web.env

## 附加到后端服务

Drycc 将数据库、缓存和队列等后端服务视为[附加资源][]。
附加使用环境变量执行。

例如，使用 `drycc config` 设置 `DATABASE_URL`，将
应用程序附加到外部 PostgreSQL 数据库。

    $ drycc config set DATABASE_URL=postgres://user:pass@example.com:5432/db
    === peachy-waxworks
    DATABASE_URL: postgres://user:pass@example.com:5432/db

可以使用 `drycc config unset` 执行分离。


## Buildpacks 缓存

默认情况下，使用 [Imagebuilder][] 的应用将重用最新的镜像数据。
在部署依赖于必须获取的第三方库的应用程序时，
这可以大大加快部署速度。为了利用这一点，buildpack 必须通过写入缓存目录来实现
缓存。大多数 buildpack 已经实现了这一点，但在使用
自定义 buildpack 时，可能需要更改以充分利用缓存。

### 禁用和重新启用缓存

在某些情况下，缓存可能不会加快您的应用程序速度。要禁用缓存，您可以使用 `drycc config set DRYCC_DISABLE_CACHE=1` 设置
`DRYCC_DISABLE_CACHE` 变量。当您禁用缓存时，Drycc 将清除它创建的用于存储缓存的文件。关闭后，运行
`drycc config unset DRYCC_DISABLE_CACHE` 来重新启用缓存。

### 清除缓存

使用以下过程清除缓存：

    $ drycc config set DRYCC_DISABLE_CACHE=1
    $ git commit --allow-empty -m "Clearing Drycc cache"
    $ git push drycc # (如果您使用不同的远程仓库，您应该使用您的远程仓库名称)
    $ drycc config unset DRYCC_DISABLE_CACHE


## 自定义健康检查

默认情况下，Workflow 仅检查应用程序是否在其容器中启动。可以为应用程序配置健康检查探针来添加健康检查。健康检查作为 Kubernetes 容器探针实现。可以配置 'startup_probe' 'liveness_probe' 和 'readiness_probe'，每个探针可以是 'http_get'、'exec' 或 'tcp_socket' 类型，具体取决于容器所需的探针类型。

'startup_probe' 指示容器内的应用程序是否已启动。
如果提供了启动探针，则所有其他探针都被禁用，直到它成功。
如果启动探针失败，容器将受到其重启策略的影响。

'liveness_probe' 对于长时间运行的应用程序很有用，最终
会过渡到损坏状态，除非通过重启它们，否则无法恢复。

其他时候，'readiness_probe' 很有用，当容器只是暂时无法
服务，并且会自行恢复。在这种情况下，如果容器未能通过 'readiness_probe'，
容器不会被关闭，而是容器将停止接收
传入请求。

'http_get' 探针正如其名称：它在容器上执行 HTTP GET 操作。
200-399 范围内的响应代码被视为通过。'http_get' 探针接受一个
端口号，以便在容器上执行 HTTP GET 操作。

'exec' 探针在容器内运行命令来确定其健康状况。退出代码为
零被视为通过，而非零状态代码被视为失败。'exec'
探针接受要在容器内运行的参数字符串。

'tcp_socket' 探针尝试在容器中打开套接字。只有当检查可以建立连接时，容器才被视为健康。'tcp_socket' 探针接受一个
端口号，以便在容器上执行套接字连接。

可以使用 `drycc healthchecks set` 为每个应用程序的每个 proctype 配置健康检查。如果未提及类型，则健康检查将应用于默认进程类型 web（无论存在哪个）。要
配置 `http_get` liveness 探针：

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

If the application relies on certain headers being set (such as the `Host` header) or a specific
URL path relative to the root, you can also send specific HTTP headers:

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

To configure an `exec` readiness probe:

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

You can overwrite a probe by running `drycc healthchecks set` again:

```
$ drycc healthchecks set readiness_probe http_get 80 --ptype web
Applying liveness_probe healthcheck... done

App:             peachy-waxworks
UUID:            afd84067-29e9-4a5f-9f3a-60d91e938812
Owner:           dev
Created:         2023-12-08T10:25:00Z
Updated:         2023-12-08T10:25:00Z
Healthchecks:
                 liveness_probe web http_get headers=[] path=/ port=80 delay=50s timeout=50s period=10s #success=1 #failure=3
```

Configured health checks also modify the default application deploy behavior. When starting a new
Pod, Workflow will wait for the health check to pass before moving onto the next Pod.


## 自动部署
默认情况下，更改配置、限制或健康检查等将触发部署。
如果您不想部署，可以禁用。

```
$ drycc autodeploy disable
```

要重新启用自动部署。
```
drycc autodeploy enable
```

您可以通过执行以下命令进行部署。
部署所有 ptype
```
drycc releases deploy

```
部署 web 进程类型，并支持 `--force` 选项强制部署。
```
drycc releases deploy web --force
```

## 自动回滚
默认情况下，部署失败将回滚到之前的成功版本。
如果您不想发生这种情况，可以禁用。

```
$ drycc autorollback disable
```

要重新启用自动回滚。
```
drycc autorollback enable
```

## 隔离应用程序

Workflow 支持使用 `drycc tags` 将应用程序隔离到一组节点上。

{{% alert title="Note" color="info" %}}
为了使用标签，您必须首先使用适当的节点标签启动集群。如果您没有这样做，标签命令将失败。通过阅读["将 Pod 分配给节点"][pods-to-nodes]了解更多。
{{% /alert %}}

一旦您的节点配置了适当的标签选择器，使用 `drycc tags set` 将应用程序 ptype 限制到这些节点：

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
