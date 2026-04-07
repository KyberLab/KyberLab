# KyberLab

[English Version](README.md) | 中文版本

## 项目简介

KyberLab 是一个 基础软件开发平台：
* 通过 KyberRules 提供的Makefile宏，简化Makefile规则的编写；
* 通过 KyberBench 构建基于容器化的开发环境，保证开发环境的一致性；
* 通过 KyberImage 提供的镜像构建方法，固化镜像构建的方法和步骤；
* 通过 KyberEmu 提供的Qemu运行脚本，简化模拟器的配置和运行。

通过实现多种系统镜像的自动化构建和运行，实现基础软件开发的DevOps，做到从源码和配置到系统镜像的一一映射，简化基础软件开发的配置管理，提高开发效率和质量。

在AI时代，通过 Vibe Coding 和 Spec Coding 进行软件开发的方法已经越来越流行。然而，在基础软件开发领域，由于开发和运行环境多变，构建和部署步骤繁杂，导致开发效率低下。同时也不利于通过AI来自动化的编码和测试，为此，KyberLab 通过简化和自动化基础软件的开发环境的搭建、多种系统镜像的构建、部署和运行，从而使得 AI 和工程师更容易的开发基础软件。


## 主要功能

### 1. 虚拟工作环境
- 提供基于容器的虚拟开发环境；
- 使用 Jinja2 增强 Dockerfile 的可编程性；
- 使用 Dockpin 等工具和方法固化软件包版本。

### 2. 系统镜像构建
- 支持多种操作系统镜像的构建和定制，轻松适配 BuildRoot、Yocto 等构建方法；
- 提供灵活的构建配置和自动化流程，可灵活扩展构建方法；
- 预集成多种构建方法：Linux、BusyBox、BuildRoot等。


## 快速开始

### 1. 环境准备

确保系统已安装以下依赖：
- Git；
- Repo；
- Make；
- Docker。


### 2. 初始化工作区

使用 `kyberlab` CLI 一键初始化。在仓库根目录下运行：

```bash
# 初始化 Virt-AArch64 工作区（默认）
python3 kyberlab init
```

这将自动创建 `build/virt-aarch64/`，运行 `repo init`、`repo sync`，初始化子仓库，并复制模板文件。

指定不同的开发板、分支或 URL：

```bash
python3 kyberlab init -d virt-x86_64
python3 kyberlab init -u <your-url> -b <your-branch> -d <board> -m <config>
```

更多选项请运行 `python3 kyberlab help`。

### 3. 构建虚拟工作台镜像

```bash
cd build/virt-aarch64

# 构建 Virt-AArch64 虚拟工作台镜像
python3 ../../kyberlab dkbuild
```

### 4. 构建系统镜像

```bash
cd build/virt-aarch64

# 构建默认镜像
python3 ../../kyberlab build

# 构建指定镜像（例如 BusyBox）
python3 ../../kyberlab build -i BusyBox

# 安装默认镜像
python3 ../../kyberlab install

# 安装 BusyBox
python3 ../../kyberlab install -i BusyBox

# 清理指定镜像的构建产物
python3 ../../kyberlab clean -i BusyBox
```

在镜像目录（如 `config/image/BusyBox/` 或 `build/BusyBox/`）中运行时，`-i` 参数会自动检测，无需手动指定。

### 5. Docker 命令

```bash
cd build/virt-aarch64

# 构建 Docker 工作台镜像（默认开发板）
python3 ../../kyberlab dkbuild

# 构建指定 Docker 镜像
python3 ../../kyberlab dkbuild -d develop

# 启动 Docker 容器（交互式）
python3 ../../kyberlab dkrun

# 启动 Docker 容器（后台运行）
python3 ../../kyberlab dkrund

# 锁定 Docker 依赖
python3 ../../kyberlab dkpin
```

### 6. 运行系统镜像

```bash
# 运行默认镜像
make emu

# 运行BuildRoot镜像
make emu_buildroot
```

## 基本概念

