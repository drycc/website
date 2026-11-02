---
title: Using drycc path
linkTitle: Deploying with drycc path
description: Deploy applications using Drycc path configuration for advanced Docker-based deployments.
weight: 15
---

The Drycc stack supports advanced use cases with custom Docker images. For most applications, we recommend using Drycc's default buildpack system, which provides automatic security updates, language-specific optimizations, and eliminates the need to maintain Dockerfiles.

## Drycc Config Path Overview

A Drycc repository supports two configurations:

* A `.drycc` directory at the root of the working tree
* A root directory as a 'bare' repository (without working tree), typically used for `drycc pull`

Repository contents include:

```
config/[a-z0-9]+(\.[a-z0-9]+)*::
        Configuration files named by group.
        Format follows environment variable syntax.

[a-z0-9]+(\-[a-z0-9]+)*.toml::
        Pipeline configuration files in TOML format.
```

### Config Format

Environment variables use `<NAME>=<VALUE>` format. By convention, variable names are capitalized:

```
DEBUG=true
JVM_OPTIONS=-XX:+UseG1GC
```

### Pipeline Format

A manifest contains these top-level sections:

- `build` – Specifies Dockerfile for building
- `env` – Defines container environment variables
- `run` – Specifies release phase tasks
- `config` – References config groups (global groups referenced automatically)
- `deploy` – Defines deployment commands and arguments

Example manifest for building Docker images:

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

For more deployment examples, see the Drycc [samples](https://github.com/drycc/samples).
