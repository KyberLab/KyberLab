# KyberLab

English Version | [中文版本](README_zh.md)

## Project Overview

KyberLab is a basic software development platform:
* Simplify Makefile rule writing through KyberRules' Makefile macros;
* Build containerized development environments through KyberBench to ensure development environment consistency;
* Solidify image building methods and steps through KyberImage's image building methods;
* Simplify emulator configuration and execution through KyberEmu's Qemu run scripts.

By implementing automated building and running of various system images, it achieves DevOps for basic software development, enabling one-to-one mapping from source code and configuration to system images, simplifying configuration management for basic software development, and improving development efficiency and quality.

In the AI era, software development methods such as Vibe Coding and Spec Coding are becoming increasingly popular. However, in the basic software development field, due to the variability of development and runtime environments and the complexity of build and deployment steps, development efficiency is low. It is also not conducive to automated coding and testing through AI. To address this, KyberLab simplifies and automates the setup of basic software development environments, building, deployment, and running of various system images, making it easier for AI and engineers to develop basic software.

## Key Features

### 1. Virtual Workbench Environment
- Provide container-based virtual development environments;
- Use Jinja2 to enhance the programmability of Dockerfiles;
- Use tools and methods like Dockpin to solidify software package versions.

### 2. System Image Building
- Support building and customizing various operating system images, easily adapting to build methods like BuildRoot and Yocto;
- Provide flexible build configurations and automated workflows, allowing flexible extension of build methods;
- Pre-integrate multiple build methods: Linux, BusyBox, BuildRoot, etc.

## Quick Start

### 1. Installation

You can install KyberLab to make the `kyberlab` command available system-wide or for your user only.

**System-wide installation** (requires sudo, installs to `/usr/local/bin`):

```bash
# From the KyberLab repository root
sudo ./install.sh
```

**User-only installation** (no sudo required, installs to `~/.local/bin`):

```bash
# From the KyberLab repository root
./install.sh --user
```

**Verification**: After installation, verify it works:

```bash
kyberlab help
```

**Uninstall**:

```bash
# System-wide
sudo ./install.sh --uninstall

# User-only
./install.sh --uninstall --user
```

Note: Uninstalling KyberLab does not delete your workspace data.

If `~/.local/bin` is not in your PATH, the installer will provide instructions to add it.

---

### 2. Environment Preparation

Ensure the following dependencies are installed on your system:
- Git;
- Repo;
- Make;
- Docker.


### 3. Initialize Workspace

Use the `kyberlab` CLI for one-click initialization.

**From the KyberLab repository root** (contains `manifests/` and `template/`):

```bash
# Initialize Virt-AArch64 workspace (default)
kyberlab init
```

This creates `virt-aarch64/`, runs `repo init`, `repo sync`, initializes submodules, and copies template files.

**From any other directory** (outside the repository):

```bash
# Initialize a workspace in the current directory (creates ./<board>)
kyberlab init -d <board> -p <platform>
```

You must specify the platform with `-p` (e.g., `qemu`, `rockchip`). The workspace will be created at `./<board>` relative to the current directory. You can also provide `-u`, `-b`, and `-m` to customize the remote repository and configuration.

**Examples**:

```bash
# From repo root: initialize default board
kyberlab init

# From anywhere: initialize x86_64 board using qemu platform
kyberlab init -d virt-x86_64 -p qemu

# From anywhere: custom URL and branch
kyberlab init -u https://github.com/example/KyberLab.git -b develop -d my-board -p rockchip -m custom
```

For more options, run `kyberlab help`.

### 4. Build Virtual Workbench Image

```bash
cd virt-aarch64

# Build Virt-AArch64 virtual workbench image
kyberlab dkbuild
```

### 5. Build System Image

```bash
cd virt-aarch64

# Build default image
kyberlab build

# Build a specific image (e.g. BusyBox)
kyberlab build -i BusyBox

# Install default image
kyberlab install

# Install BusyBox
kyberlab install -i BusyBox

# Clean a specific image
kyberlab clean -i BusyBox
```

The `kyberlab` CLI auto-detects the image name when run from inside an image directory (e.g. `config/image/BusyBox/` or `build/BusyBox/`), so `-i` is not needed.

### 6. Docker Commands

```bash
cd virt-aarch64

# Build Docker workbench image (default board)
kyberlab dkbuild

# Build specific Docker image
kyberlab dkbuild -d develop

# Start Docker container interactively
kyberlab dkrun

# Start Docker container detached
kyberlab dkrund

# Pin Docker dependencies
kyberlab dkpin
```

### 7. Run System Image

```bash
# Run default image
make emu

# Run BuildRoot image
make emu_buildroot
```

## Basic Concepts

- **Virtual Workbench Environment (Bench)**: Provides container-based virtual development environments for developing and testing basic software;
- **System Image Building (Image)**: Supports building and customizing various operating system images, easily adapting to build methods like Buildroot and Yocto;
- **Build Rules and Tools (Rules)**: Provides flexible build configurations and automated workflows, allowing flexible extension of build methods;
- **Pre-integrated Build Methods (Methods)**: Pre-integrates multiple build methods such as Linux, BusyBox, BuildRoot, etc.

