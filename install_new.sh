#!/bin/bash

# Claude Model Switcher - Simplified Installation Script
# Version 5.0.0 - Modular Architecture
# This script bootstraps the modular installation system

set -e

# Script metadata
SCRIPT_VERSION="5.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_TARGET="$HOME/.claude/claude-model-switcher"

# Simple logging for bootstrap
log_info() {
    echo "ℹ️  $1"
}

log_success() {
    echo "✅ $1"
}

log_error() {
    echo "❌ $1"
}

log_progress() {
    echo "🚀 $1"
}

# Bootstrap installation
bootstrap_install() {
    log_info "Claude Model Switcher v$SCRIPT_VERSION - Modular Installation"
    echo "================================================================="
    
    # Check if we're running from the correct location
    if [ ! -f "$SCRIPT_DIR/main.sh" ]; then
        log_error "main.sh not found. Please ensure you're running from the correct directory."
        exit 1
    fi
    
    # Check if already installed
    if [ -d "$INSTALL_TARGET" ] && [ -f "$INSTALL_TARGET/main.sh" ]; then
        log_info "Existing installation detected at: $INSTALL_TARGET"
        echo -n "Do you want to update the existing installation? [y/N]: "
        read -r update_choice
        
        case "$update_choice" in
            [yY]|[yY][eS]|[yY][eE][sS])
                log_progress "Updating existing installation..."
                ;;
            *)
                log_info "Installation cancelled by user"
                exit 0
                ;;
        esac
    fi
    
    # Create installation directory
    log_progress "Creating installation directory: $INSTALL_TARGET"
    mkdir -p "$INSTALL_TARGET"
    
    # Copy all files to installation directory
    log_progress "Copying modular system files..."
    cp -r "$SCRIPT_DIR"/* "$INSTALL_TARGET/"
    
    # Make scripts executable
    chmod +x "$INSTALL_TARGET/main.sh"
    chmod +x "$INSTALL_TARGET/tests/test_runner.sh"
    
    log_success "Modular system files copied successfully"
    
    # Run the modular installation
    log_progress "Running modular installation process..."
    cd "$INSTALL_TARGET"
    
    if ./main.sh install; then
        log_success "Installation completed successfully!"
        echo ""
        log_info "The modular system is now installed at: $INSTALL_TARGET"
        log_info "You can manage it using: $INSTALL_TARGET/main.sh [command]"
        echo ""
        log_info "Quick start:"
        log_info "1. Source your shell configuration: source ~/.bashrc"
        log_info "2. List models: list_models"
        log_info "3. Use a model: use_model kimi"
    else
        log_error "Installation failed!"
        exit 1
    fi
}

# Uninstall function
uninstall() {
    log_info "Uninstalling Claude Model Switcher..."
    
    if [ -d "$INSTALL_TARGET" ] && [ -f "$INSTALL_TARGET/main.sh" ]; then
        log_progress "Running modular uninstallation..."
        cd "$INSTALL_TARGET"
        ./main.sh uninstall
    else
        log_info "Modular system not found, cleaning up manually..."
        
        # Manual cleanup for legacy installations
        local shell_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
        for shell_file in "${shell_files[@]}"; do
            if [ -f "$shell_file" ] && grep -q "CLAUDE_CODE_MODEL_MANAGER" "$shell_file"; then
                log_progress "Cleaning shell configuration: $shell_file"
                # Create backup
                cp "$shell_file" "${shell_file}.cleanup_backup.$(date +%Y%m%d_%H%M%S)"
                # Remove old configuration blocks (both V4 and V5)
                sed -i '/# CLAUDE_CODE_MODEL_MANAGER/,/# END_OF_CLAUDE_CONFIG/d' "$shell_file"
            fi
        done
        
        # Remove installation directory
        if [ -d "$INSTALL_TARGET" ]; then
            rm -rf "$INSTALL_TARGET"
            log_success "Installation directory removed"
        fi
        
        # Remove parent directory if empty
        local parent_dir
        parent_dir=$(dirname "$INSTALL_TARGET")
        if [ -d "$parent_dir" ] && [ -z "$(ls -A "$parent_dir" 2>/dev/null)" ]; then
            rmdir "$parent_dir"
        fi
    fi
    
    log_success "Uninstallation completed"
    log_info "Please restart your terminal for changes to take effect"
}

# Show help
show_help() {
    cat << EOF
Claude Model Switcher v$SCRIPT_VERSION - Installation Script

USAGE:
    $0 [OPTION]

OPTIONS:
    (no option)    Install or update Claude Model Switcher
    --uninstall    Remove Claude Model Switcher completely
    --help         Show this help message

DESCRIPTION:
    This script installs the modular Claude Model Switcher system.
    The system will be installed to: $INSTALL_TARGET

FEATURES:
    • Modular architecture with clean separation of concerns
    • Configuration-driven (no hardcoded values)
    • Comprehensive test suite with TDD/BDD support
    • Support for multiple AI model providers
    • Automatic shell integration
    • Safe installation with backups

EXAMPLES:
    $0                 # Install or update
    $0 --uninstall     # Complete removal
    $0 --help          # Show this help

After installation, you can use:
    list_models        # List available models
    use_model <alias>  # Switch to a model
    
Or use the full CLI:
    $INSTALL_TARGET/main.sh [command]

EOF
}

# Main execution
main() {
    local command="${1:-install}"
    
    case "$command" in
        "install"|"")
            bootstrap_install
            ;;
        "--uninstall")
            uninstall
            ;;
        "--help"|"-h")
            show_help
            ;;
        *)
            log_error "Unknown option: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
