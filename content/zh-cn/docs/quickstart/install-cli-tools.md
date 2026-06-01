---
title: Drycc Workflow 客户端 CLI
linkTitle: 安装 CLI 工具
description: 如何下载、安装 Drycc CLI 工具。
weight: 3
---

## Drycc Workflow 客户端 CLI

Drycc 命令行界面 (CLI) 让您与 Drycc Workflow 交互。
使用 CLI 创建、配置和管理应用程序。

### Linux / macOS

使用以下命令为 Linux 或 macOS 安装 `drycc` 客户端：

```
$ curl -sfL https://www.drycc.cc/install-cli.sh | bash -
```

{{% alert title="Note" color="danger" %}}
中国大陆用户可以使用以下方法加速安装：

```
$ curl -sfL https://www.drycc.cc/install-cli.sh | INSTALL_DRYCC_MIRROR=cn bash -
```
{{% /alert %}}

### Windows

在 Windows 上，打开 PowerShell 并运行：

```powershell
> irm https://www.drycc.cc/install-cli.ps1 | iex
```

{{% alert title="Note" color="danger" %}}
中国大陆用户可以使用以下方法加速安装：

```powershell
> $env:INSTALL_DRYCC_MIRROR="cn"; irm https://www.drycc.cc/install-cli.ps1 | iex
```
{{% /alert %}}

其他人请访问：https://github.com/drycc/workflow-cli/releases

安装程序将 `drycc` 二进制文件放在当前目录中，但您应该将其移动到 $PATH 中的某个位置：

```
$ sudo ln -fs $PWD/drycc /usr/local/bin/drycc
```

*或*：

```
$ sudo mv $PWD/drycc /usr/local/bin/drycc
```

通过运行 `drycc version` 检查您的工作：

```
$ drycc version
v1.1.0
```

将 workflow cli 更新到最新发布。
```
drycc update
```

{{% alert title="Note" color="info" %}}
请注意，随着新版本的发布，版本号可能会有所不同
{{% /alert %}}