- 虚拟工作台环境（Bench）：提供基于容器的虚拟开发环境，用于开发和测试基础软件；
- 系统镜像构建（Image）：支持多种操作系统镜像的构建和定制，轻松适配 Buildroot、Yocto 等构建方法；
- 构建规则和工具（Rules）：提供灵活的构建配置和自动化流程，可灵活扩展构建方法；
- 预集成构建方法（Methods）：预集成多种构建方法，如 Linux、BusyBox、BuildRoot 等。

### 构建目标

构建目标（Goal）位于`config/image/`目录下，是系统镜像构建的实例，每个构建目标必须指定一个构建类型（Type），并可对其中的构建方法进行重载。

### 构建类型

构建类型（Type）定义构建目标（Goal）的构建方法和步骤，目前支持的构建类型有：

- U-Boot，构建U-Boot引导加载器；
- Linux，构建Linux内核和内核模块；
- BusyBox，构建BusyBox系统；
- BuildRoot，构建BuildRoot系统；
- Ubuntu，构建Ubuntu系统。


### 构建阶段

构建阶段（Phase）是每个构建目标（Goal）在构建过程中需要执行的基本步骤，主要有：
- Fetch，获取构建资源；
- Patch，打补丁或复制预编译文件；
- Config，配置构建目标；
- Build，正式构建；
- Install，安装到指定目录；
- Package，打包目标文件，一般为tar.xz压缩包或Bin安装包；
- Clean，基本清理，一般只会清理构建中间文件；
- Distclean，彻底清理，会清除配置和已安装文件;
- Remove，删除构建文件；
- Info，查看构建信息；
- Status，查看构建状态；
- Action，执行镜像自定义的操作；
- Summary，查看镜像概要信息。

### 构建方法（Method）

每个构建类型（Type）和构建阶段（Phase）的具体实现方法,主要有：

- Dump，仅打印 Phase 信息；
- Skip，跳过 Phase ，不执行任何操作；
- Scons，支持基于 Scons 的构建方法；
- BuildRoot，支持基于 BuildRoot 的构建方法；
- Custom，支持自定义构建方法；
- Linux，支持基于 Linux 的构建方法；
- Git，支持基于 Git 的构建方法，主要是 Patch 阶段；
- Patch，支持打补丁或复制预编译文件，找事 Patch 阶段；
- Copy，支持复制文件到指定目录，主要是 Patch 和 Install 阶段；
- Install，支持安装文件到指定目录，主要是 Install 阶段；
- Tar，支持打包目标文件，主要是 Package 阶段。

## 配置说明

### 配置选项

项目支持多种镜像构建，位于 `config/image/` 目录：

- **BuildRoot**：BuildRoot 配置；
- **BusyBox**：BusyBox 配置；
- **CustomDemo**：自定义演示配置；
- **EDK2**：EDK2 UEFI 配置；
- **KyberEmu**：模拟器配置；
- **Linux**：Linux 配置；
- **OP-TEE**：OP-TEE 安全框架配置；
- **Qemu**：Qemu 配置；
- **U-Boot**：U-Boot 配置；
- **Ubuntu**：Ubuntu 系统配置；
- **Xen**：Xen 虚拟机配置；
- **Yocto**：Yocto 系统配置。


### 构建方法

支持多种构建方法，位于 `image/method/` 目录, 以及多种构件类型，位于 `image/type/` 目录。

有关更多详细信息，请参阅 [image 文档](image/README_zh.md)。


## 虚拟工作台环境

虚拟工作台环境位于 `bench/` 目录，提供了：

- 虚拟环境构建和运行框架；
- 工作台镜像配置；
- 构建规则和工具；
- 对不同架构的支持。

有关更多详细信息，请参阅 [bench 文档](bench/README_zh.md)。

## 贡献指南

1. Fork 项目仓库；
2. 创建功能分支；
3. 提交更改；
4. 发起 Pull Request。

## 许可证

本项目采用 Apache License 2.0 许可证。详见 [LICENSE](LICENSE) 文件。

