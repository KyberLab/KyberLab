## ADDED Requirements

### Requirement: Auto-detect working context
The `kyberlab` CLI MUST automatically determine whether it is running from:
- **Repo root**: the KyberLab manifests/templates git repository
- **Workspace**: an initialized workspace directory created by `kyberlab init`
- **Workspace subdirectory**: any nested path inside a workspace

Detection rules up the directory tree from CWD:
- If a directory contains `WorkSpace.mk` → context is WORKSPACE, root is that directory
- If a directory contains both `manifests/` directory and `template/` directory → context is REPO_ROOT, root is that directory
- If neither found after reaching filesystem root → context is UNKNOWN

#### Scenario: Running from workspace root
- **WHEN** user runs `kyberlab build` from `/home/user/build/virt-aarch64/`
- **THEN** context is detected as WORKSPACE with root `/home/user/build/virt-aarch64/`

#### Scenario: Running from nested workspace subdirectory
- **WHEN** user runs `kyberlab build` from `/home/user/build/virt-aarch64/config/image/BusyBox/`
- **THEN** context is detected as WORKSPACE with root `/home/user/build/virt-aarch64/` by walking up the tree

#### Scenario: Running from repo root
- **WHEN** user runs `kyberlab init` from `/opt/virt/KyberLab/KyberLab/`
- **THEN** context is detected as REPO_ROOT with root `/opt/virt/KyberLab/KyberLab/`

#### Scenario: Running outside any KyberLab context
- **WHEN** user runs `kyberlab build` from `/tmp/`
- **THEN** context is detected as UNKNOWN and an error message is printed: "Not in a KyberLab repo root or workspace directory"

### Requirement: Context-appropriate help
The `kyberlab help` command MUST display different commands based on detected context:
- In REPO_ROOT: show `init` command with options
- In WORKSPACE: show build phase commands (`build`, `fetch`, etc.) and docker commands (`dkbuild`, `dkrun`, etc.)
- In UNKNOWN: show generic help with usage instructions

#### Scenario: Help in workspace context
- **WHEN** user runs `kyberlab help` from a workspace directory
- **THEN** output includes build phase commands and docker commands, NOT the `init` command

### Requirement: Build commands execute from workspace root
When executing `make` commands in WORKSPACE context, `kyberlab` MUST change to the detected workspace root directory before invoking `make`, ensuring correct Makefile resolution regardless of current subdirectory depth.

#### Scenario: Build from nested directory
- **WHEN** user runs `kyberlab build -i BusyBox` from `build/virt-aarch64/config/`
- **THEN** `make` is invoked from `build/virt-aarch64/` (the workspace root), NOT from `config/`

### Requirement: Auto-detect image from directory
When the `-i IMAGE` flag is omitted, the CLI MUST walk up the directory tree from CWD to the workspace root, checking each directory name against known images from two sources:
1. Directory names under `config/image/` (image definitions)
2. Directory names under `build/` inside the workspace (built output directories, e.g. `build/BusyBox/`)

If a match is found (case-insensitive), that image name SHALL be used.

#### Scenario: Auto-detect BusyBox from image directory
- **WHEN** user runs `kyberlab build` from `build/virt-aarch64/config/image/BusyBox/`
- **THEN** `make BusyBox_build` is executed (image auto-detected as BusyBox)

#### Scenario: Auto-detect BusyBox from build output directory
- **WHEN** user runs `kyberlab install` from `build/virt-aarch64/build/BusyBox/`
- **THEN** `make BusyBox_install` is executed (image auto-detected as BusyBox from `build/BusyBox/` path)

#### Scenario: Auto-detect from nested subdirectory
- **WHEN** user runs `kyberlab clean` from `build/virt-aarch64/config/image/Linux/drivers/`
- **THEN** `make Linux_clean` is executed (image auto-detected as Linux)

#### Scenario: `-i` flag overrides auto-detection
- **WHEN** user runs `kyberlab build -i BusyBox` from inside `config/image/Linux/`
- **THEN** `make BusyBox_build` is executed (explicit `-i` wins)

#### Scenario: `-i` flag overrides auto-detection
- **WHEN** user runs `kyberlab build -i BusyBox` from inside `config/image/Linux/`
- **THEN** `make BusyBox_build` is executed (explicit `-i` wins)

### Requirement: Auto-detect docker name from directory
When the `-d DKNAME` flag is omitted, the CLI MUST walk up the directory tree from CWD to the workspace root, checking each directory name against known docker names in `bench/image/dockerfile/`. If a match is found (case-insensitive), that name SHALL be used. If no match, fall back to the board name from the workspace path.

#### Scenario: Auto-detect docker name from dockerfile directory
- **WHEN** user runs `kyberlab dkbuild` from `bench/image/dockerfile/qemu/`
- **THEN** `make build_qemu` is executed (docker name auto-detected)

#### Scenario: Fallback to board name
- **WHEN** user runs `kyberlab dkbuild` from `build/virt-aarch64/` (not inside a docker directory)
- **THEN** `make build_virt-aarch64` is executed (board name from path)

#### Scenario: `-d` flag overrides auto-detection
- **WHEN** user runs `kyberlab dkbuild -d develop` from inside `bench/image/dockerfile/qemu/`
- **THEN** `make build_develop` is executed (explicit `-d` wins)
