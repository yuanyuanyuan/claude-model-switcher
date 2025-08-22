#!/bin/bash

# Claude Model Switcher - Simplified Installation Script
# Version 5.0.0 - Modular Architecture
# This script bootstraps the modular installation system

set -e

# Script metadata
SCRIPT_VERSION="5.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_INSTALL_TARGET="/root/claude-model-switcher"
INSTALL_TARGET="${CLAUDE_INSTALL_DIR:-$DEFAULT_INSTALL_TARGET}"

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

log_warning() {
    echo "⚠️  $1"
}

log_progress() {
    echo "🚀 $1"
}

log_debug() {
    if [ "${DEBUG:-0}" -eq 1 ]; then
        echo "🐛 $1"
    fi
}

# Parse exclusion rules from file
parse_exclusion_file() {
    local exclude_file="${1:-.claude-exclude}"
    local -n exclusion_rules_ref="$2"
    
    if [ ! -f "$exclude_file" ]; then
        log_debug "Exclusion file not found: $exclude_file"
        return 0
    fi
    
    log_info "Loading exclusion rules from: $exclude_file"
    local line_count=0
    local rule_count=0
    
    while IFS= read -r line || [ -n "$line" ]; do
        line_count=$((line_count + 1))
        
        # Remove leading/trailing whitespace
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        # Skip empty lines and comments
        if [ -z "$line" ] || [[ "$line" =~ ^# ]]; then
            continue
        fi
        
        # Validate rule syntax
        if [[ "$line" =~ [[:space:]]+# ]] || [[ "$line" =~ ^[[:space:]]+! ]]; then
            log_warning "Invalid rule syntax at line $line_count: '$line' (trailing comment or malformed negation)"
            continue
        fi
        
        exclusion_rules_ref+=("$line")
        rule_count=$((rule_count + 1))
        log_debug "Added exclusion rule: $line"
        
    done < "$exclude_file"
    
    log_success "Loaded $rule_count exclusion rules from $exclude_file"
    return 0
}

# Check if a file should be excluded based on rules
is_file_excluded() {
    local file_path="$1"
    shift
    local exclusion_rules=("$@")
    
    # If no rules, never exclude
    if [ ${#exclusion_rules[@]} -eq 0 ]; then
        return 1
    fi
    
    local exclude_file=false
    local include_override=false
    
    for rule in "${exclusion_rules[@]}"; do
        # Handle negation rules (include overrides)
        if [[ "$rule" == !* ]]; then
            local include_pattern="${rule:1}"
            # Remove leading/trailing whitespace from pattern
            include_pattern=$(echo "$include_pattern" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            
            if [ -z "$include_pattern" ]; then
                log_warning "Empty negation rule found, skipping"
                continue
            fi
            
            # Check if this file matches the include pattern
            if [[ "$file_path" == $include_pattern ]] || 
               [[ "$include_pattern" == */ && "$file_path" == "${include_pattern%/}"* ]] ||
               [[ "$file_path" == *"/$include_pattern" ]]; then
                include_override=true
                log_debug "Include override matched: $file_path == $include_pattern"
            fi
            continue
        fi
        
        # Handle directory exclusion (pattern ends with /)
        if [[ "$rule" == */ ]]; then
            local dir_pattern="${rule%/}"
            if [[ "$file_path" == "$dir_pattern"* ]] || 
               [[ "$file_path" == *"/$dir_pattern"* ]] ||
               [[ "$file_path" == *"/$dir_pattern" ]]; then
                exclude_file=true
                log_debug "Directory exclusion matched: $file_path in $dir_pattern"
            fi
            continue
        fi
        
        # Handle exact file match or wildcard pattern
        if [[ "$file_path" == $rule ]] || 
           [[ "$file_path" == *"/$rule" ]] ||
           [[ "$rule" == *"*" && "$file_path" == $rule ]]; then
            exclude_file=true
            log_debug "Pattern matched: $file_path == $rule"
        fi
    done
    
    # If there's an include override, don't exclude
    if [ "$include_override" = true ]; then
        return 1
    fi
    
    # Return exclusion status
    [ "$exclude_file" = true ]
}

# Copy files with exclusion rules applied
copy_with_exclusion() {
    local source_dir="$1"
    local target_dir="$2"
    local exclusion_rules=("${@:3}")
    
    log_info "Copying files with exclusion rules applied..."
    local copied_count=0
    local excluded_count=0
    
    # Create target directory if it doesn't exist
    mkdir -p "$target_dir"
    
    # Use find to safely handle file paths with spaces and special characters
    while IFS= read -r -d '' file_path; do
        # Get relative path from source directory
        local relative_path="${file_path#$source_dir/}"
        
        # Check if file should be excluded
        if is_file_excluded "$relative_path" "${exclusion_rules[@]}"; then
            log_debug "Excluded: $relative_path"
            excluded_count=$((excluded_count + 1))
            continue
        fi
        
        # Create target directory structure
        local target_file="$target_dir/$relative_path"
        local target_parent=$(dirname "$target_file")
        mkdir -p "$target_parent"
        
        # Copy the file
        if cp "$file_path" "$target_file"; then
            copied_count=$((copied_count + 1))
            log_debug "Copied: $relative_path"
        else
            log_warning "Failed to copy: $relative_path"
        fi
        
    done < <(find "$source_dir" -type f -print0 2>/dev/null)
    
    # Copy directories (empty directories that don't contain files but might be needed)
    while IFS= read -r -d '' dir_path; do
        local relative_path="${dir_path#$source_dir/}"
        
        # Skip source directory itself
        if [ "$relative_path" = "" ]; then
            continue
        fi
        
        # Check if directory should be excluded
        if is_file_excluded "$relative_path/" "${exclusion_rules[@]}"; then
            log_debug "Excluded directory: $relative_path/"
            continue
        fi
        
        # Create directory in target (mkdir -p will handle existing directories)
        mkdir -p "$target_dir/$relative_path"
        
    done < <(find "$source_dir" -type d -print0 2>/dev/null)
    
    log_success "Copied $copied_count files, excluded $excluded_count files"
    return 0
}

# Check directory permissions
check_directory_permissions() {
    local target_dir="$1"
    local parent_dir
    parent_dir=$(dirname "$target_dir")
    
    # Check if parent directory is writable
    if [ ! -w "$parent_dir" ]; then
        log_error "No write permission for parent directory: $parent_dir"
        log_error "Please check your permissions or choose a different installation directory"
        return 1
    fi
    
    # Check if target directory exists and is writable (if it exists)
    if [ -d "$target_dir" ] && [ ! -w "$target_dir" ]; then
        log_error "No write permission for existing directory: $target_dir"
        return 1
    fi
    
    return 0
}

# Handle existing directory
handle_existing_directory() {
    local target_dir="$1"
    if [ -d "$target_dir" ] && [ "$(ls -A "$target_dir" 2>/dev/null)" ]; then
        log_warning "Directory already exists and is not empty: $target_dir"
        echo -n "Do you want to continue? This may overwrite existing files. [y/N]: "
        read -r continue_choice
        
        case "$continue_choice" in
            [yY]|[yY][eE][sS])
                log_info "Continuing with installation..."
                ;;
            *)
                log_info "Installation cancelled by user"
                exit 0
                ;;
        esac
    fi
}

# Cleanup on failure
cleanup_on_failure() {
    local target_dir="$1"
    if [ -d "$target_dir" ] && [ "${CLEANUP_ON_FAILURE:-true}" = "true" ]; then
        log_info "Cleaning up installation directory due to failure..."
        rm -rf "$target_dir"
    fi
}

# Update configuration paths with actual installation directory
_update_configuration_paths() {
    local install_target="$1"
    local config_file="$install_target/config/app.conf"
    
    if [ ! -f "$config_file" ]; then
        log_warning "Configuration file not found: $config_file"
        return 0
    fi
    
    log_info "Updating configuration file: $config_file"
    
    # Create backup
    cp "$config_file" "$config_file.backup"
    
    # Update SWITCHER_DIR in configuration
    if sed -i "s|^SWITCHER_DIR=.*|SWITCHER_DIR=\"$install_target\"|" "$config_file"; then
        log_success "Updated SWITCHER_DIR in configuration: $install_target"
        
        # Update dependent directory paths
        local config_dir="$install_target/config"
        local lib_dir="$install_target/lib"
        local memory_dir="$install_target/memory"
        local log_dir="$install_target/logs"
        local backup_dir="$install_target/backups"
        
        sed -i "s|^CONFIG_DIR=.*|CONFIG_DIR=\"$config_dir\"|" "$config_file"
        sed -i "s|^LIB_DIR=.*|LIB_DIR=\"$lib_dir\"|" "$config_file"
        sed -i "s|^MEMORY_DIR=.*|MEMORY_DIR=\"$memory_dir\"|" "$config_file"
        sed -i "s|^LOG_DIR=.*|LOG_DIR=\"$log_dir\"|" "$config_file"
        sed -i "s|^BACKUP_DIR=.*|BACKUP_DIR=\"$backup_dir\"|" "$config_file"
        
        log_success "All directory paths updated in configuration"
        return 0
    else
        log_error "Failed to update configuration file: $config_file"
        # Restore backup
        mv "$config_file.backup" "$config_file"
        return 1
    fi
}

# Verify configuration integrity
_verify_configuration() {
    local install_target="$1"
    local config_file="$install_target/config/app.conf"
    
    if [ ! -f "$config_file" ]; then
        log_warning "Configuration file not found for verification: $config_file"
        return 0
    fi
    
    log_info "Verifying configuration integrity..."
    
    # Check if SWITCHER_DIR is correctly set
    if ! grep -q "^SWITCHER_DIR=\"$install_target\"$" "$config_file"; then
        log_error "Configuration verification failed: SWITCHER_DIR not correctly set"
        return 1
    fi
    
    # Check if all directory paths exist and are accessible
    local dirs_to_check=(
        "$install_target/config"
        "$install_target/lib" 
        "$install_target/memory"
        "$install_target/logs"
        "$install_target/backups"
    )
    
    for dir in "${dirs_to_check[@]}"; do
        if [ ! -d "$dir" ]; then
            log_warning "Directory not found, creating: $dir"
            mkdir -p "$dir" || {
                log_error "Failed to create directory: $dir"
                return 1
            }
            log_success "Created directory: $dir"
        fi
    done
    
    # Verify main executable exists
    if [ ! -f "$install_target/main.sh" ] || [ ! -x "$install_target/main.sh" ]; then
        log_error "Configuration verification failed: main.sh not found or not executable"
        return 1
    fi
    
    log_success "Configuration verification passed"
    return 0
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
    
    # Check directory permissions
    log_progress "Checking installation directory permissions..."
    if ! check_directory_permissions "$INSTALL_TARGET"; then
        exit 1
    fi
    
    # Handle existing directory
    handle_existing_directory "$INSTALL_TARGET"
    
    # Check if already installed (for update scenario)
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
    
    # Copy all files to installation directory with exclusion rules
    log_progress "Copying modular system files with exclusion rules..."
    
    # Load exclusion rules if available
    local exclusion_rules=()
    if [ "${IGNORE_EXCLUDE:-0}" -ne 1 ]; then
        parse_exclusion_file ".claude-exclude" exclusion_rules
    else
        log_info "Exclusion rules disabled by IGNORE_EXCLUDE environment variable"
    fi
    
    # Use smart copy function with exclusion rules
    copy_with_exclusion "$SCRIPT_DIR" "$INSTALL_TARGET" "${exclusion_rules[@]}"

    # Update configuration files with actual installation directory
    log_progress "Updating configuration files with installation path..."
    _update_configuration_paths "$INSTALL_TARGET"
    
    # Verify configuration correctness
    log_progress "Verifying configuration integrity..."
    _verify_configuration "$INSTALL_TARGET"
    
    # Make scripts executable
    chmod +x "$INSTALL_TARGET/main.sh"
    
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
        cleanup_on_failure "$INSTALL_TARGET"
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
    
    You can customize the installation directory using the CLAUDE_INSTALL_DIR
    environment variable. For example:
        CLAUDE_INSTALL_DIR="/custom/path" ./install.sh

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
