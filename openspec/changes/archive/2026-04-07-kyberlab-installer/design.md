## Context

KyberLab is a Python-based CLI tool for embedded systems development. Currently, users must either:
1. Run `python3 kyberlab <command>` from the repository root
2. Add the repository to their PATH and run `kyberlab` (still requires python3 prefix if the shebang doesn't work)

This creates friction and doesn't match the experience of standard CLI tools (like `git`, `make`, `docker`) that can be invoked directly from any directory.

## Goals / Non-Goals

**Goals:**
- Create a simple, user-friendly installer script (`install.sh`)
- Install kyberlab script to a standard system location (/usr/local/bin)
- Support both system-wide and user-only installation modes
- Provide clean uninstall/rollback capability
- Work on Linux and macOS systems
- Verify installation success

**Non-Goals:**
- Modify the kyberlab CLI itself
- Create a formal Python package for pip installation
- Handle complex dependency management (kyberlab uses only Python stdlib)
- Support Windows systems
- Integrate with system package managers (apt, yum, brew)

## Decisions

### 1. Installer Script Language: Bash

**Decision**: Use Bash for the installer script.

**Rationale**:
- Bash is universally available on Linux/macOS
- Well-suited for file operations, permission management, and system integration
- Can easily handle sudo/non-sudo scenarios
- Matches conventions of other open-source tools (Docker, kubectl, etc.)

**Alternatives Considered**:
- Python: Would require Python to be installed (already a requirement), but adds unnecessary complexity for simple file copy operations
- Makefile: Not as user-friendly for end users

### 2. Installation Location: /usr/local/bin (default)

**Decision**: Default installation to `/usr/local/bin/`, with fallback to user's local bin directory (`~/.local/bin`) if system install fails or is not desired.

**Rationale**:
- `/usr/local/bin` is the standard location for locally-installed executables on Unix-like systems
- It's typically on the PATH for all users
- `/usr/bin` is reserved for distribution-managed packages
- `~/.local/bin` provides a user-only option that doesn't require sudo

**Alternatives Considered**:
- `/opt/kyberlab/bin`: Would require manual PATH modification
- Custom location via flag: Keeps flexibility but complicates UX

### 3. Dependency Management: No-op

**Decision**: The installer will NOT install Python dependencies.

**Rationale**:
- KyberLab CLI uses only Python standard library modules (os, sys, subprocess, argparse, shutil)
- No external Python packages are required
- Build dependencies (git, repo, make, docker) are already checked by kyberlab at runtime and documented separately
- Simpler installer with fewer failure points

### 4. Installation Method: Binary Copy with Metadata

**Decision**: Copy the kyberlab script (after optional git archive) and record installation metadata for uninstall.

**Rationale**:
- Simple and reliable
- Metadata tracking (install location, timestamp) enables clean uninstall
- Git archive ensures clean copy without .git directory
- Preserves shebang (`#!/usr/bin/env python3`) for Python auto-detection

### 5. Uninstall: Remove installed file only

**Decision**: Uninstall removes the installed kyberlab binary but preserves user data (workspaces, configs).

**Rationale**:
- Follows principle of least surprise - uninstall removes installed files, not user data
- User workspaces in `build/` and configs in `config/` are valuable and should persist
- Simple implementation: just delete the installed binary

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| User runs install.sh from wrong directory (not repo root) | Script will detect and abort with clear error |
| Permission denied writing to /usr/local/bin | Script detects and suggests using sudo or user-only mode |
| Overwrites existing kyberlab installation | Script will prompt for confirmation (or use --force) |
| PATH doesn't include install location | Script checks and warns user if kyberlab won't be found |
| Multiple Python versions (pyenv, conda) interfering | Uses `#!/usr/bin/env python3` to respect user's environment |
| macOS differences (brew Python locations) | Test on both Linux and macOS; shebang should work on both |

**Trade-offs**:
- Simplicity over sophistication: No dependency resolution, no package manager integration
- Manual updates: Users must re-run installer to update kyberlab CLI (future improvement could add `--upgrade` flag)

## Migration Plan

### Deployment Steps:
1. Create `install.sh` script with all features
2. Test on clean Linux (Ubuntu/Debian) and macOS systems
3. Test both system-wide and user-only modes
4. Add installation instructions to README.md
5. Announce to users

### Rollback Strategy:
- User runs: `install.sh --uninstall`
- Script removes installed binary (tracked via metadata file or default location)
- User can still manually remove if needed

### Open Questions
- Should install.sh be executable by default in git? (Yes, should have +x)
- Should we add version checking? (Potentially, to prevent downgrades)
- Should we validate Python version (>=3.8?) at install time or defer to runtime? (Defer to runtime for simpler installer)
