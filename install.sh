#!/bin/bash
#
# KyberLab Installer
# Installs the kyberlab CLI script to a system or user binary directory

set -e  # Exit on error

# Configuration
INSTALL_SCRIPT_NAME="kyberlab"
SYS_BIN_DIR="/usr/local/bin"
USER_BIN_DIR="$HOME/.local/bin"

# Defaults
INSTALL_MODE="system"  # "system" or "user"
UNINSTALL_MODE=0
FORCE_INSTALL=0
VERBOSE=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Installs the KyberLab CLI tool to the system or user's local bin directory.

Options:
  --user            Install to user directory (~/.local/bin) instead of system-wide
  --uninstall       Uninstall kyberlab from the system
  --force           Overwrite existing installation without prompting
  --verbose         Enable verbose output
  -h, --help        Show this help message and exit

Examples:
  # System-wide installation (requires sudo)
  sudo $0

  # User-only installation
  $0 --user

  # Uninstall system-wide
  sudo $0 --uninstall

  # Uninstall user-only
  $0 --uninstall --user

EOF
    exit 0
}

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --user)
                INSTALL_MODE="user"
                shift
                ;;
            --uninstall)
                UNINSTALL_MODE=1
                shift
                ;;
            --force)
                FORCE_INSTALL=1
                shift
                ;;
            --verbose)
                VERBOSE=1
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done
}

# Detect if we're running from KyberLab repo root
check_repo_root() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check for kyberlab script
    if [[ ! -f "$script_dir/kyberlab" ]]; then
        log_error "Cannot find 'kyberlab' script in current directory."
        log_error "This script must be run from the KyberLab repository root."
        exit 1
    fi

    # Check for repository markers (manifests/ or template/ or manifests/qemu/)
    if [[ ! -d "$script_dir/manifests" && ! -d "$script_dir/template" ]]; then
        log_error "Cannot find 'manifests' or 'template' directory."
        log_error "This script must be run from the KyberLab repository root."
        exit 1
    fi

    if [[ $VERBOSE -eq 1 ]]; then
        log_info "Repository root detected at: $script_dir"
    fi

    REPO_ROOT="$script_dir"
}

# Get the install directory based on mode
get_install_dir() {
    if [[ "$INSTALL_MODE" == "system" ]]; then
        echo "$SYS_BIN_DIR"
    else
        echo "$USER_BIN_DIR"
    fi
}

# Check if we can write to the install directory
check_write_permission() {
    local target_dir="$1"
    local target_file="$target_dir/$INSTALL_SCRIPT_NAME"

    # Check if directory exists and is writable
    if [[ ! -d "$target_dir" ]]; then
        # Parent directory might exist
        local parent_dir
        parent_dir="$(dirname "$target_dir")"
        if [[ ! -d "$parent_dir" ]]; then
            log_error "Parent directory $parent_dir does not exist"
            return 1
        fi
        if [[ ! -w "$parent_dir" ]]; then
            log_error "Cannot create directory $target_dir (parent not writable)"
            if [[ "$INSTALL_MODE" == "system" ]]; then
                log_error "Use sudo or run with --user for user-only installation."
            fi
            return 1
        fi
        return 0
    fi

    if [[ ! -w "$target_dir" ]]; then
        log_error "Cannot write to $target_dir (permission denied)"
        if [[ "$INSTALL_MODE" == "system" ]]; then
            log_error "Use sudo or run with --user for user-only installation."
        fi
        return 1
    fi

    # If file exists, check if we can overwrite it
    if [[ -e "$target_file" && ! -w "$target_file" ]]; then
        log_error "Cannot overwrite $target_file (permission denied)"
        if [[ "$INSTALL_MODE" == "system" ]]; then
            log_error "Use sudo or run with --user for user-only installation."
        fi
        return 1
    fi

    return 0
}

# Check if kyberlab already exists at target location
check_existing_installation() {
    local target_file="$1"

    if [[ -e "$target_file" ]]; then
        if [[ $FORCE_INSTALL -eq 1 ]]; then
            log_warn "Forcing overwrite of existing installation at $target_file"
            return 0
        fi

        log_warn "kyberlab is already installed at: $target_file"
        read -p "Overwrite? (y/N): " -r response
        case "$response" in
            [yY]|[yY][eE][sS])
                return 0
                ;;
            *)
                log_info "Installation cancelled"
                exit 0
                ;;
        esac
    fi

    return 0
}

# Check if directory is in PATH
check_path() {
    local target_dir="$1"

    # Remove trailing slash for PATH check
    target_dir="${target_dir%/}"

    # Get current PATH
    local IFS=':'
    local path_dirs=($PATH)
    unset IFS

    for dir in "${path_dirs[@]}"; do
        # Normalize paths (remove trailing slashes)
        dir="${dir%/}"
        if [[ "$dir" == "$target_dir" ]]; then
            return 0  # Found in PATH
        fi
    done

    return 1  # Not in PATH
}

# Generate shell configuration advice based on user's shell
get_shell_config_advice() {
    local shell_name
    shell_name="$(basename "$SHELL")"

    case "$shell_name" in
        bash)
            echo "Add to ~/.bashrc or ~/.bash_profile:"
            echo "  export PATH=\"$USER_BIN_DIR:\$PATH\""
            ;;
        zsh)
            echo "Add to ~/.zshrc:"
            echo "  export PATH=\"$USER_BIN_DIR:\$PATH\""
            ;;
        fish)
            echo "Add to ~/.config/fish/config.fish:"
            echo "  set -gx PATH $USER_BIN_DIR \$PATH"
            ;;
        *)
            echo "Add to your shell configuration file:"
            echo "  export PATH=\"$USER_BIN_DIR:\$PATH\""
            echo "(For bash: ~/.bashrc, for zsh: ~/.zshrc, etc.)"
            ;;
    esac
}

