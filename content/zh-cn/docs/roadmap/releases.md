---
title: 发布
linkTitle: 发布
description: Drycc 的发布模型允许应用记录和回滚到以前的版本。
weight: 3
---

Drycc 使用 [持续交付][] 方法来创建发布。每个通过测试的合并提交都会产生一个可交付成果，可以为其指定 [语义版本][] 标签并发布。

项目的 master `git` 分支应该始终工作。只有被认为准备好公开发布的更改才会合并。


## 组件按需发布

Drycc 组件根据需要发布新版本。修复高优先级错误需要项目维护者创建新的补丁发布。合并向后兼容的功能意味着次要发布。

通过频繁发布，每个组件发布都成为安全且常规的事件。这使得用户更快更容易地获得特定修复。持续交付还减少了发布像 Drycc Workflow 这样的产品所需的工作，该产品集成了多个组件。

"组件"不仅适用于 Drycc Workflow 项目，还适用于开发和发布工具、容器基础镜像，以及进行 [语义版本][] 发布 的其他 Drycc 项目。

有关更多详细信息，请参见"[如何发布组件](#how-to-release-a-component)"。


## Workflow 每月发布

Drycc Workflow 有规律的公开发布节奏。从 v2.8.0 开始，新 Workflow 功能发布在每个月的第一个星期四到达。补丁发布根据需要随时创建。GitHub 里程碑用于传达主要和次要发布的内容和时间，更长期的规划在 [路线图](roadmap.md) 上可见。

Workflow 发布时间不与特定功能相关联。如果某个功能在发布日期之前合并，它将包含在下一个发布中。

有关更多详细信息，请参见"[如何发布 Workflow](#how-to-release-workflow)"。


## 语义版本控制

Drycc 发布符合 [语义版本控制][semantic version]，其中"公共 API"广泛定义为：

- REST、gRPC 或其他网络可访问的 API
- 供公众使用的库或框架 API
- 用户可以重定向的"可插拔"套接字级协议
- CLI 命令和输出格式

一般来说，对用户可能合理链接、自定义或集成的任何内容的更改都应该是向后兼容的，否则需要主要发布。Drycc 用户可以确信升级到补丁或次要发布不会破坏任何东西。


## 如何发布组件

大多数 Drycc 项目都是"组件"，它们产生容器镜像或二进制可执行文件作为交付成果。本节指导维护者创建组件发布。

### 步骤 1：更新代码并运行发布工具

主要或次要发布应该在 master 分支上进行。补丁发布应该检出之前的发布标签并从 master 樱桃挑选特定提交。

