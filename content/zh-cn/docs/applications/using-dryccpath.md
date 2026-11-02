---
title: 使用 drycc 路径
linkTitle: 使用 drycc 路径部署
description: Drycc 容器注册表允许您将基于 Docker 的应用部署到 Drycc。支持通用运行时和私有空间。
weight: 15
---

Drycc 堆栈仅适用于高级用例。除非您有自定义 Docker 镜像的具体需求，否则我们建议使用 Drycc 的默认 buildpack 驱动的构建系统。它提供自动基础镜像安全更新和特定于语言的优化。它还避免了维护容器 Dockerfile 的需要。

## Drycc 配置路径概述

Drycc 仓库有两种不同的形式：

* 工作树根目录下的 `.drycc` 目录；

* 根目录是一个"裸"仓库（即没有自己的工作树）。
  通常用于 `drycc pull`。

Drycc 仓库中可能存在这些东西。

```
config/[a-z0-9]+(\.[a-z0-9]+)*::
        配置文件名，文件名是组名。
        格式是环境变量格式。

[a-z0-9]+(\-[a-z0-9]+)*.toml::
        流水线配置文件，使用 TOML 格式。
```

### 配置格式

环境变量遵循 <NAME>=<VALUE> 格式。按照惯例，但不是规则，环境变量名称总是大写的。

```
DEBUG=true
JVM_OPTIONS=-XX:+UseG1GC
```

### 流水线格式

清单包含以下顶级部分。

- build – 指定要构建的 Dockerfile。
- env – 指定容器中的环境变量。
- run – 指定要执行的发布阶段任务。
- config – 指定配置组，全局组自动引用。
- deploy – 指定部署的命令和参数。

这是一个说明使用清单构建 Docker 镜像的示例。

```toml
ptype = "web"
config = ["jvmconfig"]

[build]
docker = "Dockerfile"

[build.arg]
CODENAME = "bookworm"

[env]
VERSION = "1.2.1"

[run]
command = ["./deployment-tasks.sh"]
image = "task"
timeout = 100

[deploy]
command = ["bash", "-ec"]
args = ["bundle exec puma -C config/puma.rb"]
```

有关更多部署信息，请参考 drycc [示例](https://github.com/drycc/samples)。
