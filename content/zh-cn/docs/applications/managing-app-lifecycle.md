---
title: 管理应用
linkTitle: 管理应用生命周期
description: 这是 Drycc 工作方式的高级技术描述。它将您在 Drycc 平台上编写、配置、部署和运行应用时遇到的许多概念联系在一起。
weight: 7
---

## 跟踪应用更改

Drycc Workflow 跟踪对您的应用的所有更改。应用更改是新应用代码推送到平台（通过 `git push drycc master`）或应用配置更新（通过 `drycc config:set KEY=VAL`）的结果。

每次对您的应用进行构建或配置更改时，都会创建一个新的 [release][]。这些发布编号单调递增。

您可以使用 `drycc releases` 查看对您的应用的更改记录：

```
$ drycc releases
OWNER    STATE      VERSION    CREATED                 SUMMARY
dev      succeed    v3         2023-12-04T10:17:46Z    dev deleted PIP_INDEX_URL, DISABLE_COLLECTSTATIC
dev      succeed    v2         2023-12-01T10:20:22Z    dev added IMAGE_PULL_POLICY, PIP_INDEX_URL, PORT, DISABLE_COLLEC[...]
dev      succeed    v1         2023-11-30T17:54:57Z    dev created initial release
```

## 回滚发布

Drycc Workflow 还支持回滚到以前的发布。如果有问题的代码或错误的配置更改被推送到您的应用，您可以回滚到以前已知良好的发布。

{{% alert title="Note" color="info" %}}
所有回滚都会创建一个新的编号发布。但将引用所需回滚点的构建/代码和配置。
{{% /alert %}}


在此示例中，应用当前运行发布 v4。使用 `drycc rollback v2` 告诉 Workflow 部署用于发布 v2 的构建和配置。这创建一个名为 v5 的新发布，其内容是发布 v2 的源代码和配置：

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

仅回滚 web 进程类型：
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

## 运行一次性管理任务

Drycc 应用 [使用一次性进程进行管理任务][] 如数据库迁移和其他必须针对实时应用运行的命令。

使用 `drycc run` 在部署的应用上执行命令。

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


## 使用 Workspace 管理访问


应用协作现在通过 Workspace 进行管理，而不是应用级别的权限。
使用 `drycc workspaces invite` 将用户添加到工作区，使用 `drycc workspaces remove` 撤销访问。

```
$ drycc workspaces invite my-workspace user@example.com
Inviting user@example.com to my-workspace... done
```

使用 `drycc workspaces update` 修改成员的角色或提醒设置，使用 `drycc workspaces info` 检查工作区成员和权限。

要在工作区之间移动应用，请使用 `drycc apps transfer`：

```
$ drycc apps transfer peachy-waxworks target-workspace
Transferring peachy-waxworks to target-workspace... done
```

{{% alert title="Note" color="info" %}}
Workspace 成员的访问权限由其角色决定，而不是通过应用级别的共享关系。应用转移会将应用重新分配到另一个工作区。
{{% /alert %}}

在使用与您共享的应用时，克隆原始存储库并在尝试 `git push` 任何更改到 Drycc 之前添加 Drycc 的 git 远程条目。

```
$ git clone https://github.com/drycc/example-java-jetty.git
Cloning into 'example-java-jetty'... done
$ cd example-java-jetty
$ git remote add -f drycc ssh://git@local3.dryccapp.com:2222/peachy-waxworks.git
Updating drycc
From drycc-controller.local:peachy-waxworks
 * [new branch]      master     -> drycc/master
```

## 应用故障排除

部署在 Drycc Workflow 上的应用 [将日志视为事件流][]。Drycc Workflow 聚合每个 [Container][] 的 `stdout` 和 `stderr`，使排除应用问题变得容易。

使用Drycc Grafana查看部署应用的日志输出。

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
