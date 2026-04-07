# KyberLab Installer Test Checklist

## Pre-Test Setup
- [ ] Fresh test environment (clean workspace)
- [ ] Installer script present at repository root: `install.sh`
- [ ] Installer is executable: `ls -l install.sh` shows `-rwxr-xr-x`
- [ ] KyberLab repository root contains `kyberlab` script, `manifests/`, and `template/`

## Functional Tests

### 1. Installation Modes

#### 1.1 System-wide Installation
- [ ] Run: `sudo ./install.sh --force`
- [ ] Output shows success: "Installed kyberlab to /usr/local/bin/kyberlab"
- [ ] File exists: `/usr/local/bin/kyberlab`
- [ ] File is executable: `ls -l /usr/local/bin/kyberlab`
- [ ] Can run from any directory: `kyberlab help` (works from /tmp or other dir)
- [ ] Uninstall: `sudo ./install.sh --uninstall --force`
- [ ] File removed: `/usr/local/bin/kyberlab` no longer exists

#### 1.2 User-only Installation
- [ ] Run: `./install.sh --user --force`
- [ ] Output shows success with correct path
- [ ] File exists: `~/.local/bin/kyberlab`
- [ ] File is executable
- [ ] Can run from any directory (ensure ~/.local/bin in PATH): `kyberlab help`
- [ ] Uninstall: `./install.sh --uninstall --user --force`
- [ ] File removed: `~/.local/bin/kyberlab` no longer exists

### 2. Context Detection

- [ ] Run install from non-repo directory: `cd /tmp && /path/to/kyberlab/install.sh`
- [ ] Error: "This script must be run from the KyberLab repository root"
- [ ] Exit code is non-zero
- [ ] No files installed

### 3. Permission Handling

#### 3.1 System install without sudo
- [ ] As non-root (no sudo), run: `./install.sh`
- [ ] Error: "Permission denied. Use 'sudo ./install.sh'..."
- [ ] Exit code is non-zero
- [ ] No files installed

#### 3.2 User install (should always work)
- [ ] Run: `./install.sh --user`
- [ ] Succeeds without sudo
- [ ] File installed to `~/.local/bin`

### 4. Existing Installation Handling

#### 4.1 Overwrite Prompt (decline)
- [ ] Install once: `./install.sh --user --force`
- [ ] Run again: `./install.sh --user` (without --force)
- [ ] Prompt appears: "kyberlab is already installed... Overwrite? (y/N)"
- [ ] Type "n" and press Enter
- [ ] Output: "Installation cancelled"
- [ ] Exit code is 0
- [ ] Existing file remains unchanged

#### 4.2 Overwrite with --force
- [ ] Run: `./install.sh --user --force`
- [ ] No prompt
- [ ] Output shows: "Forcing overwrite..."
- [ ] File timestamp updated

### 5. Uninstall Behavior

#### 5.1 Workspace Preservation
- [ ] Ensure workspace directories exist: `build/`, `config/`
- [ ] Install: `./install.sh --user --force`
- [ ] Note timestamps or contents of workspace dirs
- [ ] Uninstall: `./install.sh --uninstall --user --force`
- [ ] Output: "Your workspace data (build/, config/, etc.) has been preserved"
- [ ] Verify `build/`, `config/` directories still exist and unchanged

#### 5.2 Uninstall non-existent installation
- [ ] Ensure no kyberlab installed at target location
- [ ] Run: `./install.sh --uninstall --user`
- [ ] Output: warning "kyberlab not found" or "Nothing to uninstall"
- [ ] Exit code is 0

### 6. PATH Verification (User Install Only)

- [ ] Temporarily remove `~/.local/bin` from PATH: `export PATH=$(echo $PATH | tr ':' '\n' | grep -v "$HOME/.local/bin" | paste -sd: -)`
- [ ] Run: `./install.sh --user --force`
- [ ] Output includes warning: "~/.local/bin is NOT in your PATH"
- [ ] Output shows shell-specific configuration command
- [ ] Restore PATH

## Cross-Platform Tests

### 7. macOS Tests (if available)

- [ ] Run system install: `sudo ./install.sh`
- [ ] Successfully installs to `/usr/local/bin`
- [ ] File is executable
- [ ] Shebang `#!/usr/bin/env python3` resolves to system Python 3.8+
- [ ] Run: `/usr/local/bin/kyberlab help` (works)
- [ ] Uninstall: `sudo ./install.sh --uninstall`

## Backward Compatibility

### 8. Legacy Workflow

- [ ] Ensure `python3 kyberlab help` still works from repository root (no changes to kyberlab script)
- [ ] All existing commands using `python3 kyberlab` continue to function

## Installation Verification

### 9. Verification Logic

- [ ] After install, script checks: file exists
- [ ] After install, script checks: file is executable
- [ ] After install, script attempts to run kyberlab --version or --help
- [ ] If execution test fails (expected outside workspace), warning is shown but install still succeeds
- [ ] After uninstall, script verifies file was removed

## Documentation

### 10. README.md

- [ ] Installation section exists with system-wide and user-only instructions
- [ ] Examples show `kyberlab <command>` (not `python3 kyberlab`)
- [ ] Uninstall instructions included
- [ ] Troubleshooting section covers:
  - [ ] PATH issues
  - [ ] Permission denied
  - [ ] Verification failures
  - [ ] Python version
- [ ] Notes that uninstall preserves workspace data

### 11. Other Documentation

- [ ] CHANGELOG or release notes updated (if applicable)
- [ ] Any migration guides updated (if applicable)

## Edge Cases

### 12. Install Script Itself

- [ ] `install.sh` has executable bit set in git (`git ls-files --stage | grep install.sh` shows mode 100755)
- [ ] Shebang is `#!/bin/bash` (not `#!/usr/bin/env bash`)
- [ ] Script handles `--help` flag correctly
- [ ] Script handles unknown flags with error message

### 13. Error Handling

- [ ] All errors output to stderr
- [ ] Exit codes: 0 for success, non-zero for failures
- [ ] Error messages are clear and actionable

---

## Sign-off

Tested by: ___________________
Date: ___________________
Environment: ___________________

**Result:** 
- [ ] All tests passed
- [ ] Some tests failed (see notes below)

**Notes:**
