#!/bin/bash

# Claude Model Switcher - Main Entry Point
# Version 5.0.0 - Modular Architecture
# A robust installer and manager for Claude Code with multi-model support

set -e

# --- Script Metadata ---
SCRIPT_VERSION="5.0.0"
SCRIPT_NAME="Claude Model Switcher"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Bootstrap Configuration ---
# Load base configuration to get directory paths
if [ -f "$SCRIPT_DIR/config/app.conf" ]; then
    source "$SCRIPT_DIR/config/app.conf"
else
    echo "❌ Error: Configuration file not found: $SCRIPT_DIR/config/app.conf"
    echo "Please ensure the script is run from the correct directory."
    exit 1
fi

# --- Module Loading ---
# Load core modules
source "$SCRIPT_DIR/lib/core/logger.sh"
source "$SCRIPT_DIR/lib/core/config_loader.sh"
source "$SCRIPT_DIR/lib/core/validator.sh"

# Load installer modules
source "$SCRIPT_DIR/lib/installers/nodejs_installer.sh"
source "$SCRIPT_DIR/lib/installers/claude_installer.sh"

# Load manager modules
source "$SCRIPT_DIR/lib/managers/model_manager.sh"

# --- Initialization ---
initialize_system() {
    # Initialize logger
    logger_init
    
    log_header "$SCRIPT_NAME v$SCRIPT_VERSION"
    log_info "Initializing modular system..."
    
    # Load all configurations
    if ! config_load_all "$SCRIPT_DIR/config"; then
        log_error "Failed to load configurations"
        return 1
    fi
    
    # Validate environment
    if ! config_validate_environment; then
        log_error "Environment validation failed"
        return 1
    fi
    
    log_success "System initialization completed"
    return 0
}

# --- Command Functions ---

# Install command - Full installation process
cmd_install() {
    log_header "Full Installation Process"
    
    # Validate system requirements
    if ! validate_system_requirements; then
        log_error "System requirements not met"
        return 1
    fi
    
    # Install Node.js if needed
    log_progress "Step 1: Node.js Installation"
    if ! install_nodejs; then
        log_error "Node.js installation failed"
        return 1
    fi
    
    # Install Claude Code
    log_progress "Step 2: Claude Code Installation"
    if ! install_claude_code; then
        log_error "Claude Code installation failed"
        return 1
    fi
    
    # Setup shell integration
    log_progress "Step 3: Shell Integration Setup"
    if ! setup_shell_integration; then
        log_error "Shell integration setup failed"
        return 1
    fi
    
    # Display completion message
    display_installation_complete
    
    return 0
}

# Setup shell integration
setup_shell_integration() {
    log_progress "Setting up shell integration..."
    
    # Detect shell
    local current_shell
    current_shell=$(basename "$SHELL")
    local rc_file
    
    case "$current_shell" in
        bash) rc_file="$HOME/.bashrc" ;;
        zsh) rc_file="$HOME/.zshrc" ;;
        *) rc_file="$HOME/.profile" ;;
    esac
    
    log_info "Detected shell: $current_shell"
    log_info "Configuration file: $rc_file"
    
    # Create backup
    if [ -f "$rc_file" ]; then
        local backup_file="$rc_file.claude_backup.$(date +%Y%m%d_%H%M%S)"
        if cp "$rc_file" "$backup_file"; then
            log_success "Backup created: $backup_file"
        else
            log_warn "Failed to create backup"
        fi
        
        # Remove old configuration block
        sed -i "/$SHELL_CONFIG_MARKER/,/$SHELL_CONFIG_END_MARKER/d" "$rc_file"
    fi
    
    # Add new configuration block
    local shell_config
    shell_config=$(cat << 'EOF'

# CLAUDE_CODE_MODEL_MANAGER_V5
# --- Claude Model Switcher (Modular Architecture) ---
# This block is managed automatically by the installation script.

# Define paths for the switcher's files.
export CLAUDE_SWITCHER_DIR="$HOME/.claude/claude-model-switcher"
export CLAUDE_MODELS_CONF="$CLAUDE_SWITCHER_DIR/config/models.conf"

# Load the modular system
if [ -f "$CLAUDE_SWITCHER_DIR/main.sh" ]; then
    # Source configuration
    [ -f "$CLAUDE_SWITCHER_DIR/config/app.conf" ] && source "$CLAUDE_SWITCHER_DIR/config/app.conf"
    [ -f "$CLAUDE_SWITCHER_DIR/config/providers.conf" ] && source "$CLAUDE_SWITCHER_DIR/config/providers.conf"
    
    # Pre-declare associative arrays before loading models.conf
    declare -gA MODEL_PROVIDERS 2>/dev/null || true
    declare -gA MODEL_API_NAMES 2>/dev/null || true
    declare -gA MODEL_CONTEXTS 2>/dev/null || true
    declare -gA MODEL_SMALL_FAST_NAMES 2>/dev/null || true
    declare -gA MODEL_DESCRIPTIONS 2>/dev/null || true
    declare -gA MODEL_CAPABILITIES 2>/dev/null || true
    
    [ -f "$CLAUDE_SWITCHER_DIR/config/models.conf" ] && source "$CLAUDE_SWITCHER_DIR/config/models.conf"
    
    # Source core modules
    [ -f "$CLAUDE_SWITCHER_DIR/lib/core/logger.sh" ] && source "$CLAUDE_SWITCHER_DIR/lib/core/logger.sh"
    [ -f "$CLAUDE_SWITCHER_DIR/lib/core/config_loader.sh" ] && source "$CLAUDE_SWITCHER_DIR/lib/core/config_loader.sh"
    [ -f "$CLAUDE_SWITCHER_DIR/lib/core/validator.sh" ] && source "$CLAUDE_SWITCHER_DIR/lib/core/validator.sh"
    [ -f "$CLAUDE_SWITCHER_DIR/lib/managers/model_manager.sh" ] && source "$CLAUDE_SWITCHER_DIR/lib/managers/model_manager.sh"
    
    # Initialize logger for shell functions
    logger_init >/dev/null 2>&1
    
    # Load persisted environment variables if available
    if declare -f load_persisted_env_vars >/dev/null 2>&1; then
        load_persisted_env_vars >/dev/null 2>&1 || true
    fi
fi

# Shell functions for user interaction
list_models() {
    # Check if the modular system is loaded
    if [ -f "$CLAUDE_SWITCHER_DIR/main.sh" ] && declare -f list_models_impl >/dev/null 2>&1; then
        list_models_impl "$@"
    else
        echo "❌ Claude Model Switcher not properly installed"
        echo "💡 Try running: source ~/.bashrc"
        return 1
    fi
}

use_model() {
    # Check if the modular system is loaded  
    if [ -f "$CLAUDE_SWITCHER_DIR/main.sh" ] && declare -f use_model_impl >/dev/null 2>&1; then
        use_model_impl "$@"
    else
        echo "❌ Claude Model Switcher not properly installed"
        echo "💡 Try running: source ~/.bashrc"
        return 1
    fi
}

# END_OF_CLAUDE_CONFIG
EOF
    )
    
    # Append configuration
    if echo "$shell_config" >> "$rc_file"; then
        log_success "Shell integration configured: $rc_file"
        return 0
    else
        log_error "Failed to configure shell integration"
        return 1
    fi
}

