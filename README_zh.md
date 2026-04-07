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

### 1. 安装

您可以将 KyberLab 安装到系统或用户目录，使 `kyberlab` 命令全局可用。

**系统级安装**（需要 sudo，安装到 `/usr/local/bin`）：

```bash
# 从 KyberLab 仓库根目录运行
sudo ./install.sh
```

**用户级安装**（无需 sudo，安装到 `~/.local/bin`）：

```bash
# 从 KyberLab 仓库根目录运行
./install.sh --user
```

**验证安装**：

```bash
kyberlab help
```

**卸载**：

```bash
# 系统级卸载
sudo ./install.sh --uninstall

# 用户级卸载
./install.sh --uninstall --user
```

注意：卸载 KyberLab 不会删除您的工作区数据（`build/`、`config/` 等目录）。

如果 `~/.local/bin` 不在您的 PATH 中，安装程序会提供添加它的说明。

---

### 2. 环境准备

确保系统已安装以下依赖：
- Git；
- Repo；
- Make；
- Docker。


### 3. 初始化工作区

使用 `kyberlab` CLI 一键初始化。

**在 KyberLab 仓库根目录**（包含 `manifests/` 和 `template/`）：

```bash
# 初始化 Virt-AArch64 工作区（默认）
kyberlab init
```

这将在 `build/virt-aarch64/` 创建并运行 `repo init`、`repo sync`、初始化子模块、复制模板文件。

**在任何其他目录**（仓库外部）：

```bash
# 在当前目录初始化工作区（创建 ./<board>）
kyberlab init -d <board> -p <platform>
```

必须在仓库外使用 `-p` 指定平台（例如 `qemu`、`rockchip`）。工作区将在当前目录下创建 `./<board>`。您也可以使用 `-u`、`-b`、`-m` 自定义仓库和配置。

**示例**：

```bash
# 从仓库根目录：初始化默认开发板
kyberlab init

# 从任意位置：使用 qemu 平台初始化 x86_64 开发板
kyberlab init -d virt-x86_64 -p qemu

# 从任意位置：自定义 URL 和分支
kyberlab init -u https://github.com/example/KyberLab.git -b develop -d my-board -p rockchip -m custom
```

更多选项请运行 `kyberlab help`。

### 4. 构建虚拟工作台镜像

```bash
cd build/virt-aarch64

# 构建 Virt-AArch64 虚拟工作台镜像
kyberlab dkbuild
```

### 5. 构建系统镜像

```bash
cd build/virt-aarch64

# 构建默认镜像
kyberlab build

# 构建指定镜像（例如 BusyBox）
kyberlab build -i BusyBox

# 安装默认镜像
kyberlab install

# 安装 BusyBox
kyberlab install -i BusyBox

# 清理指定镜像的构建产物
kyberlab clean -i BusyBox
```

在镜像目录（如 `config/image/BusyBox/` 或 `build/BusyBox/`）中运行时，`-i` 参数会自动检测，无需手动指定。

### 6. Docker 命令

```bash
cd build/virt-aarch64

# 构建 Docker 工作台镜像（默认开发板）
kyberlab dkbuild

# 构建指定 Docker 镜像
kyberlab dkbuild -d develop

# 启动 Docker 容器（交互式）
kyberlab dkrun

# 启动 Docker 容器（后台运行）
kyberlab dkrund

# 锁定 Docker 依赖
kyberlab dkpin
```

### 7. 运行系统镜像

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

## 故障排除

### kyberlab: command not found

如果安装后 shell 报告 `kyberlab: command not found`，说明安装目录不在您的 PATH 中。

**用户级安装（`~/.local/bin`）**：

在您的 shell 配置文件中添加以下内容：

- **Bash**（`~/.bashrc` 或 `~/.bash_profile`）：
  ```bash
  export PATH="$HOME/.local/bin:$PATH"
  ```

- **Zsh**（`~/.zshrc`）：
  ```bash
  export PATH="$HOME/.local/bin:$PATH"
  ```

- **Fish**（`~/.config/fish/config.fish`）：
  ```bash
  set -gx PATH $HOME/.local/bin $PATH
  ```

更新后，重启终端或运行：

```bash
source ~/.bashrc  # 或 ~/.zshrc 等
```

### 系统安装时权限被拒绝

运行 `sudo ./install.sh` 时如果看到：

```
[ERROR] Cannot write to /usr/local/bin (permission denied)
```

这表示您没有使用 sudo。系统级安装需要 root 权限：

```bash
sudo ./install.sh
```

### 安装验证失败

如果安装程序报告 "Verification: Script is installed but execution test returned non-zero"，通常是因为：

1. kyberlab 命令在 workspace 之外运行（没有找到 WorkSpace.mk）
2. 您不在 KyberLab 仓库或已初始化的 workspace 中

这个警告通常是**无害的** - kyberlab 脚本已正确安装，当从有效的 workspace 或仓库根目录运行时将正常工作。

### Python 版本问题

KyberLab 需要 **Python 3.8 或更高版本**。如果遇到 Python 相关错误，请验证您的 Python 版本：

```bash
python3 --version
```

如果您的系统 Python 版本较旧，请先升级 Python。

### 卸载保留工作区数据

卸载 KyberLab 只会从二进制目录中删除 `kyberlab` 可执行文件。您的工作区数据（`build/`、`config/` 等目录）**不会被影响** 并会保留在您的系统上。

---

## 贡献指南

1. Fork 项目仓库；
2. 创建功能分支；
3. 提交更改；
4. 发起 Pull Request。

## 许可证

本项目采用 Apache License 2.0 许可证。详见 [LICENSE](LICENSE) 文件。

