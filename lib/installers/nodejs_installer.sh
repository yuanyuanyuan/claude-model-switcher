#!/bin/bash

# Node.js Installer Module
# Handles Node.js installation via NVM

# Source dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../core/logger.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/validator.sh"

# Install Node.js via NVM
install_nodejs() {
    local min_version="${1:-$NODE_MIN_VERSION}"
    local nvm_version="${2:-$NVM_VERSION}"
    
    log_header "Node.js Installation"
    
    # Validate system requirements
    if ! validate_system_requirements; then
        log_error "System requirements not met for Node.js installation"
        return 1
    fi
    
    # Check if Node.js is already installed and meets requirements
    if validate_nodejs "$min_version"; then
        log_info "Node.js already meets requirements, skipping installation"
        return 0
    fi
    
    local platform
    platform=$(uname -s)
    
    case "$platform" in
        Linux|Darwin)
            _install_nodejs_unix "$min_version" "$nvm_version"
            ;;
        *)
            log_error "Unsupported platform for Node.js installation: $platform"
            return 1
            ;;
    esac
}

# Install Node.js on Unix-like systems (Linux/macOS)
_install_nodejs_unix() {
    local min_version="$1"
    local nvm_version="$2"
    
    log_progress "Installing Node.js via NVM for Unix-like system..."
    
    # Check if NVM is already installed
    if [ -d "$HOME/.nvm" ]; then
        log_info "NVM directory already exists, sourcing existing installation..."
        _source_nvm
    else
        log_progress "Downloading and installing NVM $nvm_version..."
        if ! _install_nvm "$nvm_version"; then
            log_error "Failed to install NVM"
            return 1
        fi
    fi
    
    # Install Node.js LTS
    log_progress "Installing Node.js LTS version..."
    if ! _install_nodejs_lts; then
        log_error "Failed to install Node.js LTS"
        return 1
    fi
    
    # Verify installation
    if validate_nodejs "$min_version"; then
        log_success "Node.js installation completed successfully"
        _display_nodejs_info
        return 0
    else
        log_error "Node.js installation verification failed"
        return 1
    fi
}

# Install NVM
_install_nvm() {
    local nvm_version="$1"
    local install_url="${NVM_INSTALL_URL:-https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh}"
    
    log_debug "Downloading NVM from: $install_url"
    
    # Validate URL format
    if ! validate_url "$install_url"; then
        log_error "Invalid NVM install URL: $install_url"
        return 1
    fi
    
    # Download and execute NVM installer
    if curl -s -o- "$install_url" | bash; then
        log_success "NVM installation script executed successfully"
        _source_nvm
        return 0
    else
        log_error "Failed to download or execute NVM installer"
        return 1
    fi
}

# Source NVM environment
_source_nvm() {
    log_debug "Sourcing NVM environment..."
    
    export NVM_DIR="$HOME/.nvm"
    
    # Source NVM script
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
        log_debug "NVM script sourced successfully"
    else
        log_error "NVM script not found: $NVM_DIR/nvm.sh"
        return 1
    fi
    
    # Source NVM bash completion (optional)
    if [ -s "$NVM_DIR/bash_completion" ]; then
        source "$NVM_DIR/bash_completion"
        log_debug "NVM bash completion sourced"
    fi
    
    return 0
}

# Install Node.js LTS
_install_nodejs_lts() {
    # Ensure NVM is sourced
    if ! command -v nvm >/dev/null 2>&1; then
        if ! _source_nvm; then
            log_error "NVM not available after sourcing"
            return 1
        fi
    fi
    
    log_debug "Installing Node.js LTS via NVM..."
    
    # Install LTS version
    if nvm install --lts; then
        log_success "Node.js LTS installed successfully"
    else
        log_error "Failed to install Node.js LTS"
        return 1
    fi
    
    # Use LTS version
    if nvm use --lts; then
        log_success "Switched to Node.js LTS"
    else
        log_error "Failed to switch to Node.js LTS"
        return 1
    fi
    
    # Set LTS as default
    if nvm alias default 'lts/*'; then
        log_success "Node.js LTS set as default"
    else
        log_warn "Failed to set Node.js LTS as default"
    fi
    
    return 0
}

