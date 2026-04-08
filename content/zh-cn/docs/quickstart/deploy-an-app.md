---
title: 部署您的第一个应用
description: 使用 drycc cli 部署应用程序。
weight: 4
---

## 确定您的主机和主机名值

Drycc Workflow 需要一个通配符 DNS 记录来动态映射应用名称到路由器。

用户应该已经设置了 DNS 指向他们的已知主机。`$hostname` 值可以通过在 `global.platformDomain` 中设置的值前加上 `drycc.` 来计算。

## 登录到 Workflow

Workflow 使用 passport 组件创建和授权用户。
如果您已经有账户，使用 `drycc login` 对 Drycc Workflow API 进行身份验证。

```
$ drycc login http://drycc.example.com
Opening browser to http://drycc.example.com/v2/login/drycc/?key=4ccc81ee2dce4349ad5261ceffe72c71
Waiting for login... .o.Logged in as admin
Configuration file written to /root/.drycc/client.json
```

或者您可以使用用户名和密码登录
```
$ drycc login http://drycc.example.com --username=demo --password=demo
Configuration file written to /root/.drycc/client.json
```

## 部署应用程序

Drycc Workflow 支持三种不同类型的应用程序，Buildpacks、Dockerfiles 和容器镜像。我们的第一个应用程序将是一个简单的基于容器镜像的应用程序，所以您不必与检出代码搏斗。

运行 `drycc create` 在 Drycc Workflow 上创建一个新应用程序。如果您没有为应用程序指定名称，Workflow 会自动生成一个友好的（有时有趣的）名称。

```
$ drycc create --no-remote
Creating Application... done, created proper-barbecue
If you want to add a git remote for this app later, use `drycc git remote -a proper-barbecue`
```

我们的应用程序已创建并命名为 `proper-barbecue`。与 `drycc` 主机名一样，任何到 `proper-barbecue` 的 HTTP 流量将由边缘路由器自动路由到您的应用程序 pod。

让我们使用 CLI 告诉平台部署应用程序，然后使用 curl 向应用发送请求：

```
$ drycc pull drycc/example-go -a proper-barbecue
Creating build... done
$ curl http://proper-barbecue.$hostname
Powered by Drycc
```

{{% alert title="Note" color="info" %}}
如果您看到 404 错误，请确保使用 `-a <appname>` 指定了您的应用程序名称！
{{% /alert %}}

Workflow 的边缘路由器知道所有关于应用程序名称的信息，并自动将流量发送到正确的应用程序。路由器将 `proper-barbecue.example.drycc.com` 的流量发送到您的应用，就像 `drycc.example.drycc.com` 被发送到 Workflow API 服务一样。

## 更改应用程序配置

接下来，让我们使用 CLI 更改一些配置。我们的示例应用构建为从环境读取配置。通过使用 `drycc config set` 我们可以更改应用程序的行为方式：

```
$ drycc config set POWERED_BY="Container Images + Kubernetes" -a proper-barbecue
Creating config... done
```

在幕后，Workflow 为您的应用程序创建了一个新发布，并使用 Kubernetes 提供零停机滚动部署到新发布！

验证我们的配置更改是否有效：

```
$ curl http://proper-barbecue.example.drycc.com
Powered by Container Images + Kubernetes
```

## 扩展您的应用程序

最后，让我们通过添加更多应用程序进程来扩展我们的应用程序。使用 CLI 您可以轻松添加和删除额外的进程来服务请求：

```
$ drycc scale web=2 -a proper-barbecue
Scaling processes... but first, coffee!
done in 36s

NAME                                RELEASE    STATE    PTYPE       STARTED
proper-barbecue-v18-web-rk644       v18        up       web         2023-12-08T03:09:25UTC
proper-barbecue-v18-web-0ag04       v18        up       web         2023-12-08T03:09:25UTC
```

恭喜！您已使用 Drycc Workflow 部署、配置和扩展了您的第一个应用程序。

## 进一步探索
Drycc Workflow 可以做更多事情，试试 CLI：

{{% alert title="Note" color="danger" %}}
为了有权限推送应用，您必须在 Drycc Workflow 上为您的用户添加 SSH 密钥。
有关更多信息，请查看 [用户和 SSH 密钥](../users/ssh-keys/) 和 [故障排除 Workflow](../troubleshooting/)。
{{% /alert %}}

* 使用 `drycc rollback -a proper-barbecue` 回滚到以前的发布。
* 使用Drycc Grafana查看应用程序日志。
* 尝试我们的其他示例应用程序，如：
    * [drycc/ruby-getting-started](https://github.com/drycc/ruby-getting-started)
    * [drycc/python-getting-started](https://github.com/drycc/python-getting-started)
    * [drycc/php-getting-started](https://github.com/drycc/php-getting-started)
* 阅读关于使用应用程序 [Buildpacks](../applications/using-buildpacks.md) 或 [Dockerfiles](../applications/using-dockerfiles.md)
* 加入我们的 [#community slack channel](https://drycc.slack.com/) 并与团队见面！