# Display installation complete message
display_installation_complete() {
    log_header "Installation Complete!"
    
    echo ""
    log_success "🎉 Claude Model Switcher v$SCRIPT_VERSION is ready!"
    echo ""
    
    log_info "Next Steps:"
    log_indent info "1. Refresh your environment:" 2
    log_indent info "   source ~/.bashrc  # or ~/.zshrc" 4
    echo ""
    
    log_indent info "2. List available models:" 2
    log_indent info "   list_models" 4
    echo ""
    
    log_indent info "3. Switch to a model:" 2
    log_indent info "   use_model kimi" 4
    log_indent info "   use_model glm4" 4
    echo ""
    
    log_indent info "4. Start using Claude Code:" 2
    log_indent info "   claude \"your prompt here\"" 4
    echo ""
    
    log_info "Configuration Files:"
    log_indent info "• Models: $MODEL_CONFIG_FILE" 2
    log_indent info "• Providers: $PROVIDERS_CONFIG_FILE" 2
    log_indent info "• Application: $SCRIPT_DIR/config/app.conf" 2
    echo ""
    
    log_info "For help: $SCRIPT_DIR/main.sh --help"
}

# Uninstall command
cmd_uninstall() {
    log_header "Uninstallation Process"
    
    echo "This will remove Claude Model Switcher and all its components."
    echo -n "Are you sure you want to continue? [y/N]: "
    read -r confirmation
    
    case "$confirmation" in
        [yY]|[yY][eE][sS])
            log_progress "Proceeding with uninstallation..."
            ;;
        *)
            log_info "Uninstallation cancelled"
            return 0
            ;;
    esac
    
    # Remove shell integration
    local current_shell
    current_shell=$(basename "$SHELL")
    local rc_file
    
    case "$current_shell" in
        bash) rc_file="$HOME/.bashrc" ;;
        zsh) rc_file="$HOME/.zshrc" ;;
        *) rc_file="$HOME/.profile" ;;
    esac
    
    if [ -f "$rc_file" ]; then
        if grep -q "$SHELL_CONFIG_MARKER" "$rc_file"; then
            log_progress "Removing shell integration..."
            
            # Create backup
            local backup_file="$rc_file.uninstall_backup.$(date +%Y%m%d_%H%M%S)"
            cp "$rc_file" "$backup_file"
            
            # Remove configuration block
            sed -i "/$SHELL_CONFIG_MARKER/,/$SHELL_CONFIG_END_MARKER/d" "$rc_file"
            log_success "Shell integration removed. Backup: $backup_file"
        fi
    fi
    
    # Remove switcher directory
    if [ -d "$SWITCHER_DIR" ]; then
        log_progress "Removing switcher directory: $SWITCHER_DIR"
        rm -rf "$SWITCHER_DIR"
        
        # After removing the directory, disable file logging to avoid errors
        # since the log directory no longer exists
        export LOGGER_FILE=""
        
        log_success "Switcher directory removed"
    fi
    
    # Optionally remove Claude Code (ask user)
    echo -n "Do you want to remove Claude Code CLI as well? [y/N]: "
    read -r remove_claude
    
    case "$remove_claude" in
        [yY]|[yY][eE][sS])
            uninstall_claude_code "" "true"
            ;;
        *)
            log_info "Claude Code CLI preserved"
            ;;
    esac
    
    log_success "🎉 Uninstallation completed successfully"
    log_info "Please restart your terminal for changes to take effect"
    
    return 0
}

