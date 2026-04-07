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

### 1. Environment Preparation

Ensure the following dependencies are installed:
- Git;
- Repo;
- Make;
- Docker.

### 2. Clone Repository

Use the `kyberlab` CLI to initialize a workspace. Run from the repository root:

```bash
# Initialize Virt-AArch64 workspace (default)
python3 kyberlab init
```

This will automatically create `build/virt-aarch64/`, run `repo init`, `repo sync`, initialize submodules, and copy template files.

To specify a different board, branch, or URL:

```bash
python3 kyberlab init -d virt-x86_64
python3 kyberlab init -u <your-url> -b <your-branch> -d <board> -m <config>
```

For more options, run `python3 kyberlab help`.

### 3. Build Virtual Workbench Image

```bash
cd build/virt-aarch64

# Build Virt-AArch64 virtual workbench image
python3 ../../kyberlab dkbuild
```

### 4. Build System Image

```bash
cd build/virt-aarch64

# Build default image
python3 ../../kyberlab build

# Build a specific image (e.g. BusyBox)
python3 ../../kyberlab build -i BusyBox

# Install default image
python3 ../../kyberlab install

# Install BusyBox
python3 ../../kyberlab install -i BusyBox

# Clean a specific image
python3 ../../kyberlab clean -i BusyBox
```

The `kyberlab` CLI auto-detects the image name when run from inside an image directory (e.g. `config/image/BusyBox/` or `build/BusyBox/`), so `-i` is not needed.

### 5. Docker Commands

```bash
cd build/virt-aarch64

# Build Docker workbench image (default board)
python3 ../../kyberlab dkbuild

# Build specific Docker image
python3 ../../kyberlab dkbuild -d develop

# Start Docker container interactively
python3 ../../kyberlab dkrun

# Start Docker container detached
python3 ../../kyberlab dkrund

# Pin Docker dependencies
python3 ../../kyberlab dkpin
```

### 6. Run System Image

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

## Contribution Guide

1. Fork the project repository;
2. Create a feature branch;
3. Commit your changes;
4. Submit a Pull Request.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
