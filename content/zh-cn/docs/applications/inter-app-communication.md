---
title: 应用间通信
linkTitle: 应用间通信
description: Drycc 应用程序之间的通信解决方案。
weight: 11
---

多进程应用程序的常见架构模式是让一个进程服务公共请求，同时让多个其他进程支持公共进程，例如按计划执行操作或处理队列中的工作项。要在 Drycc Workflow 中实现这种应用程序系统，请设置应用程序使用 DNS 解析进行通信，如上所示，并通过从 Drycc Workflow 路由器中删除它们来隐藏支持进程的公共视图。

## DNS 服务发现

Workflow 会为 web 进程类型创建默认的 [Kubernetes Service](https://kubernetes.io/docs/user-guide/services/)。您也可以为任意进程类型创建指定名称的 Service，包括使用不同端口但选择同一进程类型的多个 Service。

默认 web Service 使用应用名称并监听 80 端口；自定义 Service 使用其配置的名称和端口。每个 Service 都会获得 `<service-name>.<app-id>.svc` 形式的集群内部 DNS 名称。

例如，应用可以通过 `python-getting-started-sleep.python-getting-started.svc:8001` 连接 `sleep` Service。请使用 `drycc services list` 显示的 Service 名称，该名称也用于 Route 后端引用。
