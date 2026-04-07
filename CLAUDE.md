# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KyberLab is an embedded systems development platform that automates building, configuring, and running system images (kernels, bootloaders, root filesystems). Its purpose is to bring DevOps practices to embedded software, achieving one-to-one mapping from source code and configuration to deployable system images. The platform is designed to enable AI-assisted development of bare-metal and embedded software by simplifying environment setup and build/deployment complexity.

## Architecture

The project uses a multi-layered Makefile-based build framework with three sub-components managed via the Android `repo` tool:

1. **KyberBench** (`bench/`) -- Docker-based virtual workbench. Uses Jinja2 templates (`.j2`) and Python (`kyberdocker` script) to generate Dockerfiles. Uses Dockpin for dependency pinning. Provides reproducible, containerized development environments.

2. **KyberImage** (`image/`) -- Core build orchestration. Defines 12 build phases (fetch, patch, config, build, install, package, clean, distclean, remove, info, status, action, summary). Each build goal maps to a build type (Linux, BusyBox, BuildRoot, U-Boot, Ubuntu, etc.) which selects method-specific Makefile rules.

3. **KyberConfig** (`config/`) -- Per-target configuration. Directory under `config/image/` for each build goal (BuildRoot, BusyBox, EDK2, KyberEmu, Linux, OP-TEE, Qemu, U-Boot, Ubuntu, Xen, Yocto, etc.).

The Makefile framework uses extensive macro composition (`define`/`eval`/`call`), conditional logic, and environment variable propagation across nested make invocations and Docker boundaries.

**Key files:**
- `template/Makefile` -- Top-level Makefile template for new workspaces
- `template/WorkSpace.mk` -- Workspace-level configuration template
- `image/Main.mk` -- Central build orchestration
- `bench/Main.mk` -- Bench/docker environment rules

## Repository Structure

- `/manifests/` -- `repo` tool XML manifests for workspace setup (virt-aarch64, virt-x86_64)
- `/template/` -- Template files copied into new workspaces after `repo sync`
- `/build/` -- Synced workspaces (git submodules via repo). Ignored from this repo's tracking.
- `/openspec/` -- OpenSpec AI-assisted spec-driven development workflow

## Common Commands

### KyberLab CLI Installation

From the KyberLab repository root, install the CLI:

```bash
# System-wide installation (requires sudo)
sudo ./install.sh

# User-only installation
./install.sh --user

# Uninstall
sudo ./install.sh --uninstall   # system-wide
./install.sh --uninstall --user # user-only
```

After installation, `kyberlab` command is available from any directory.

### KyberLab CLI Usage

Initialize a workspace:

```bash
# Initialize Virt-AArch64 workspace (default)
kyberlab init

# Specify different board, branch, or URL
kyberlab init -d virt-x86_64
kyberlab init -u <your-url> -b <your-branch> -d <board> -m <config>
```

Workspace build commands (run from workspace directory):

```bash
# Build the Docker workbench image
kyberlab dkbuild

# Build specific Docker image
kyberlab dkbuild -d develop

# Start Docker container (interactive)
kyberlab dkrun

# Start Docker container (detached)
kyberlab dkrund

# Pin Docker dependencies
kyberlab dkpin
```

Build system images (run from workspace directory):

```bash
# Build default image
kyberlab build

# Build a specific image (e.g., BusyBox)
kyberlab build -i BusyBox

# Install default image
kyberlab install

# Install specific image
kyberlab install -i BusyBox

# Clean specific image
kyberlab clean -i BusyBox

# Run default image in QEMU
make emu

# Run specific image in QEMU
make emu_buildroot
make emu_busybox
```

For more options, run `kyberlab help`.

All make commands are run from a workspace directory (e.g., `build/virt-aarch64/`):

```bash
# Build the Docker workbench image
make build_virt-aarch64

# Start the Docker workbench environment
make run_virt-aarch64

# Build the default system image
make build

# Install the default image
make install

# Install a specific image (e.g., BusyBox)
make busybox_install

# Run the default image in QEMU
make emu

# Run a specific image in QEMU
make emu_buildroot
make emu_busybox

# Individual build phases (can be run per-image)
make fetch
make patch
make config
make build
make install
make package
make clean
make distclean
```

## Creating a New Workspace

```bash
# Using repo
mkdir -pv build/virt-aarch64 && cd build/virt-aarch64
repo init -u https://github.com/KyberLab/KyberLab.git -b master -m manifests/qemu/virt-aarch64/default.xml
repo sync -j$(nproc) -v && repo forall -c 'if [ -f .gitmodules ]; then git fetch && git submodule update --init --recursive --force; fi'
cp .repo/manifests/template/* .

# Or clone a workspace repo directly (e.g. Virt-AArch64)
git clone https://github.com/KyberLab/Virt-AArch64.git
cd Virt-AArch64
git submodule update --init --recursive
```

## AI Tooling

This project uses **OpenSpec** for spec-driven development. Custom slash commands are available:
- `/opsx:propose` -- Propose a new change with design, specs, and tasks in one step
- `/opsx:explore` -- Think through ideas and clarify requirements
- `/opsx:apply` -- Implement tasks from an OpenSpec change
- `/opsx:archive` -- Archive a completed change

Also uses **Superpowers** skills (TDD workflow, brainstorming, code review). See `/home/lastritter/.claude/rules/` for the global configuration.

## ⚠️ Important Notes

- The `build/` and `output/` directories are gitignored -- they contain synced submodules and build artifacts. Never commit from these directories.
- All build configuration lives in `WorkSpace.mk` and `config/` `.mk` files in the workspace.
- New build targets go in `config/image/` as a directory with a `.mk` config file.
- New build types go in `image/type/`. New build methods go in `image/method/`.
- Dockerfiles are generated from `.j2` templates in `bench/image/dockerfile/` with config in `bench/image/config/KyberDocker.yaml`.
