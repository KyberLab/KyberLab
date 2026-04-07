## Why

KyberLab currently requires users to run commands with `python3 kyberlab <command>` or to provide the full path to the kyberlab script. This creates friction in the developer experience and makes KyberLab feel less like a native CLI tool. An installer script would enable system-wide installation with simple `kyberlab <command>` usage from any directory, lowering the barrier to entry and improving workflow efficiency.

## What Changes

- Add `install.sh` script that:
  - Copies the kyberlab CLI script to `/usr/local/bin/` (or user-specified location)
  - Sets appropriate permissions (executable)
  - Optionally installs Python dependencies if needed
  - Provides an uninstall option for rollback
  - Supports both system-wide (sudo) and user-only installation
  - Includes verification to confirm successful installation
- Update documentation with installation instructions
- No changes to kyberlab CLI functionality itself

## Capabilities

### New Capabilities
- `system-installer`: Provides one-command installation of KyberLab to the system, enabling `kyberlab` to be run from anywhere without path or python prefixes.

### Modified Capabilities
(None)

## Impact

- **Code affected**: New `install.sh` script at repository root
- **APIs affected**: None
- **Dependencies**: Standard Linux/Unix environment with Python 3, standard file system permissions
- **Systems**: Linux/macOS systems where KyberLab is used
- **Users**: All KyberLab users benefit from simplified installation and usage

## Rollback Plan

The installer will include an `--uninstall` flag that:
- Removes the installed kyberlab binary from the target directory
- Preserves any user configuration/data in workspace directories
- Provides clear output about what was removed

## Affected Teams

- Embedded systems developers using KyberLab
- DevOps engineers setting up build environments
- CI/CD pipelines that could use the installer for automated setup
- New users onboarding to KyberLab