# Display Node.js installation information
_display_nodejs_info() {
    log_info "Node.js Installation Summary:"
    
    if command -v node >/dev/null 2>&1; then
        local node_version
        node_version=$(node -v 2>/dev/null)
        log_indent info "Node.js version: $node_version" 2
    fi
    
    if command -v npm >/dev/null 2>&1; then
        local npm_version
        npm_version=$(npm -v 2>/dev/null)
        log_indent info "npm version: $npm_version" 2
    fi
    
    if command -v nvm >/dev/null 2>&1; then
        local nvm_version
        nvm_version=$(nvm --version 2>/dev/null)
        log_indent info "NVM version: $nvm_version" 2
    fi
}

# Check if Node.js upgrade is needed
check_nodejs_upgrade() {
    local min_version="${1:-$NODE_MIN_VERSION}"
    
    if ! validate_nodejs "$min_version"; then
        log_info "Node.js upgrade recommended"
        return 1
    else
        log_info "Node.js version is up to date"
        return 0
    fi
}

# Upgrade Node.js to latest LTS
upgrade_nodejs() {
    log_header "Node.js Upgrade"
    
    # Check if NVM is available
    if [ ! -d "$HOME/.nvm" ]; then
        log_error "NVM not found. Please install Node.js first."
        return 1
    fi
    
    # Source NVM
    if ! _source_nvm; then
        log_error "Failed to source NVM environment"
        return 1
    fi
    
    log_progress "Upgrading to latest Node.js LTS..."
    
    # Install latest LTS
    if ! _install_nodejs_lts; then
        log_error "Failed to upgrade Node.js"
        return 1
    fi
    
    log_success "Node.js upgrade completed"
    _display_nodejs_info
    return 0
}

# Uninstall Node.js (remove NVM)
uninstall_nodejs() {
    log_header "Node.js Uninstallation"
    
    if [ -d "$HOME/.nvm" ]; then
        log_progress "Removing NVM directory..."
        rm -rf "$HOME/.nvm"
        log_success "NVM directory removed"
    else
        log_info "NVM directory not found, nothing to remove"
    fi
    
    # Remove NVM lines from shell configuration files
    local shell_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    
    for shell_file in "${shell_files[@]}"; do
        if [ -f "$shell_file" ]; then
            if grep -q "NVM_DIR" "$shell_file"; then
                log_progress "Cleaning NVM configuration from: $shell_file"
                # Create backup
                cp "$shell_file" "${shell_file}.nvm_removal_backup"
                # Remove NVM lines
                sed -i '/NVM_DIR/d' "$shell_file"
                sed -i '/nvm.sh/d' "$shell_file"
                sed -i '/bash_completion/d' "$shell_file"
                log_success "NVM configuration removed from: $shell_file"
            fi
        fi
    done
    
    log_success "Node.js uninstallation completed"
    log_info "Please restart your terminal for changes to take effect"
}

# Test Node.js installation
test_nodejs_installation() {
    log_header "Node.js Installation Test"
    
    local errors=0
    
    # Test Node.js command
    if command -v node >/dev/null 2>&1; then
        local node_version
        node_version=$(node -v 2>/dev/null)
        log_success "Node.js command available: $node_version"
    else
        log_error "Node.js command not found"
        ((errors++))
    fi
    
    # Test npm command
    if command -v npm >/dev/null 2>&1; then
        local npm_version
        npm_version=$(npm -v 2>/dev/null)
        log_success "npm command available: $npm_version"
    else
        log_error "npm command not found"
        ((errors++))
    fi
    
    # Test simple Node.js execution
    local test_result
    test_result=$(node -e "console.log('Node.js test successful')" 2>/dev/null)
    if [ "$test_result" = "Node.js test successful" ]; then
        log_success "Node.js execution test passed"
    else
        log_error "Node.js execution test failed"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "All Node.js tests passed"
        return 0
    else
        log_error "Node.js tests failed with $errors errors"
        return 1
    fi
}

