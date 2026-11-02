---
title: 管理应用进程
linkTitle: 管理应用进程
description: Procfile 是应用中进程类型的列表。每个进程类型声明一个命令，该命令在启动该进程类型的容器时执行。
weight: 5
---

Drycc Workflow 将您的应用作为一组可以根据其角色命名、扩展和配置的进程进行管理。这为您提供了灵活性，可以轻松管理应用的各个方面。例如，您可能有面向 Web 的进程处理 HTTP 流量、后台工作进程执行异步工作，以及从 Twitter API 流式传输的辅助进程。

通过使用 Procfile（已检入您的应用或通过 CLI 提供），您可以指定类型的名称和应运行的应用命令。要生成其他进程类型，请使用 `drycc scale <ptype>=<n>` 来相应地扩展这些类型。

## 默认进程类型

在没有 Procfile 的情况下，为每个应用假设单个默认进程类型。

使用 [Buildpacks][buildpacks] 通过 `git push` 构建的应用隐式接收 `web` 进程类型，该类型启动应用服务器。例如，Rails 4 具有以下进程类型：

    web: bundle exec rails server -p $PORT

所有使用 [Dockerfiles][dockerfile] 的应用都有一个隐含的 `web` 进程类型，该类型运行 Dockerfile 的 `CMD` 指令而不修改：

    $ cat Dockerfile
    FROM centos:latest
    COPY . /app
    WORKDIR /app
    CMD python -m SimpleHTTPServer 5000
    EXPOSE 5000

对于上述基于 Dockerfile 的应用，`web` 进程类型将运行容器的 `CMD` `python -m SimpleHTTPServer 5000`。

使用 [远程容器镜像][container image] 的应用也会隐含 `web` 进程类型，并运行容器镜像中指定的 `CMD`。

{{% alert title="Note" color="info" %}}
`web` 进程类型是特殊的，因为它是默认进程类型，将从 Workflow 的路由器接收 HTTP 流量。其他进程类型可以任意命名。
{{% /alert %}}

## 声明进程类型

如果您使用 [Buildpack][buildpacks] 或 [Dockerfile][dockerfile] 构建并想要覆盖或指定其他进程类型，只需在应用源树的根目录中包含一个名为 `Procfile` 的文件。

`Procfile` 的格式是每行一个进程类型，每行包含要调用的命令：

    <process type>: <command>

语法定义为：

* `<process type>` – 小写字母数字字符串，是您的命令的名称，如 web、worker、urgentworker、clock 等。
* `<command>` – 启动进程的命令行，如 `rake jobs:work`。

此示例 Procfile 指定了两种类型，`web` 和 `sleeper`。`web` 进程在端口 5000 上启动 Web 服务器，一个简单的进程休眠 900 秒然后退出。

```
$ cat Procfile
web: bundle exec ruby web.rb -p ${PORT:-5000}
sleeper: sleep 900
```

如果您使用 [远程容器镜像][container image]，您可以通过在工作目录中使用 `Procfile` 运行 `drycc pull`，或通过将字符串化的 Procfile 传递给 `--procfile` CLI 选项来定义进程类型。

例如，内联传递进程类型：

```
$ drycc pull drycc/example-go:latest --procfile="web: /app/bin/boot"
```

读取另一个目录中的 `Procfile`：

```
$ drycc pull drycc/example-go:latest --procfile="$(cat deploy/Procfile)"
```

或通过位于当前工作目录中的 Procfile：

```
$ cat Procfile
web: /bin/boot
sleeper: echo "sleeping"; sleep 900


$ drycc pull -a steely-mainsail drycc/example-go
Creating build... done

$ drycc scale sleeper=1 -a steely-mainsail
Scaling processes... but first, coffee!
done in 0s

NAME                                        RELEASE    STATE    PTYPE      READY    RESTARTS     STARTED
steely-mainsail-sleeper-76c45b967c-4qm6w    v3         up       sleeper    1/1      0            2023-12-08T02:25:00UTC
steely-mainsail-web-c4f44c4b4-7p7dh         v3         up       web        1/1      0            2023-12-08T02:25:00UTC
```

{{% alert title="Note" color="info" %}}
只有 `web` 进程类型会自动扩展到 1。如果您有其他进程类型，请记住创建后扩展进程计数。
{{% /alert %}}

要删除进程类型，只需将其扩展到 0：

```
$ drycc scale sleeper=0 -a steely-mainsail
Scaling processes... but first, coffee!
done in 3s

NAME                                        RELEASE    STATE    PTYPE      READY    RESTARTS     STARTED
steely-mainsail-web-c4f44c4b4-7p7dh         v3         up       web        1/1      0            2023-12-08T02:25:00UTC
```

## 扩展进程

部署在 Drycc Workflow 上的应用通过 [进程模型][] 向外扩展。使用 `drycc scale` 来控制为您的应用提供动力的 [容器][container] 数量。

