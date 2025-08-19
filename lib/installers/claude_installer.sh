#!/bin/bash

# Claude Code Installer Module
# Handles Claude Code CLI installation and configuration

# Source dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../core/logger.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/validator.sh"

# Install Claude Code CLI
install_claude_code() {
    local package_name="${1:-$CLAUDE_PACKAGE}"
    
    log_header "Claude Code Installation"
    
    # Validate Node.js is available
    if ! validate_nodejs; then
        log_error "Node.js is required for Claude Code installation"
        return 1
    fi
    
    # Check if Claude Code is already installed
    if validate_claude_code; then
        log_info "Claude Code is already installed and working"
        _display_claude_info
        return 0
    fi
    
    log_progress "Installing Claude Code CLI package: $package_name"
    
    # Install via npm
    if _install_claude_npm "$package_name"; then
        log_success "Claude Code CLI installed successfully"
    else
        log_error "Failed to install Claude Code CLI"
        return 1
    fi
    
    # Configure Claude Code
    if _configure_claude_code; then
        log_success "Claude Code configured successfully"
    else
        log_warn "Claude Code installation succeeded but configuration failed"
    fi
    
    # Verify installation
    if validate_claude_code; then
        log_success "Claude Code installation and verification completed"
        _display_claude_info
        return 0
    else
        log_error "Claude Code installation verification failed"
        return 1
    fi
}

# Install Claude Code via npm
_install_claude_npm() {
    local package_name="$1"
    
    log_debug "Installing $package_name via npm..."
    
    # Check npm availability
    if ! command -v npm >/dev/null 2>&1; then
        log_error "npm command not found"
        return 1
    fi
    
    # Install globally with error handling
    local install_output
    if install_output=$(npm install -g "$package_name" 2>&1); then
        log_debug "npm install output: $install_output"
        return 0
    else
        log_error "npm install failed: $install_output"
        return 1
    fi
}

# Configure Claude Code
_configure_claude_code() {
    log_progress "Configuring Claude Code to skip onboarding..."
    
    local claude_config_dir="$HOME/.claude"
    local claude_config_file="$claude_config_dir/.claude.json"
    
    # Ensure Claude config directory exists
    if ! mkdir -p "$claude_config_dir"; then
        log_error "Failed to create Claude config directory: $claude_config_dir"
        return 1
    fi
    
    # Create or update configuration using Node.js
    local config_script='
        const fs = require("fs");
        const path = require("path");
        const os = require("os");
        const configPath = path.join(os.homedir(), ".claude.json");
        
        let config = {};
        if (fs.existsSync(configPath)) {
            try {
                const content = fs.readFileSync(configPath, "utf-8");
                config = JSON.parse(content);
            } catch (e) {
                console.error("Warning: Could not parse existing config, creating new one");
                config = {};
            }
        }
        
        config.hasCompletedOnboarding = true;
        
        try {
            fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
            console.log("Configuration updated successfully");
        } catch (e) {
            console.error("Failed to write configuration:", e.message);
            process.exit(1);
        }
    '
    
    if node -e "$config_script" 2>/dev/null; then
        log_success "Claude Code configuration updated"
        return 0
    else
        log_error "Failed to configure Claude Code"
        return 1
    fi
}

