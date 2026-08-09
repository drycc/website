# Drycc Website — Agent Instructions

> **When you change code patterns, conventions, or architecture, update this file
> in the same commit.** AGENTS.md is the single source of truth for project
> conventions — if it's stale, the next agent will follow wrong patterns.

## Project Overview

Documentation website for the Drycc PaaS platform. Built with [Hugo](https://gohugo.io/) (extended, v0.151.0) using the [Docsy](https://www.docsy.dev/) theme (pulled as a Hugo module). Content is bilingual: English (`content/en/`) and Chinese (`content/zh-cn/`).

## Directory Structure

```
website/
  hugo.yaml                # Main Hugo configuration (languages, params, module imports)
  config.yaml              # Test-only config for Hugo version detection (do not edit)
  package.json             # npm scripts for build/serve (hugo-extended via npm)
  Dockerfile               # Container image for CI builds
  docker-compose.yaml      # Local Docker-based development
  Makefile                 # Podman-based build commands
  go.mod / go.sum          # Go module dependencies (Hugo + Docsy)
  docsy.work               # Hugo workspace file for local Docsy development
  assets/
    scss/
      _variables_project.scss  # Theme color overrides ($primary, $secondary)
    icons/
      logo.svg             # Site logo
  content/
    en/                    # English content (default language)
      docs/               # Main documentation
        applications/      # App deployment & management guides
        contribution-guidelines/
        installing-workflow/
        managing-workflow/
        quickstart/
        reference-guide/  # Controller API reference (v2.0–v2.3)
        roadmap/
        security/
        troubleshooting/
        understanding-workflow/
        users/
      blog/
        news/              # Blog posts (news)
        releases/          # Release announcements (v1.2.0–v1.8.1)
      about/
      community/
    zh-cn/                 # Chinese content — mirrors en/ structure
      docs/
      blog/
      about/
      community/
  i18n/
    en/en.toml             # English UI strings
    zh-cn/zh-cn.toml       # Chinese UI strings
  layouts/
    404.html               # Custom 404 page
    _default/
      _markup/
        render-heading.html  # Custom heading renderer
  static/
    images/
      diagrams/            # Architecture diagrams (PNG, JPG, SVG)
  .woodpecker/
    publish-docs.yml       # CI pipeline for publishing docs
```

## Content Conventions

### Front Matter

All content pages use YAML front matter:

```yaml
---
title: Managing App Processes
linkTitle: Managing App Processes
description: Learn how to manage application processes using Procfiles, scale process types, configure autoscaling, and troubleshoot running containers.
weight: 5
---
```

- `weight` controls page ordering within a section (lower = earlier).
- `linkTitle` is the short title shown in navigation.
- `description` appears in SEO meta and search results.

### Page Structure

- Use Markdown headings (`##`, `###`) for sections.
- Code examples in fenced code blocks (`` ``` ``).
- Alert boxes use Docsy shortcodes: `{{% alert title="Note" color="info" %}}...{{% /alert %}}`.
- Reference links at the bottom of the page using Markdown reference link syntax: `[text]: url`.

### Bilingual Content

English (`content/en/`) and Chinese (`content/zh-cn/`) directories **must mirror each other**. The docs subdirectory structure is identical across both languages:

- `content/en/docs/applications/deploying-apps.md` ↔ `content/zh-cn/docs/applications/deploying-apps.md`
- `content/en/docs/reference-guide/controller-api-v2-3.md` ↔ `content/zh-cn/docs/reference-guide/controller-api-v2-3.md`

**When updating one language, update the other.** Keep the same front matter fields (`weight`, `linkTitle` translated), same section structure, and same code examples (CLI commands and output are not translated — only prose).

## Naming Convention: snake_case for API Fields

**CLI commands and examples use `snake_case` for all Drycc API-related field names.** This matches the Controller API's `CamelCaseJSONField` output convention, which converts Django CamelCase model fields to snake_case JSON keys.

Examples of snake_case API field names used in docs:

- `liveness_probe`, `readiness_probe`, `startup_probe` (health check probes)
- `http_get`, `exec`, `tcp_socket` (probe check types)
- `post_start`, `pre_stop` (lifecycle hooks)
- `backend_refs` (route backend references)
- `common_name`, `last_login`, `is_superuser`, `date_joined` (API response fields)

**K8s concept descriptions** in prose can reference native Kubernetes `camelCase` names (e.g., `imagePullPolicy`, `terminationGracePeriodSeconds`) when explaining how Drycc maps to underlying K8s resources. However, **CLI command examples and CLI output examples must use snake_case**.

Example — correct (snake_case in CLI context):

```
$ drycc healthchecks set liveness_probe http_get 80 --ptype web
```

```
$ drycc healthchecks set readiness_probe exec -- /bin/echo -n hello --ptype web
```

Example — K8s YAML manifests in docs use K8s-native camelCase (this is fine, it's K8s manifest format, not Drycc CLI):

```yaml
apiVersion: controller.drycc.cc/v2.3
kind: HTTPRoute
metadata:
  name: sleep
spec:
  parents:
  - name: python-getting-started
```

## Build and Preview

### Local Development

Install [Hugo extended](https://gohugo.io/installation/) (v0.151.0+) and run:

```bash
hugo serve
```

View at [http://localhost:1313](http://localhost:1313).

### Via npm (with Hugo extended package)

```bash
npm install
npm run serve       # serves with live reload
npm run build       # builds to public/
```

### Via Docker

```bash
docker-compose up   # uses docker-compose.yaml
```

### Via Podman (Makefile)

```bash
make build          # builds container image and runs Hugo inside
```

### CI/CD

Woodpecker CI pipeline (`.woodpecker/publish-docs.yml`) builds and publishes the site.

## Key Configuration

| Setting | Location | Purpose |
|---|---|---|
| Languages | `hugo.yaml` → `languages` | English (default) and Chinese |
| Default content dir | `hugo.yaml` → `contentDir` | `content/en` |
| Docsy theme | `hugo.yaml` → `module.imports` | `github.com/google/docsy` |
| Hugo version | `hugo.yaml` → `module.hugoVersion` | extended, min 0.110.0 |
| Search | `hugo.yaml` → `params.offlineSearch` | Lunr.js offline search |
| GitHub repo | `hugo.yaml` → `params.github_repo` | `https://github.com/drycc/website` |
| Theme colors | `assets/scss/_variables_project.scss` | `$primary: rgb(8,27,75)`, `$secondary: #fff` |

## Dependencies

- Hugo Extended v0.151.0
- Docsy theme (Hugo module: `github.com/google/docsy`)
- Node.js 22 (see `.nvmrc`)
- Go (for Hugo module resolution)

## Content Sections

| Section | Path | Description |
|---|---|---|
| Applications | `docs/applications/` | Deploying, configuring, scaling, and managing apps |
| Quickstart | `docs/quickstart/` | Getting started guides |
| Installing Workflow | `docs/installing-workflow/` | Installation, DNS, registry, postgres, object storage |
| Managing Workflow | `docs/managing-workflow/` | Production deployments, logging, monitoring, upgrades |
| Understanding Workflow | `docs/understanding-workflow/` | Architecture, components, concepts |
| Reference Guide | `docs/reference-guide/` | Controller REST API v2.0–v2.3 |
| Users | `docs/users/` | CLI installation, registration, SSH keys |
| Troubleshooting | `docs/troubleshooting/` | Workflow, kubectl, application debugging |
| Contribution Guidelines | `docs/contribution-guidelines/` | Contributing, testing, PRs, design docs |
| Roadmap | `docs/roadmap/` | Releases, planning process |
| Blog | `blog/news/`, `blog/releases/` | News and release announcements |