# Perform the installation
install_kyberlab() {
    local target_dir
    target_dir="$(get_install_dir)"
    local target_file="$target_dir/$INSTALL_SCRIPT_NAME"

    log_info "Installing KyberLab to: $target_file"

    # Ensure target directory exists
    if [[ ! -d "$target_dir" ]]; then
        log_info "Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi

    # Check write permissions
    if ! check_write_permission "$target_dir"; then
        exit 1
    fi

    # Check for existing installation
    if ! check_existing_installation "$target_file"; then
        exit 0
    fi

    # Copy the kyberlab script
    log_info "Copying kyberlab script..."
    if command -v git &> /dev/null && [[ -d "$REPO_ROOT/.git" ]]; then
        # Use git archive for clean copy without .git directory
        (
            cd "$REPO_ROOT"
            git archive HEAD kyberlab | tar -x -C "$target_dir"
        ) || {
            log_error "Failed to archive kyberlab script"
            exit 1
        }
    else
        # Direct copy if not in git repo
        cp "$REPO_ROOT/kyberlab" "$target_file" || {
            log_error "Failed to copy kyberlab script"
            exit 1
        }
    fi

    # Set executable permissions
    chmod 755 "$target_file" || {
        log_error "Failed to set executable permissions on $target_file"
        exit 1
    }

    log_success "Installed kyberlab to $target_file"

    # Verify installation
    if [[ -x "$target_file" ]]; then
        log_info "Verifying installation..."
        if "$target_file" --version &> /dev/null || "$target_file" --help &> /dev/null; then
            log_success "Installation verified successfully"
        else
            log_warn "Verification: Script is installed but execution test returned non-zero"
            log_warn "This may be expected if run from incorrect context"
        fi
    else
        log_warn "Installed file is not executable!"
    fi

    # Check PATH for user-only installation
    if [[ "$INSTALL_MODE" == "user" ]]; then
        if check_path "$target_dir"; then
            log_info "Installation directory is in your PATH"
        else
            log_warn "Note: $target_dir is NOT in your PATH"
            get_shell_config_advice
            log_warn "After updating your shell configuration, restart your shell or run: source <config-file>"
        fi
    fi

    log_info "Installation complete!"
}

# Perform uninstallation
uninstall_kyberlab() {
    local target_dir
    target_dir="$(get_install_dir)"
    local target_file="$target_dir/$INSTALL_SCRIPT_NAME"
    local metadata_file="/var/lib/kyberlab/install.meta"

    # Try to read install location from metadata (for future-proofing)
    if [[ -f "$metadata_file" ]] && [[ "$INSTALL_MODE" == "system" ]]; then
        local stored_location
        stored_location="$(grep '^INSTALL_LOCATION=' "$metadata_file" 2>/dev/null | cut -d= -f2)"
        if [[ -n "$stored_location" ]]; then
            target_file="$stored_location"
        fi
    fi

    log_info "Uninstalling KyberLab..."

    if [[ ! -e "$target_file" ]]; then
        log_warn "kyberlab not found at $target_file (may have been already removed)"
        # Try other location as fallback
        if [[ "$INSTALL_MODE" == "system" ]]; then
            if [[ -e "$USER_BIN_DIR/$INSTALL_SCRIPT_NAME" ]]; then
                log_info "Found kyberlab in user directory, removing..."
                target_file="$USER_BIN_DIR/$INSTALL_SCRIPT_NAME"
            else
                log_info "Nothing to uninstall"
                exit 0
            fi
        else
            if [[ -e "$SYS_BIN_DIR/$INSTALL_SCRIPT_NAME" ]]; then
                log_info "Found kyberlab in system directory, removing..."
                target_file="$SYS_BIN_DIR/$INSTALL_SCRIPT_NAME"
            else
                log_info "Nothing to uninstall"
                exit 0
            fi
        fi
    fi

    # Check if we can remove it
    if [[ ! -w "$(dirname "$target_file")" ]]; then
        log_error "Cannot remove $target_file (permission denied)"
        if [[ "$INSTALL_MODE" == "system" ]]; then
            log_error "Use sudo or run with --user for user-only uninstall"
        fi
        exit 1
    fi

    # Confirm removal
    if [[ $FORCE_INSTALL -eq 0 ]]; then
        read -p "Remove $target_file? (y/N): " -r response
        case "$response" in
            [yY]|[yY][eE][sS])
                ;;
            *)
                log_info "Uninstall cancelled"
                exit 0
                ;;
        esac
    fi

    rm -f "$target_file" || {
        log_error "Failed to remove $target_file"
        exit 1
    }

    # Also remove metadata file if exists
    if [[ -f "$metadata_file" ]]; then
        rm -f "$metadata_file" || true
    fi

    log_success "Uninstalled kyberlab"
    log_info "Your workspace data (build/, config/, etc.) has been preserved"
}

# Helper function for success logging
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Main execution
main() {
    parse_args "$@"

    # Check if running from repo root
    check_repo_root

    if [[ $VERBOSE -eq 1 ]]; then
        log_info "Mode: $INSTALL_MODE"
        log_info "Uninstall: $UNINSTALL_MODE"
    fi

    if [[ $UNINSTALL_MODE -eq 1 ]]; then
        uninstall_kyberlab
    else
        install_kyberlab
    fi
}

# Run main function
main "$@"
