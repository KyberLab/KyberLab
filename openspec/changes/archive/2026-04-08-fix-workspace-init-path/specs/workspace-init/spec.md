## ADDED Requirements

### Requirement: Support initialization from any working directory
The `kyberlab init` command SHALL be executable from any directory, not only from the KyberLab repository root.

#### Scenario: Initializing from repository root
- **WHEN** the user runs `kyberlab init` from the KyberLab repository root (a directory containing `manifests/` and `template/`)
- **THEN** the system SHALL accept the command
- **AND** the workspace SHALL be created at `<repo_root>/build/<board>`
- **AND** the platform SHALL be auto-detected from the local `manifests/` directory
- **AND** the initialization SHALL proceed with `repo init`, `repo sync`, submodule update, and template copying

#### Scenario: Initializing from an arbitrary directory outside the repository
- **WHEN** the user runs `kyberlab init -d <board> -p <platform>` from a directory that is not within the KyberLab repository
- **THEN** the system SHALL accept the command
- **AND** the workspace SHALL be created at `./<board>` relative to the current working directory
- **AND** the manifest SHALL be resolved from the remote repository URL: `<url>/manifests/<platform>/<board>/<config>.xml`
- **AND** the initialization SHALL proceed with `repo init`, `repo sync`, submodule update, and template copying

#### Scenario: Missing platform flag when outside repository
- **WHEN** the user runs `kyberlab init` from a directory outside the KyberLab repository without providing the `-p` flag
- **THEN** the system SHALL display an error message: "Error: When initializing from outside the KyberLab repository, the -p/--platform flag is required."
- **AND** the command SHALL exit with non-zero status

#### Scenario: Attempting initialization from inside an existing workspace
- **WHEN** the user runs `kyberlab init` from a directory that contains a `WorkSpace.mk` file (i.e., inside an already-initialized workspace)
- **THEN** the system SHALL display an error message: "Error: Cannot initialize a workspace from inside an existing workspace."
- **AND** the command SHALL exit with non-zero status

### Requirement: No automatic building after initialization
After successful workspace initialization, the system SHALL NOT automatically build any Docker images or system images. The user must explicitly run `kyberlab dkbuild` and build commands.

#### Scenario: Post-initialization state
- **WHEN** workspace initialization completes successfully
- **THEN** the workspace directory SHALL contain the initialized repo and copied template files
- **AND** no Docker images SHALL be built
- **AND** no system images SHALL be built
- **AND** the user SHALL receive a message indicating success and next steps (e.g., "cd into the workspace and run `kyberlab dkbuild`")

### Requirement: Command-line interface
The `kyberlab init` command SHALL accept the following options:
- `-d, --board <name>`: Board name (default: `virt-aarch64`)
- `-u, --url <git-url>`: Git URL for the KyberLab repository (default: `https://github.com/KyberLab/KyberLab.git`)
- `-b, --branch <branch>`: Branch name (default: `master`)
- `-m, --config <name>`: Config file name (default: `default`)
- `-p, --platform <name>`: Platform name (e.g., `qemu`, `virt`) — required when running outside the KyberLab repository

#### Scenario: Help text includes new platform flag
- **WHEN** the user runs `kyberlab help` or `kyberlab init --help`
- **THEN** the usage text SHALL include the `-p, --platform` option with an appropriate description
