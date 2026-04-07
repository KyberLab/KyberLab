## 1. Installer Script Development

- [x] 1.1 Create install.sh with basic structure, shebang, and argument parsing (--user, --uninstall, --help flags)
- [x] 1.2 Implement context detection: verify running from KyberLab repo root (check for kyberlab file, manifests/, template/ directories)
- [x] 1.3 Implement installation logic for system-wide mode (sudo): copy kyberlab to /usr/local/bin with executable permissions
- [x] 1.4 Implement installation logic for user-only mode: copy kyberlab to ~/.local/bin with executable permissions
- [x] 1.5 Add permission checking: detect write access to target directory, provide clear error messages with guidance
- [x] 1.6 Add existing installation detection: check if target kyberlab already exists, prompt for confirmation before overwriting
- [x] 1.7 Implement uninstall functionality: remove installed kyberlab binary from the tracked location, preserve workspace data
- [x] 1.8 Add PATH verification: check if installation directory is in PATH, output warning with shell configuration guidance if not
- [x] 1.9 Add installation verification: after copy, check file exists, is executable, and test `kyberlab --version` (or --help) passes

## 2. Testing & Validation

- [x] 2.1 Test system-wide install on Linux (Ubuntu/Debian): verify kyberlab runs from any directory without path/python prefix
- [x] 2.2 Test user-only install on Linux: verify installation to ~/.local/bin and test execution (adjust PATH if needed)
- [x] 2.3 Test uninstall (--uninstall) for both system and user modes: verify binary removed, workspaces intact
- [x] 2.4 Test permission denial scenarios: run install.sh as non-sudo to system location, verify error message and exit
- [x] 2.5 Test running from wrong directory: verify error message and exit without changes
- [x] 2.6 Test overwrite protection: existing kyberlab detected, confirm prompt works correctly
- [ ] 2.7 Test on macOS: ensure /usr/local/bin is writable with sudo, verify shebang works with system Python

## 3. Documentation

- [x] 3.1 Update README.md at repository root with installation instructions (system-wide and user-only)
- [x] 3.2 Add usage examples showing `kyberlab <command>` instead of `python3 kyberlab <command>`
- [x] 3.3 Document uninstall process and note about preserved workspace data
- [x] 3.4 Add troubleshooting section for common issues (PATH, permissions, Python version)

## 4. Final Verification

- [x] 4.1 Verify install.sh is executable (chmod +x) in the repository
- [x] 4.2 Perform end-to-end test: fresh install, use various kyberlab commands (build, emu, etc.), uninstall
- [x] 4.3 Check that no workspace or configuration data is lost during install/uninstall (build/, config/ directories remain)
- [x] 4.4 Ensure backward compatibility: existing workflows using `python3 kyberlab` still work (no changes to kyberlab script itself)
- [x] 4.5 Create test checklist for manual QA covering all specified scenarios
