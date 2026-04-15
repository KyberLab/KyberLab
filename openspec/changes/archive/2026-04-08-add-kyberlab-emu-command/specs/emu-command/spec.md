## ADDED Requirements

### Requirement: Emu command interface
The KyberLab CLI SHALL provide an `emu` sub-command that can be invoked as `kyberlab emu`. This command SHALL function as a build phase that launches the system image in QEMU.

#### Scenario: User invokes emu command from workspace root
- **WHEN** user runs `kyberlab emu` from a workspace root directory
- **THEN** the CLI SHALL execute `make emu` in the workspace root after performing prerequisite checks
- **AND** the QEMU emulator SHALL launch with the built system image

### Requirement: Platform restriction enforcement
The `emu` command SHALL only work when the workspace platform (`PLAT`) is set to `qemu`. If the platform is not qemu, the command SHALL abort with a clear error message before any make invocation.

#### Scenario: Emu command on non-qemu platform
- **WHEN** user runs `kyberlab emu` in a workspace where `PLAT` is not `qemu` (e.g., `virt`, `x86`)
- **THEN** the CLI SHALL print an error: "Error: 'emu' command only supports qemu platform."
- **AND** the CLI SHALL exit with non-zero status without invoking `make`

#### Scenario: Emu command on qemu platform passes platform check
- **WHEN** user runs `kyberlab emu` in a workspace where `PLAT = qemu`
- **THEN** the CLI SHALL continue to the KyberEmu dependency check
- **AND** the CLI SHALL NOT print a platform error

### Requirement: KyberEmu dependency auto-initialization
Before running the emu phase, the CLI SHALL check for the presence of the KyberEmu repository in `build/KyberEmu`. If this directory does not exist, the CLI SHALL automatically run `make kyberemu_install` to initialize it.

#### Scenario: KyberEmu missing on first emu invocation
- **WHEN** user runs `kyberlab emu` and `build/KyberEmu` directory does not exist
- **THEN** the CLI SHALL print a message: "[kyberlab] KyberEmu not found. Initializing..."
- **AND** the CLI SHALL run `make kyberemu_install` in the workspace root
- **IF** `kyberemu_install` succeeds
  - **THEN** the CLI SHALL proceed to run the emu phase
- **IF** `kyberemu_install` fails (non-zero exit)
  - **THEN** the CLI SHALL exit with that error code and NOT attempt the emu phase

#### Scenario: KyberEmu already present skips initialization
- **WHEN** user runs `kyberlab emu` and `build/KyberEmu` directory exists
- **THEN** the CLI SHALL NOT run `make kyberemu_install`
- **AND** the CLI SHALL proceed directly to the emu phase

### Requirement: Image selection and auto-detection
The `emu` command SHALL support the `-i IMAGE` option to specify which image to emulate. If `-i` is not provided, the CLI SHALL auto-detect the image from the current working directory (consistent with other build phase commands).

#### Scenario: User specifies image explicitly
- **WHEN** user runs `kyberlab emu -i BusyBox`
- **THEN** the CLI SHALL execute `make emu_BusyBox` (or `make emu` if the target name differs)
- **AND** the BusyBox image SHALL be launched in QEMU

#### Scenario: User runs emu from an image config directory without -i
- **WHEN** user is in a directory like `config/image/BusyBox/` and runs `kyberlab emu`
- **THEN** the CLI SHALL auto-detect the image name as "BusyBox"
- **AND** execute `make emu_BusyBox`

#### Scenario: User runs emu from workspace root without -i
- **WHEN** user runs `kyberlab emu` from the workspace root and no specific image config directory is detected
- **THEN** the CLI SHALL execute `make emu` (default target)
- **AND** the default image build SHALL be launched in QEMU

### Requirement: Workspace context requirement
The `emu` command SHALL only work when executed within an initialized KyberLab workspace. If run outside a workspace, the CLI SHALL abort with an error instructing the user to initialize a workspace first.

#### Scenario: Emu command outside workspace
- **WHEN** user runs `kyberlab emu` in a directory that is not a KyberLab workspace
- **THEN** the CLI SHALL print an error: "Error: This command requires an initialized workspace."
- **AND** the CLI SHALL exit with non-zero status