```
$ drycc scale web=5 -a iciest-waggoner
Scaling processes... but first, coffee!
done in 3s

NAME                                        RELEASE    STATE    PTYPE      READY    RESTARTS     STARTED
iciest-waggoner-web-c4f44c4b4-7p7dh         v3         up       web        1/1      0            2023-12-08T02:25:00UTC
iciest-waggoner-web-c4f44c4b4-8p7dh         v3         up       web        1/1      0            2023-12-08T02:25:00UTC
iciest-waggoner-web-c4f44c4b4-9p7dh         v3         up       web        1/1      0            2023-12-08T02:25:00UTC
iciest-waggoner-web-c4f44c4b4-1p7dh         v3         up       web        1/1      0            2023-12-08T02:25:00UTC
iciest-waggoner-web-c4f44c4b4-2p7dh         v3         up       web        1/1      0            2023-12-08T02:25:00UTC
```

如果您的应用有多个进程类型，您可以分别为每个类型扩展进程计数。例如，这允许您独立管理 Web 进程和后台工作进程。有关进程类型的更多信息，请参阅我们的 [管理应用进程](managing-app-processes.md) 文档。

在此示例中，我们将进程类型 `web` 扩展到 5，但将进程类型 `background` 保留为一个工作进程。

```
$ drycc scale web=5
Scaling processes... but first, coffee!
done in 4s

NAME                                                RELEASE    STATE    PTYPE      READY    RESTARTS     STARTED
scenic-icehouse-web-3291896318-7lord                v3         up       web        1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-web-3291896318-jn957                v3         up       web        1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-web-3291896318-rsekj                v3         up       web        1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-web-3291896318-vwhnh                v3         up       web        1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-web-3291896318-vokg7                v3         up       web        1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-web-3291896318-vokg7                v3         up       web        1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-background-3291896318-yf8kh         v3         up       web        1/1      0            2023-12-08T02:25:00UTC
```

通过减少进程计数来扩展进程会向进程发送 `TERM` 信号，如果它们在 30 秒内未退出，则跟随 `SIGKILL`。根据您的应用，扩展可能会中断长时间运行的 HTTP 客户端连接。

例如，从 5 个进程扩展到 3：

```
$ drycc scale web=3
Scaling processes... but first, coffee!
done in 1s

NAME                                                RELEASE    STATE    PTYPE     READY    RESTARTS     STARTED
scenic-icehouse-web-3291896318-vwhnh                v2         up       web       1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-web-3291896318-vokg7                v2         up       web       1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-web-3291896318-vokg9                v2         up       web       1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-background-3291896318-yf8kh         v2         up       web       1/1      0            2023-12-08T02:25:00UTC
```

## 自动扩展

自动扩展允许在每个进程类型的基础上添加最小和最大数量的 Pod。这是通过指定所有可用 Pod 的目标 CPU 使用率来实现的。

此功能建立在 Kubernetes 中的 [Horizontal Pod Autoscaling][HPA] 或简称 [HPA][] 之上。

{{% alert title="Note" color="info" %}}
这是一个 alpha 功能。建议在使用此功能时使用最新的 Kubernetes。
{{% /alert %}}

```
$ drycc autoscale set web --min=3 --max=8 --cpu-percent=75
Applying autoscale settings for process type web on scenic-icehouse... done

```
然后查看为 `web` 创建的扩展规则

```
$ drycc autoscale list
PTYPE    PERCENT    MIN    MAX
web      75         3      8
```

删除扩展规则

```
$ drycc autoscale unset web
Removing autoscale for process type web on scenic-icehouse... done
```

为了使自动扩展工作，必须在每个应用 Pod 上指定 CPU 请求（可以通过 `drycc limits --cpu` 完成）。这允许自动扩展策略进行 [适当计算][autoscale-algo] 并决定何时向上和向下扩展。

向上扩展只能在过去 3 分钟内没有重新扩展的情况下发生。向下扩展将等待上次重新扩展后的 5 分钟。该信息和更多信息可以在 [HPA 算法页面][autoscale-algo] 找到。

## 获取应用容器的日志
列出容器：

```
$ drycc ps
NAME                                                RELEASE    STATE    PTYPEE     READY    RESTARTS     STARTED
python-getting-started-web-69b7d4bfdc-kl4xf         v2         up       web        1/1      0             2023-12-08T02:25:00UTC

=== python-getting-started Processes
--- web:
python-getting-started-web-69b7d4bfdc-kl4xf up (v2)
```

获取容器日志：
```
$ drycc ps logs -f python-getting-started-web-69b7d4bfdc-kl4xf
[2024-05-24 07:14:39 +0000] [1] [INFO] Starting gunicorn 20.1.0
[2024-05-24 07:14:39 +0000] [1] [INFO] Listening at: http://0.0.0.0:8000 (1)
[2024-05-24 07:14:39 +0000] [1] [INFO] Using worker: gevent
[2024-05-24 07:14:39 +0000] [8] [INFO] Booting worker with pid: 8
[2024-05-24 07:14:39 +0000] [9] [INFO] Booting worker with pid: 9
[2024-05-24 07:14:39 +0000] [10] [INFO] Booting worker with pid: 10
[2024-05-24 07:14:39 +0000] [11] [INFO] Booting worker with pid: 11

```

