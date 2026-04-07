## ADDED Requirements

### Requirement: Install kyberlab to system binary directory
The system SHALL provide an installer that copies the kyberlab script to a standard binary directory (e.g., /usr/local/bin or ~/.local/bin) so that it can be executed from any location without specifying a path.

#### Scenario: System-wide installation to /usr/local/bin with sudo
- **WHEN** user runs `sudo ./install.sh` from the KyberLab repository root
- **THEN** the kyberlab script SHALL be copied to `/usr/local/bin/kyberlab`
- **AND** the file permissions SHALL be set to executable (chmod +x)
- **AND** the installer SHALL output confirmation: "kyberlab installed to /usr/local/bin/kyberlab"

#### Scenario: User-only installation without sudo
- **WHEN** user runs `./install.sh --user` from the KyberLab repository root
- **THEN** the kyberlab script SHALL be copied to `~/.local/bin/kyberlab`
- **AND** the file permissions SHALL be set to executable
- **AND** the installer SHALL output confirmation with the install location
- **AND** the installer SHALL warn if `~/.local/bin` is not in the user's PATH

### Requirement: Verify installation success
The installer SHALL verify that the installation was successful and provide clear feedback to the user.

#### Scenario: Verify installation by checking file exists and is executable
- **WHEN** the installer completes copying the kyberlab script
- **THEN** the installer SHALL check that the target file exists
- **AND** the installer SHALL check that the file is executable
- **AND** the installer SHALL run `kyberlab --version` (or similar) to confirm it executes correctly
- **AND** the installer SHALL output "Installation verified successfully" or an appropriate error message

### Requirement: Provide uninstall capability
The installer SHALL provide an `--uninstall` option that removes the installed kyberlab binary.

#### Scenario: Uninstall system-wide installation
- **WHEN** user runs `sudo ./install.sh --uninstall`
- **THEN** the installer SHALL remove `/usr/local/bin/kyberlab` (or the tracked installation location)
- **AND** the installer SHALL output "kyberlab uninstalled successfully"
- **AND** user workspace data (build/, config/, etc.) SHALL remain untouched

#### Scenario: Uninstall user-only installation
- **WHEN** user runs `./install.sh --uninstall --user`
- **THEN** the installer SHALL remove `~/.local/bin/kyberlab`
- **AND** the installer SHALL output confirmation

### Requirement: Detect and verify execution context
The installer SHALL verify it is being run from the KyberLab repository root and abort with a clear error message otherwise.

#### Scenario: Running installer from repository root
- **WHEN** user runs `./install.sh` from the KyberLab repository root directory (where the kyberlab script and manifests/ exist)
- **THEN** the installer SHALL detect the presence of the kyberlab script and repository markers
- **AND** the installer SHALL proceed with installation

#### Scenario: Running installer from wrong directory
- **WHEN** user runs `./install.sh` from a directory that is not the KyberLab repository root
- **THEN** the installer SHALL output an error: "This script must be run from the KyberLab repository root"
- **AND** the installer SHALL exit with non-zero status code
- **AND** no files SHALL be copied

### Requirement: Handle permission errors gracefully
The installer SHALL detect insufficient permissions and provide actionable guidance.

#### Scenario: System install without sufficient permissions
- **WHEN** user runs `./install.sh` (without sudo) and the default system location requires elevated permissions
- **THEN** the installer SHALL detect the permission failure
- **AND** the installer SHALL output: "Permission denied. Use 'sudo ./install.sh' for system-wide install, or './install.sh --user' for user-only install"
- **AND** the installer SHALL exit with non-zero status

### Requirement: Prevent accidental overwrites
The installer SHALL check for existing kyberlab installations and prompt for confirmation before overwriting.

#### Scenario: Existing installation detected
- **WHEN** the target location already contains a kyberlab executable
- **THEN** the installer SHALL output: "kyberlab is already installed at <location>. Overwrite? (y/N)"
- **AND** the installer SHALL wait for user input
- **AND** only if user confirms with 'y' or 'yes' SHALL the installer proceed
- **AND** if user declines, the installer SHALL exit without making changes

### Requirement: Update PATH guidance
The installer SHALL check whether the installation directory is in the user's PATH and provide guidance if not.

#### Scenario: Installation directory not in PATH (user-only mode)
- **WHEN** user runs `./install.sh --user` and `~/.local/bin` is not in the PATH
- **THEN** the installer SHALL detect that the install location is not in PATH
- **AND** the installer SHALL output a warning: "Note: ~/.local/bin is not in your PATH. Add it to your shell configuration:"
- **AND** the installer SHALL provide the appropriate shell configuration command (e.g., `export PATH="$HOME/.local/bin:$PATH"`)
