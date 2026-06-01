---
title: Install CLI Tools
linkTitle: Install CLI Tools
description: How to download and install the Drycc CLI tools.
weight: 3
---

## Drycc Workflow Client CLI

The Drycc command-line interface (CLI) lets you interact with Drycc Workflow. Use the CLI to create, configure, and manage applications.

### Linux / macOS

Install the `drycc` client for Linux or macOS with:

```
$ curl -sfL https://www.drycc.cc/install-cli.sh | bash -
```

{{% alert title="Note" color="danger" %}}
Users in mainland China can use the following method to speed up installation:

```
$ curl -sfL https://www.drycc.cc/install-cli.sh | INSTALL_DRYCC_MIRROR=cn bash -
```
{{% /alert %}}

### Windows

On Windows, open PowerShell and run:

```powershell
> irm https://www.drycc.cc/install-cli.ps1 | iex
```

{{% alert title="Note" color="danger" %}}
Users in mainland China can use the following method to speed up installation:

```powershell
> $env:INSTALL_DRYCC_MIRROR="cn"; irm https://www.drycc.cc/install-cli.ps1 | iex
```
{{% /alert %}}

For other platforms, please visit: https://github.com/drycc/workflow-cli/releases

The installer places the `drycc` binary in your current directory, but you should move it somewhere in your $PATH:

```
$ sudo ln -fs $PWD/drycc /usr/local/bin/drycc
```

*or*:

```
$ sudo mv $PWD/drycc /usr/local/bin/drycc
```

Check your work by running `drycc version`:

```
$ drycc version
v1.1.0
```

Update the workflow CLI to the latest release:

```
$ drycc update
```

{{% alert title="Note" color="info" %}}
Note that version numbers may vary as new releases become available.
{{% /alert %}}