## 获取应用容器的信息
列出容器：

```
$ drycc ps describe python-getting-started-web-69b7d4bfdc-kl4xf
Container:        python-getting-started-web                   
Image:            drycc/python-getting-started:latest          
Command:          
Args:             
                  - gunicorn                                   
                  - -c                                         
                  - gunicorn_config.py                         
                  - helloworld.wsgi:application                
State:            running                                      
  started_at:     2024-05-24T07:14:39Z
Ready:            true                                         
Restart Count:    0                 

```

## 删除应用容器
删除容器。
由于设置了副本数量，将启动新容器以满足数量要求。

```
$ drycc ps delete python-getting-started-web-69b7d4bfdc-kl4xf
Deleting python-getting-started-web-69b7d4bfdc-kl4xf from python-getting-started... done
```

## 获取运行容器的 Shell

验证容器正在运行：

```
$ drycc ps
NAME                                                RELEASE    STATE    PTYPEE     READY    RESTARTS     STARTED
python-getting-started-web-69b7d4bfdc-kl4xf         v2         up       web        1/1      0             2023-12-08T02:25:00UTC

=== python-getting-started Processes
--- web:
python-getting-started-web-69b7d4bfdc-kl4xf up (v2)
```

获取运行容器的 shell：

```
$ drycc ps exec python-getting-started-web-69b7d4bfdc-kl4xf -it -- bash
```

在您的 shell 中，列出根目录：

```
# 在容器内运行此命令
ls /
```

在容器中运行单个命令

```
$ drycc ps exec python-getting-started-web-69b7d4bfdc-kl4xf -- date
```

使用 "drycc ps --help" 获取全局命令行列表（适用于所有命令）。

## 重启应用进程

如果您需要重启应用进程，您可以使用 `drycc pts restart`。在幕后，Drycc Workflow 指示 Kubernetes 终止旧进程并启动新进程来替换它。

```
$ drycc ps
NAME                                               RELEASE    STATE       PTYPE      READY    RESTARTS     STARTED
scenic-icehouse-web-3291896318-vokg7               v2         up          web        1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-web-3291896318-rsekj               v2         up          web        1/1      0            2023-12-08T02:50:21UTC
scenic-icehouse-web-3291896318-vokg7               v2         up          web        1/1      0            2023-12-08T02:25:00UTC
scenic-icehouse-background-3291896318-yf8kh        v2         up          web        1/1      0            2023-12-08T02:25:00UTC

$ drycc pts restart scenic-icehouse-background
NAME                                               RELEASE    STATE       PTYPE      READY    RESTARTS    STARTED
scenic-icehouse-web-3291896318-vokg7               v2         up          web        1/1      0           2023-12-08T02:25:00UTC
scenic-icehouse-web-3291896318-rsekj               v2         up          web        1/1      0           2023-12-08T02:50:21UTC
scenic-icehouse-web-3291896318-vokg7               v2         up          web        1/1      0           2023-12-08T02:25:00UTC
scenic-icehouse-background-3291896318-yf8kh        v2         starting    web        1/1      0           2023-12-08T02:25:00UTC
```

注意进程名称已从 `scenic-icehouse-background-3291896318-yf8kh` 更改为 `scenic-icehouse-background-3291896318-yd87g`。在多节点 Kubernetes 集群中，这也可能具有将 Pod 调度到新节点的效果。


使用 "drycc pts --help" 获取 pts 命令行列表（进程类型信息）。

## 列出应用进程类型

```
$ drycc pts
NAME          RELEASE    READY    UP-TO-DATE    AVAILABLE    GARBAGE    STARTED                   
web           v2         3/3      1             1            true       2023-12-08T02:25:00UTC    
background    v2         1/1      1             1            false      2023-12-08T02:25:00UTC    
```

## 清理进程类型

清理不存在的 ptype，通常在 autodeploy 设置为 `true` 时自动执行。

```
$ drycc pts clean background
```


## 获取应用进程类型的部署信息

```
$ drycc pts describe web
Container:    python-getting-started-web                   
Image:        drycc/python-getting-started:latest          
Command:      
Args:         
              - gunicorn                                   
              - -c                                         
              - gunicorn_config.py                         
              - helloworld.wsgi:application                
Limits:       
              cpu 1                                                                                               
              ephemeral-storage 2Gi                                                                               
              memory 1Gi                                                                                          
Liveness:     http-get headers=[] path=/geo/ port=8000 delay=120s timeout=10s period=20s #success=1 #failure=3    
Readiness:    http-get headers=[] path=/geo/ port=8000 delay=120s timeout=10s period=20s #success=1 #failure=3  
```

[container]: ../reference-guide/terms.md#container
[process model]: https://devcenter.heroku.com/articles/process-model
[buildpacks]: ../applications/using-buildpacks.md
[dockerfile]: ../applications/using-dockerfiles.md
[container image]: ../applications/using-container-images.md
[HPA]: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
[autoscale-algo]: https://github.com/kubernetes/community/blob/master/contributors/design-proposals/horizontal-pod-autoscaler.md#autoscaling-algorithm