# Status command
cmd_status() {
    log_header "System Status"
    
    # System requirements
    log_progress "Checking system requirements..."
    validate_system_requirements
    echo ""
    
    # Node.js status
    log_progress "Checking Node.js..."
    if validate_nodejs; then
        local node_version
        node_version=$(node -v 2>/dev/null)
        log_success "Node.js: $node_version"
    else
        log_warn "Node.js: Not installed or version too old"
    fi
    echo ""
    
    # Claude Code status
    log_progress "Checking Claude Code..."
    if validate_claude_code; then
        local claude_version
        claude_version=$(claude --version 2>/dev/null)
        log_success "Claude Code: $claude_version"
    else
        log_warn "Claude Code: Not installed"
    fi
    echo ""
    
    # Model configuration
    log_progress "Checking model configuration..."
    get_model_status
    echo ""
    
    # Configuration files
    log_progress "Checking configuration files..."
    local config_files=(
        "$SCRIPT_DIR/config/app.conf"
        "$SCRIPT_DIR/config/models.conf"
        "$SCRIPT_DIR/config/providers.conf"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            log_indent success "$(basename "$config_file"): Found" 2
        else
            log_indent error "$(basename "$config_file"): Missing" 2
        fi
    done
    
    return 0
}

# Help command
cmd_help() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION - Modular Architecture

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    install         Full installation process (Node.js + Claude Code + Shell integration)
    uninstall       Remove Claude Model Switcher and optionally Claude Code
    status          Show system and component status
    list-models     List all available models
    use-model       Switch to a specific model
    add-model       Add a new model to configuration
    remove-model    Remove a model from configuration
    update          Update Claude Code to latest version
    test            Run system tests
    help            Show this help message

EXAMPLES:
    # Full installation
    $0 install

    # List available models
    $0 list-models

    # Switch to a model
    $0 use-model kimi

    # Add a custom model
    $0 add-model my-model openai gpt-4 gpt-3.5-turbo "8K tokens" "Custom GPT-4 configuration"

    # Check system status
    $0 status

    # Uninstall everything
    $0 uninstall

SHELL FUNCTIONS (available after installation):
    list_models     List available models
    use_model       Switch to a model

CONFIGURATION:
    • Application: $SCRIPT_DIR/config/app.conf
    • Models: $SCRIPT_DIR/config/models.conf
    • Providers: $SCRIPT_DIR/config/providers.conf

For more information, visit: https://github.com/your-repo/claude-model-switcher
EOF
}

# --- Command Line Interface ---

# Parse command line arguments
parse_arguments() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "install")
            cmd_install "$@"
            ;;
        "uninstall")
            cmd_uninstall "$@"
            ;;
        "status")
            cmd_status "$@"
            ;;
        "list-models")
            list_models_impl "$@"
            ;;
        "use-model")
            use_model_impl "$@"
            ;;
        "add-model")
            add_model "$@"
            ;;
        "remove-model")
            remove_model "$@"
            ;;
        "update")
            update_claude_code "$@"
            ;;
        "test")
            cmd_test "$@"
            ;;
        "help"|"--help"|"-h")
            cmd_help
            ;;
        *)
            log_error "Unknown command: $command"
            echo ""
            cmd_help
            exit 1
            ;;
    esac
}

# Test command
cmd_test() {
    log_header "System Tests"
    
    local errors=0
    
    # Test Node.js
    if ! test_nodejs_installation; then
        ((errors++))
    fi
    echo ""
    
    # Test Claude Code
    if ! test_claude_installation; then
        ((errors++))
    fi
    echo ""
    
    # Test configuration
    log_progress "Testing configuration..."
    if ! validate_configuration_completeness; then
        ((errors++))
    fi
    echo ""
    
    if [ $errors -eq 0 ]; then
        log_success "🎉 All tests passed!"
        return 0
    else
        log_error "❌ Tests failed with $errors errors"
        return 1
    fi
}

# --- Main Execution ---

main() {
    # Initialize system
    if ! initialize_system; then
        echo "❌ Failed to initialize system"
        exit 1
    fi
    
    # Parse and execute command
    parse_arguments "$@"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

