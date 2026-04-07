# Proposal: Auto-Detect Working Directory and Full CLI Wrapper

## Problem

Currently, `kyberlab` only supports two subcommands (`help` and `init`) and requires users to:
1. Know whether they're in the KyberLab git repo root or an initialized workspace
2. Manually invoke `make <TARGET>` with complex target naming conventions (`<IMAGE>_<PHASE>`, `build_<DOCKER>`, `run_<DOCKER>`)
3. Look up available image names, build phases, and docker container names

Users switch between two modes:
- **Repo root mode** (the manifests/templates repository): initializing workspaces
- **Workspace mode** (a `build/<BOARD>/` directory after `init`): building images, running Docker environments

There's no unified CLI experience.

## What To Build

Enhance `kyberlab` to:

1. **Auto-detect context** — determine if running from:
   - **Repo root**: the KyberLab git repo (contains `manifests/`, `template/`)
   - **Workspace**: an initialized workspace (contains `WorkSpace.mk`, `image/`)

2. **In repo root**: support `init` command (existing behavior) — create workspace under `build/<BOARD>/`

3. **In workspace**: support build and docker subcommands:
   - Build phases: `fetch`, `patch`, `config`, `build`, `install`, `package`, `clean`, `distclean`
     - Use `-i <IMAGE>` to target a specific image (runs `make <IMAGE>_<PHASE>`)
     - Without `-i`, run `make <PHASE>` for the default image
   - Docker commands: `dkbuild`, `dkrun`, `dkrund`, `dkexec`
     - Use `-d <DOCKER_NAME>` to target a specific docker container
     - Maps to `make build_<name>`, `make run_<name>`, `make rund_<name>`, `make exec_<name>`

## Why

- Eliminates the need to remember Make target naming conventions
- Single CLI entry point for the entire workflow
- Better discoverability through `help` showing context-appropriate commands
- Enables future IDE/editor tooling and CI/CD integration

## Scope

### In Scope
- Auto-detection logic (repo root vs workspace)
- Build phase subcommands (`build`, `fetch`, `patch`, `config`, `install`, `package`, `clean`, `distclean`)
- Docker subcommands (`dkbuild`, `dkrun`, `dkrund`, `dkexec`)
- `-i` flag for image targeting
- `-d` flag for docker name targeting
- Updated `help` command showing context-appropriate commands
- Running `make` from the workspace root regardless of current subdirectory depth

### Out of Scope
- `emu` / QEMU emulator commands (future)
- Configuration editing/management
- Adding new build phases or docker methods
- Non-Make-based operations

## Rollback Plan

Revert the `kyberlab` script to its previous two-command version. The Makefile-based workflow remains untouched — `kyberlab` is purely a wrapper, so rollback has no impact on existing build infrastructure.

## Affected Teams

- KyberDev team members who will use `kyberlab` daily instead of raw `make` commands
- CI/CD pipelines that may switch from `make` invocations to `kyberlab`