### Build Goal

Build goals are located in the `config/image/` directory and are instances of system image building. Each build goal must specify a build type (Type) and can override the build methods within it.

### Build Type

Build types define the build methods and steps for build goals (Goal). Currently supported build types include:

- **U-Boot**: Build U-Boot bootloader;
- **Linux**: Build Linux kernel and kernel modules;
- **BusyBox**: Build BusyBox system;
- **BuildRoot**: Build BuildRoot system;
- **Ubuntu**: Build Ubuntu system.

### Build Phases

Build phases are the basic steps that each build goal (Goal) needs to execute during the build process, mainly including:
- **Fetch**: Obtain build resources;
- **Patch**: Apply patches or copy pre-compiled files;
- **Config**: Configure build goals;
- **Build**: Formal build;
- **Install**: Install to specified directory;
- **Package**: Package target files, generally as tar.xz compressed packages or Bin installation packages;
- **Clean**: Basic cleanup, generally only cleans build intermediate files;
- **Distclean**: Thorough cleanup, clears configuration and installed files;
- **Remove**: Delete build files;
- **Info**: View build information;
- **Status**: View build status;
- **Action**: Execute image custom operations;
- **Summary**: View image summary information.

### Build Methods

The specific implementation methods for each build type (Type) and build phase (Phase), mainly include:

- **Dump**: Only print Phase information;
- **Skip**: Skip Phase, do not execute any operations;
- **Scons**: Support Scons-based build methods;
- **BuildRoot**: Support BuildRoot-based build methods;
- **Custom**: Support custom build methods;
- **Linux**: Support Linux-based build methods;
- **Git**: Support Git-based build methods, mainly for Patch phase;
- **Patch**: Support applying patches or copying pre-compiled files, mainly for Patch phase;
- **Copy**: Support copying files to specified directories, mainly for Patch and Install phases;
- **Install**: Support installing files to specified directories, mainly for Install phase;
- **Tar**: Support packaging target files, mainly for Package phase.

## Configuration Instructions

### Configuration Options

The project supports multiple image builds, located in the `config/image/` directory:

- **BuildRoot**: BuildRoot configuration;
- **BusyBox**: BusyBox configuration;
- **CustomDemo**: Custom demo configuration;
- **EDK2**: EDK2 UEFI configuration;
- **KyberEmu**: Emulator configuration;
- **Linux**: Linux configuration;
- **OP-TEE**: OP-TEE security framework configuration;
- **Qemu**: Qemu configuration;
- **U-Boot**: U-Boot configuration;
- **Ubuntu**: Ubuntu system configuration;
- **Xen**: Xen hypervisor configuration;
- **Yocto**: Yocto system configuration.

### Build Methods

Supports multiple build methods located in the `image/method/` directory, and multiple build types located in the `image/type/` directory.

For more details, see the [image documentation](image/README.md).

## Virtual Workbench Environment

The virtual workbench environment is located in the `bench/` directory, providing:

- Virtual environment building and running framework;
- Workbench image configurations;
- Build rules and tools;
- Support for different architectures.

For more details, see the [bench documentation](bench/README.md).

## Troubleshooting

### kyberlab: command not found

If the shell reports `kyberlab: command not found` after installation, it means the installation directory is not in your PATH.

**For user-only installation (`~/.local/bin`)**:

Add the following to your shell configuration file:

- **Bash** (`~/.bashrc` or `~/.bash_profile`):
  ```bash
  export PATH="$HOME/.local/bin:$PATH"
  ```

- **Zsh** (`~/.zshrc`):
  ```bash
  export PATH="$HOME/.local/bin:$PATH"
  ```

- **Fish** (`~/.config/fish/config.fish`):
  ```bash
  set -gx PATH $HOME/.local/bin $PATH
  ```

After updating, restart your terminal or run:

```bash
source ~/.bashrc  # or ~/.zshrc, etc.
```

### Permission denied during system installation

When running `sudo ./install.sh` you might see:

```
[ERROR] Cannot write to /usr/local/bin (permission denied)
```

This indicates you didn't use sudo. System-wide installation requires root privileges:

```bash
sudo ./install.sh
```

### Installation verification fails

If the installer reports "Verification: Script is installed but execution test returned non-zero", this is typically because:

1. The kyberlab command is being run from outside a workspace (no WorkSpace.mk found)
2. You are not in a KyberLab repository or initialized workspace

This warning is usually **harmless** - the kyberlab script is installed correctly and will work when run from a valid workspace or repository root.

### Python version issues

KyberLab requires **Python 3.8 or later**. If you encounter Python-related errors, verify your Python version:

```bash
python3 --version
```

If your system has an older Python version, upgrade Python before using KyberLab.

### Uninstall preserves workspace data

Uninstalling KyberLab only removes the `kyberlab` executable from the binary directory. Your workspace data (directories like `build/`, `config/`, `output/`) are **not affected** and remain on your system.

---

## Contribution Guide

1. Fork the project repository;
2. Create a feature branch;
3. Commit your changes;
4. Submit a Pull Request.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
