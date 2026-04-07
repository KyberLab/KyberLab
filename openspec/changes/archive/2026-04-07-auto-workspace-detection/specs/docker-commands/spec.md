## ADDED Requirements

### Requirement: Docker commands
The CLI MUST provide subcommands for Docker workbench operations:
- `kyberlab dkbuild` — builds a Docker workbench image (`make build_<DKNAME>`)
- `kyberlab dkrun` — starts the Docker workbench interactively (`make run_<DKNAME>`)
- `kyberlab dkrund` — starts the Docker workbench detached (`make rund_<DKNAME>`)
- `kyberlab dkexec` — executes a command in a running Docker workbench (`make exec_<DKNAME>`)
- `kyberlab dkpin` — pins Docker image dependencies (`make dockpin_<DKNAME>`)

Each command accepts an optional `-d NAME` flag to specify the Docker container/image name. When omitted, the CLI SHALL auto-detect the docker name from the current directory path. If neither `-d` nor auto-detection yields a name, the default board name is used (e.g., `virt-aarch64`).

#### Scenario: Default docker build
- **WHEN** user runs `kyberlab dkbuild` in a workspace (not inside a docker directory)
- **THEN** `make build_virt-aarch64` is executed (using default board name)

#### Scenario: Named docker build
- **WHEN** user runs `kyberlab dkbuild -d develop` in a workspace
- **THEN** `make build_develop` is executed

#### Scenario: Auto-detect docker name from directory
- **WHEN** user runs `kyberlab dkbuild` from inside `bench/image/dockerfile/qemu/` or any of its subdirectories
- **THEN** `make build_qemu` is executed (docker name auto-detected)

#### Scenario: Docker run detached
- **WHEN** user runs `kyberlab dkrund -d virt-aarch64`
- **THEN** `make rund_virt-aarch64` is executed

### Requirement: Docker commands require workspace context
Docker commands MUST only work when the detected context is WORKSPACE. If detected as REPO_ROOT or UNKNOWN, an error message is printed explaining that docker commands require an initialized workspace.

#### Scenario: Docker build from repo root
- **WHEN** user runs `kyberlab dkbuild` from the KyberLab repo root
- **THEN** error: "Docker commands require an initialized workspace. Use 'kyberlab init' first."

#### Scenario: Docker pin dependencies
- **WHEN** user runs `kyberlab dkpin -d develop` in a workspace
- **THEN** `make dockpin_develop` is executed from the workspace root