# Display Claude Code information
_display_claude_info() {
    log_info "Claude Code Installation Summary:"
    
    if command -v claude >/dev/null 2>&1; then
        local claude_version
        if claude_version=$(claude --version 2>/dev/null); then
            log_indent info "Claude Code version: $claude_version" 2
        else
            log_indent warn "Could not determine Claude Code version" 2
        fi
        
        local claude_path
        if claude_path=$(which claude 2>/dev/null); then
            log_indent info "Claude Code path: $claude_path" 2
        fi
    fi
    
    local config_file="$HOME/.claude.json"
    if [ -f "$config_file" ]; then
        log_indent info "Configuration file: $config_file" 2
        local onboarding_status
        if onboarding_status=$(node -e "
            try {
                const config = JSON.parse(require('fs').readFileSync('$config_file', 'utf-8'));
                console.log(config.hasCompletedOnboarding ? 'completed' : 'pending');
            } catch (e) {
                console.log('unknown');
            }
        " 2>/dev/null); then
            log_indent info "Onboarding status: $onboarding_status" 2
        fi
    fi
}

# Update Claude Code
update_claude_code() {
    local package_name="${1:-$CLAUDE_PACKAGE}"
    
    log_header "Claude Code Update"
    
    # Check current installation
    if ! validate_claude_code; then
        log_error "Claude Code not found. Please install it first."
        return 1
    fi
    
    log_progress "Updating Claude Code CLI package: $package_name"
    
    # Update via npm
    if _update_claude_npm "$package_name"; then
        log_success "Claude Code CLI updated successfully"
        _display_claude_info
        return 0
    else
        log_error "Failed to update Claude Code CLI"
        return 1
    fi
}

# Update Claude Code via npm
_update_claude_npm() {
    local package_name="$1"
    
    log_debug "Updating $package_name via npm..."
    
    local update_output
    if update_output=$(npm update -g "$package_name" 2>&1); then
        log_debug "npm update output: $update_output"
        return 0
    else
        log_error "npm update failed: $update_output"
        return 1
    fi
}

# Uninstall Claude Code
uninstall_claude_code() {
    local package_name="${1:-$CLAUDE_PACKAGE}"
    
    log_header "Claude Code Uninstallation"
    
    # Check if Claude Code is installed
    if ! command -v claude >/dev/null 2>&1; then
        log_info "Claude Code not found, nothing to uninstall"
        return 0
    fi
    
    log_progress "Uninstalling Claude Code CLI package: $package_name"
    
    # Uninstall via npm
    if _uninstall_claude_npm "$package_name"; then
        log_success "Claude Code CLI uninstalled successfully"
    else
        log_error "Failed to uninstall Claude Code CLI"
        return 1
    fi
    
    # Clean up configuration (optional)
    local cleanup_config="${2:-false}"
    if [ "$cleanup_config" = "true" ]; then
        _cleanup_claude_config
    fi
    
    return 0
}

# Uninstall Claude Code via npm
_uninstall_claude_npm() {
    local package_name="$1"
    
    log_debug "Uninstalling $package_name via npm..."
    
    local uninstall_output
    if uninstall_output=$(npm uninstall -g "$package_name" 2>&1); then
        log_debug "npm uninstall output: $uninstall_output"
        return 0
    else
        log_error "npm uninstall failed: $uninstall_output"
        return 1
    fi
}

# Clean up Claude Code configuration
_cleanup_claude_config() {
    log_progress "Cleaning up Claude Code configuration..."
    
    local claude_config_dir="$HOME/.claude"
    local claude_config_file="$claude_config_dir/.claude.json"
    local claude_settings_file="$claude_config_dir/settings.json"
    
    # Remove configuration files
    local files_to_remove=("$claude_config_file" "$claude_settings_file")
    
    for file in "${files_to_remove[@]}"; do
        if [ -f "$file" ]; then
            log_debug "Removing configuration file: $file"
            rm -f "$file"
        fi
    done
    
    # Remove empty directory
    if [ -d "$claude_config_dir" ] && [ -z "$(ls -A "$claude_config_dir" 2>/dev/null)" ]; then
        log_debug "Removing empty Claude config directory: $claude_config_dir"
        rmdir "$claude_config_dir"
    fi
    
    log_success "Claude Code configuration cleanup completed"
}

# Test Claude Code installation
test_claude_installation() {
    log_header "Claude Code Installation Test"
    
    local errors=0
    
    # Test Claude command availability
    if command -v claude >/dev/null 2>&1; then
        log_success "Claude command is available"
    else
        log_error "Claude command not found"
        ((errors++))
    fi
    
    # Test Claude version command
    local version_output
    if version_output=$(claude --version 2>/dev/null); then
        log_success "Claude version command works: $version_output"
    else
        log_error "Claude version command failed"
        ((errors++))
    fi
    
    # Test Claude help command
    if claude --help >/dev/null 2>&1; then
        log_success "Claude help command works"
    else
        log_error "Claude help command failed"
        ((errors++))
    fi
    
    # Test configuration file
    local config_file="$HOME/.claude.json"
    if [ -f "$config_file" ]; then
        log_success "Claude configuration file exists"
        
        # Test configuration file validity
        if node -e "JSON.parse(require('fs').readFileSync('$config_file', 'utf-8'))" 2>/dev/null; then
            log_success "Claude configuration file is valid JSON"
        else
            log_error "Claude configuration file has invalid JSON"
            ((errors++))
        fi
    else
        log_warn "Claude configuration file not found (may be created on first run)"
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "All Claude Code tests passed"
        return 0
    else
        log_error "Claude Code tests failed with $errors errors"
        return 1
    fi
}

# Get Claude Code status
get_claude_status() {
    log_info "Claude Code Status:"
    
    if command -v claude >/dev/null 2>&1; then
        log_indent success "Status: Installed" 2
        
        local version
        if version=$(claude --version 2>/dev/null); then
            log_indent info "Version: $version" 2
        fi
        
        local path
        if path=$(which claude 2>/dev/null); then
            log_indent info "Path: $path" 2
        fi
    else
        log_indent error "Status: Not installed" 2
    fi
    
    local config_file="$HOME/.claude.json"
    if [ -f "$config_file" ]; then
        log_indent info "Configuration: Found" 2
    else
        log_indent warn "Configuration: Not found" 2
    fi
}

