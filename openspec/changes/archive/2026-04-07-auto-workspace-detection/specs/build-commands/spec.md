## ADDED Requirements

### Requirement: Build phase commands
The CLI MUST provide subcommands for each build phase:
- `kyberlab build` — runs `make build` or `make <IMAGE>_build`
- `kyberlab fetch` — runs `make fetch` or `make <IMAGE>_fetch`
- `kyberlab patch` — runs `make patch` or `make <IMAGE>_patch`
- `kyberlab config` — runs `make config` or `make <IMAGE>_config`
- `kyberlab install` — runs `make install` or `make <IMAGE>_install`
- `kyberlab package` — runs `make package` or `make <IMAGE>_package`
- `kyberlab clean` — runs `make clean` or `make <IMAGE>_clean`
- `kyberlab distclean` — runs `make distclean` or `make <IMAGE>_distclean`

Each command accepts an optional `-i IMAGE` flag. When provided, the target is `<IMAGE>_<phase>`. When omitted, the CLI SHALL auto-detect the image from the current directory path (see Auto-detect image from directory). If neither `-i` nor auto-detection yields a name, the target is the phase alone (e.g., `make clean`).

#### Scenario: Default image build
- **WHEN** user runs `kyberlab build` in a workspace without `-i` flag and not inside an image directory
- **THEN** `make build` is executed from the workspace root

#### Scenario: Specific image build
- **WHEN** user runs `kyberlab build -i BusyBox` in a workspace
- **THEN** `make BusyBox_build` is executed from the workspace root

#### Scenario: Auto-detect image from directory
- **WHEN** user runs `kyberlab build` from inside `config/image/BusyBox/` or any of its subdirectories
- **THEN** `make BusyBox_build` is executed (image auto-detected)

#### Scenario: Auto-detect image for clean
- **WHEN** user runs `kyberlab clean` from inside `config/image/BusyBox/`
- **THEN** `make BusyBox_clean` is executed from the workspace root

#### Scenario: Invalid image name
- **WHEN** user runs `kyberlab build -i NonExistent`
- **THEN** `make NonExistent_build` is executed and Make's error message is passed through to the user

### Requirement: Build commands require workspace context
Build phase commands MUST only work when the detected context is WORKSPACE. If detected as REPO_ROOT or UNKNOWN, an error message is printed explaining that build commands must be run from an initialized workspace.

#### Scenario: Build from repo root
- **WHEN** user runs `kyberlab build` from the KyberLab repo root (which contains `manifests/`)
- **THEN** error: "Build commands require an initialized workspace. Use 'kyberlab init' first."