**注意：** 如果是补丁发布，发布工件将需要通过触发 [component-promote](https://ci.drycc.info/job/component-promote) 作业手动提升，并使用以下值：

```bash
COMPONENT_NAME=<component name>
COMPONENT_SHA=<patch commit sha>
```

确保您的搜索 `$PATH` 中有 [dryccrel][] 发布工具。

使用假的 semver 标签运行一次 `dryccrel release` 来校对变更日志内容。（如果 master 的 `HEAD` 不是发布意图，请添加 `--sha` 标志，如 `dryccrel release --help` 中所述。）

```bash
$ dryccrel release controller v0.0.0
Doing a dry run of the component release...
skipping commit 943a49267eeb28546819a266654806cfcbae0e38

Creating changelog for controller with tag v2.8.1 through commit 943a49267eeb28546819a266654806cfcbae0e38

### v2.8.1 -> v0.0.0

#### 修复

- [`615b834`](https://github.com/drycc/controller/commit/615b834f39cb68a854cc1f1e2f0f82d862ea2731) boot: Ensure DRYCC_DEBUG==true for debug output
```

根据变更日志内容，确定组件是否值得次要或补丁发布。使用该 semver 标签再次运行命令，并使用 `--dry-run=false`。您仍会在创建发布之前被要求确认：
```bash
$ dryccrel release controller v2.8.2 --dry-run=false
skipping commit 943a49267eeb28546819a266654806cfcbae0e38

Creating changelog for controller with tag v2.8.1 through commit 943a49267eeb28546819a266654806cfcbae0e38

### v2.8.1 -> v2.8.2


#### 修复

- [`615b834`](https://github.com/drycc/controller/commit/615b834f39cb68a854cc1f1e2f0f82d862ea2731) boot: Ensure DRYCC_DEBUG==true for debug output


请检查上述变更日志内容并确保：
  1. 所有预期的提交都已提及
  2. 更改与 semver 发布标签（主要、次要或补丁）一致

为 Drycc Controller v2.8.2 创建发布？ [y/n]: y
新发布可在此处获取 https://github.com/drycc/controller/releases/tag/v2.8.2
```

### 步骤 2：验证组件可用

标记组件（参见 [步骤 1](/roadmap/releases/#step-1-update-code-and-run-the-release-tool)）启动 CI 作业，最终导致工件可供公众下载。请参见 [CI 流程图](https://github.com/drycc/jenkins-jobs/#flow) 了解详细信息。

通过 `podman pull` 命令或运行适当的安装脚本来仔细检查工件是否可用。

如果无法下载工件，请确保其 CI 发布作业仍在进行中，或修复管道中出现的任何问题。例如，[master 合并管道](https://github.com/drycc/jenkins-jobs/#when-a-component-pr-is-merged-to-master) 可能未能提升 `:git-abc1d23` 候选镜像，需要使用该组件和提交重新启动。

如果组件有相关的 [Kubernetes Helm][] 图表，此图表也将被打包、签名并上传到其生产图表仓库。请验证它可以被获取（并验证）：

```
$ helm fetch oci://registry.drycc.cc/drycc/charts/controller --version 1.0.0
Verification: &{0xc4207ec870 sha256:026e766e918ff28d2a7041bc3d560d149ee7eb0cb84165c9d9d00a3045ff45c3 controller-v1.0.1.tgz}
```

## 如何发布 Workflow

Drycc Workflow 将多个组件发布与 [Kubernetes Helm][] 图表交付成果集成在一起。本节指导维护者创建 Workflow 发布。

### 步骤 1：设置环境变量

导出将在后续步骤中使用的两个环境变量：

```bash
export WORKFLOW_RELEASE=v2.17.0 WORKFLOW_PREV_RELEASE=v2.16.0  # 例如
```

### 步骤 2：标记支持仓库

一些不在 Helm 图表中的 Workflow 组件也必须与发布同步标记。按照上面的 [组件发布过程](#how-to-release-a-component) 进行操作，并确保这些组件被标记：

- [drycc/workflow-cli][]
- [drycc/workflow-e2e][]

[drycc/workflow-cli][] 的版本号应始终与整体 Workflow 版本号匹配。

### 步骤 3：创建 Helm 图表

要为 Workflow 创建和暂存发布候选图表，我们将使用以下参数构建 [workflow-chart-stage](https://ci.drycc.info/job/workflow-chart-stage) 作业：

`RELEASE_TAG=$WORKFLOW_RELEASE`

此作业将收集所有最新的组件发布标签，并使用这些来指定所有组件图表的版本。然后它将打包 Workflow 图表，将其上传到暂存图表仓库，并针对该图表启动 e2e 运行。

### 步骤 4：手动测试

现在是时候超越当前 CI 测试了。创建一个测试矩阵电子表格（从之前的文档复制是一个好的开始），并注册测试人员来覆盖所有排列。

测试人员应特别注意整体用户体验，确保从早期版本升级顺利，并覆盖各种存储配置、Kubernetes 版本和基础设施提供商。

当发现关键级别的错误时，过程如下：

1. 创建一个修复错误的组件 PR。
1. 一旦 PR 通过并审查，合并它并进行新的 [组件发布](#how-to-release-a-component)
1. 触发与步骤 3 中提到的相同的 `workflow-chart-stage` 作业，将新生成的 Workflow 发布候选图表上传到暂存。

### 步骤 5：发布图表

当测试完成且没有发现任何新的关键级别错误时，使用以下参数启动 [workflow-chart-release](https://ci.drycc.info/job/workflow-chart-release) 作业：

`RELEASE_TAG=$WORKFLOW_RELEASE`

此作业将已批准的发布候选图表（现在由 CI 和手动测试批准）从暂存仓库复制到生产仓库，如果尚未签名则签名。

### 步骤 6：组装主变更日志

每个组件已经在 GitHub 上使用 CHANGELOG 内容更新了其发布说明。我们现在将生成 Workflow 图表的主变更日志，由所有组件和辅助仓库更改组成。

我们将使用 `WORKFLOW_PREV_RELEASE` 图表的 `requirements.lock` 文件，以及 repo-to-chart-name [映射文件](https://github.com/drycc/dryccrel/blob/main/map.json)，这次调用 `dryccrel changelog global` 来获取图表版本在 `WORKFLOW_PREV_RELEASE` 图表中存在和 GitHub 中存在的 _最新_ 发布之间的所有组件更改。（因此，如果组件仓库中有任何未发布的提交，它们不会出现在这里）：

```bash
helm fetch --untar oci://registry.drycc.cc/drycc/charts/workflow --version $WORKFLOW_PREV_RELEASE
dryccrel changelog global workflow/requirements.lock map.json > changelog-$WORKFLOW_RELEASE.md
```

此主变更日志应放置在一个 gist 中。该文件也将添加到下一步创建的文档更新 PR 中。

### 步骤 7：更新文档

在 [drycc/workflow][] 创建一个新的拉取请求，更新对新发布的版本引用。使用 `git grep $WORKFLOW_PREV_RELEASE` 查找任何引用，但要小心不要更改 `CHANGELOG.md`。

将步骤 7 中生成的 `$WORKFLOW_RELEASE` 主变更日志放置在 `changelogs` 目录中。确保为页面添加标题以明确这是 Workflow 发布，例如：

```
## Workflow v2.16.0 -> v2.17.0
```

一旦 PR 被审查并合并，对 [drycc/workflow][] 本身进行 [组件发布](#how-to-release-a-component)。[drycc/workflow][] 的版本号应始终与整体 Workflow 版本号匹配。

### 步骤 8：关闭 GitHub 里程碑

在 [seed-repo](https://github.com/drycc/seed-repo) 创建一个拉取请求以关闭发布里程碑并创建下一个。当更改合并到 seed-repo 时，所有相关项目的里程碑将被更新。如果里程碑上有未解决的问题，在合并拉取请求之前将它们移动到下一个即将到来的里程碑。

里程碑映射到 [drycc/workflow][] 中的 Drycc Workflow 发布。这些里程碑不对应于单个组件发布标签。

### 步骤 9：发布 Workflow CLI 稳定版

现在 `$WORKFLOW_RELEASE` 版本的 Workflow CLI 已经过验证，我们可以基于此版本推送 `stable` 工件。

使用 `$WORKFLOW_RELEASE` 的 `TAG` 构建参数启动 https://ci.drycc.info/job/workflow-cli-build-stable/，然后在作业完成后验证 `stable` 工件可用且适当更新：

```
$ curl -sfL https://www.drycc.cc/install-cli.sh | bash -
$ ./drycc version
# (应该显示 $WORKFLOW_RELEASE)
```

### 步骤 10：让每个人知道

让团队的其他成员知道他们可以开始为新的 Workflow 发布写博客和发推文。在 Slack 的 #company 频道发布消息。包括指向已发布图表和主 CHANGELOG 的链接：

```
@here Drycc Workflow v2.17.0 is现在上线了！
主 CHANGELOG: https://drycc.info/docs/workflow/changelogs/v2.17.0/
```

发布完成了。干得好！

[component release]: /roadmap/releases/#how-to-release-a-component
[continuous delivery]: https://en.wikipedia.org/wiki/Continuous_delivery
[drycc/workflow]: https://github.com/drycc/workflow
[drycc/workflow-cli]: https://github.com/drycc/workflow-cli
[drycc/workflow-e2e]: https://github.com/drycc/workflow-e2e
[dryccrel]: https://github.com/drycc/dryccrel
[Kubernetes Helm]: https://github.com/kubernetes/helm
[semantic version]: http://semver.org
