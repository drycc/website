---
title: Drycc Workflow CLI
linkTitle: 命令行界面
description: 如何下载、安装和开始使用 Drycc CLI。Drycc CLI 曾经是 Drycc Toolbelt 的一部分。
weight: 1
---

Drycc Workflow 命令行界面 (CLI) 或客户端允许您与 Drycc Workflow 进行交互。

## 安装

使用以下命令为 Linux 或 Mac OS X 安装最新的 `drycc` 客户端：
    $ curl -sfL https://www.drycc.cc/install-cli.sh | bash -

安装程序将 `drycc` 放在当前目录中，但您应该将其移动到 $PATH 中的某个位置：

    $ ln -fs $PWD/drycc /usr/local/bin/drycc

## 获取帮助

Drycc 客户端为每个命令提供了全面的文档。使用 `drycc help` 来探索可用的命令：

    $ drycc help
    The Drycc command-line client issues API calls to a Drycc controller.

    Usage: drycc <command> [<args>...]

    Auth commands::

      login         login to a controller
      logout        logout from the current controller

    Subcommands, use `drycc help [subcommand]` to learn more::
    ...

要获取子命令的帮助，请使用 `drycc help [subcommand]`：

    $ drycc help apps
    Valid commands for apps:

    apps:create        create a new application
    apps:list          list accessible applications
    apps:info          view info about an application
    apps:open          open the application in a browser
    apps:logs          view aggregated application logs
    apps:run           run a command in an ephemeral app container
    apps:destroy       destroy an application
    apps:transfer      transfer app to another workspace

    Use `drycc help [command]` to learn more

## Workspace commands

Drycc 现在使用基于 Workspace 的协作。使用 `drycc help workspaces` 管理工作区成员、邀请和角色：

    $ drycc help workspaces
    Valid commands for workspaces:

    workspaces:create   create a new workspace
    workspaces:list     list workspaces for current user
    workspaces:info     view info about a workspace
    workspaces:delete   delete a workspace
    workspaces:invite   invite user to workspace
    workspaces:remove   remove a user from a workspace
    workspaces:update   update a workspace member's role or alerts
    workspaces:switch   switch your default workspace

使用 `drycc help workspaces` 查看完整命令详情。


## 支持多个配置文件

CLI 从默认的 `client` 配置文件读取，该文件位于您工作站上的 `$HOME/.drycc/client.json`。

通过设置 `$DRYCC_PROFILE` 环境变量或使用 `-c` 标志，可以轻松在多个 Drycc Workflow 安装或用户之间切换。

设置 `$DRYCC_PROFILE` 选项有两种方法。

1. json 配置文件的路径。
2. 配置文件名称。如果您将配置文件设置为仅名称，它将与默认配置文件一起保存，在 `$HOME/.drycc/<name>.json` 中。

示例：

    $ DRYCC_PROFILE=production drycc login drycc.production.com
    ...
    Opening browser to http://drycc.example.com/v2/login/drycc/?key=4ccc81ee2dce4349ad5261ceffe72c71
    Waiting for login... .o.Logged in as drycc
    Configuration saved to /home/testuser/.drycc/production.json
    $ DRYCC_PROFILE=~/config.json drycc login drycc.example.com
    ...
    Opening browser to http://drycc.example.com/v2/login/drycc/?key=4ccc81ee2dce4349ad5261ceffe72c71
    Waiting for login... .o.Logged in as drycc
    Configuration saved to /home/testuser/config.json

配置标志的工作方式与 `$DRYCC_PROFILE` 相同并覆盖它：

    $ drycc whoami -c ~/config.json
    You are drycc at drycc.example.com

## 代理支持

如果您的工作站使用代理来访问集群所在的网络，请设置 `http_proxy` 或 `https_proxy` 环境变量以启用代理支持：

    $ export http_proxy="http://proxyip:port"
    $ export https_proxy="http://proxyip:port"

{{% alert title="Note" color="info" %}}
对于本地 Minikube 集群，通常不需要配置代理。
{{% /alert %}}

## CLI 插件

插件允许开发人员扩展 Drycc 客户端的功能，添加新命令或功能。

如果指定了未知命令，客户端将尝试将命令作为破折号分隔的命令执行。在这种情况下，`drycc resource:command` 将执行 `drycc-resource` 并使用参数列表 `command`。完整形式：

    $ # 以下两个命令相同
    $ drycc accounts list
    $ drycc-accounts list

命令后的任何标志也将作为参数发送到插件：

    $ # 以下两个命令相同
    $ drycc accounts list --debug
    $ drycc-accounts list --debug

但命令前的标志不会：

    $ # 以下两个命令相同
    $ drycc --debug accounts list
    $ drycc-accounts list
