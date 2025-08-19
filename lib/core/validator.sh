#!/bin/bash

# Validator Module
# Provides validation functions for various inputs and system states

# Source dependencies
source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# Validate system requirements
validate_system_requirements() {
    log_progress "Validating system requirements..."
    
    local errors=0
    
    # Check operating system
    local os_name=$(uname -s)
    case "$os_name" in
        Linux|Darwin)
            log_success "Operating system supported: $os_name"
            ;;
        *)
            log_error "Unsupported operating system: $os_name"
            ((errors++))
            ;;
    esac
    
    # Check bash version
    local bash_major="${BASH_VERSION%%.*}"
    if [ "$bash_major" -ge 4 ]; then
        log_success "Bash version supported: $BASH_VERSION"
    else
        log_error "Bash 4.0+ required. Current version: $BASH_VERSION"
        ((errors++))
    fi
    
    # Check required commands
    local required_commands=("curl" "sed" "grep" "mkdir" "cp" "rm")
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            log_debug "Required command available: $cmd"
        else
            log_error "Required command not found: $cmd"
            ((errors++))
        fi
    done
    
    # Check write permissions for home directory
    if [ -w "$HOME" ]; then
        log_success "Home directory is writable: $HOME"
    else
        log_error "Home directory is not writable: $HOME"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "All system requirements validated successfully"
        return 0
    else
        log_error "System requirements validation failed with $errors errors"
        return 1
    fi
}

# Validate Node.js installation
validate_nodejs() {
    local min_version="${1:-18}"
    
    log_debug "Validating Node.js installation (minimum version: $min_version)"
    
    if ! command -v node >/dev/null 2>&1; then
        log_warn "Node.js not found"
        return 1
    fi
    
    local current_version
    current_version=$(node -v 2>/dev/null | sed 's/v//')
    
    if [ -z "$current_version" ]; then
        log_error "Could not determine Node.js version"
        return 1
    fi
    
    local major_version
    major_version=$(echo "$current_version" | cut -d. -f1)
    
    if [ "$major_version" -ge "$min_version" ]; then
        log_success "Node.js version meets requirements: v$current_version (>= v$min_version)"
        return 0
    else
        log_warn "Node.js version too old: v$current_version (< v$min_version)"
        return 1
    fi
}

# Validate Claude Code installation
validate_claude_code() {
    log_debug "Validating Claude Code installation"
    
    if ! command -v claude >/dev/null 2>&1; then
        log_warn "Claude Code not found"
        return 1
    fi
    
    local version
    if version=$(claude --version 2>/dev/null); then
        log_success "Claude Code is installed: $version"
        return 0
    else
        log_error "Claude Code installation appears corrupted"
        return 1
    fi
}

# Validate model alias
validate_model_alias() {
    local alias="$1"
    
    if [ -z "$alias" ]; then
        log_error "Model alias cannot be empty"
        return 1
    fi
    
    # Check if alias contains only allowed characters
    if [[ ! "$alias" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Model alias contains invalid characters: $alias"
        log_info "Allowed characters: letters, numbers, underscore, hyphen"
        return 1
    fi
    
    # Check alias length
    if [ ${#alias} -gt 20 ]; then
        log_error "Model alias too long (max 20 characters): $alias"
        return 1
    fi
    
    log_debug "Model alias validation passed: $alias"
    return 0
}

# Validate provider name
validate_provider_name() {
    local provider="$1"
    local available_providers="${2:-$AVAILABLE_PROVIDERS}"
    
    if [ -z "$provider" ]; then
        log_error "Provider name cannot be empty"
        return 1
    fi
    
    # Check if provider is in the list of available providers
    if [[ " $available_providers " =~ " $provider " ]]; then
        log_debug "Provider validation passed: $provider"
        return 0
    else
        log_error "Unknown provider: $provider"
        log_info "Available providers: $available_providers"
        return 1
    fi
}

# Validate API key format
validate_api_key() {
    local api_key="$1"
    local provider="${2:-generic}"
    
    if [ -z "$api_key" ]; then
        log_error "API key cannot be empty"
        return 1
    fi
    
    # Check minimum length
    if [ ${#api_key} -lt 10 ]; then
        log_error "API key too short (minimum 10 characters)"
        return 1
    fi
    
    # Provider-specific validation
    case "$provider" in
        "moonshot")
            if [[ "$api_key" =~ ^sk-[a-zA-Z0-9]{40,}$ ]]; then
                log_debug "Moonshot API key format validation passed"
                return 0
            else
                log_warn "API key format may be incorrect for Moonshot (expected: sk-...)"
                return 0  # Warning only, don't fail
            fi
            ;;
        "zhipu")
            if [[ "$api_key" =~ ^[a-zA-Z0-9]{32,}$ ]]; then
                log_debug "Zhipu API key format validation passed"
                return 0
            else
                log_warn "API key format may be incorrect for Zhipu"
                return 0  # Warning only, don't fail
            fi
            ;;
        *)
            log_debug "Generic API key validation passed"
            return 0
            ;;
    esac
}

# Validate file path
validate_file_path() {
    local file_path="$1"
    local must_exist="${2:-false}"
    local must_be_writable="${3:-false}"
    
    if [ -z "$file_path" ]; then
        log_error "File path cannot be empty"
        return 1
    fi
    
    # Check if file must exist
    if [ "$must_exist" = "true" ] && [ ! -f "$file_path" ]; then
        log_error "File does not exist: $file_path"
        return 1
    fi
    
    # Check if file must be writable
    if [ "$must_be_writable" = "true" ]; then
        local dir_path
        dir_path=$(dirname "$file_path")
        if [ ! -w "$dir_path" ]; then
            log_error "Directory not writable: $dir_path"
            return 1
        fi
        
        if [ -f "$file_path" ] && [ ! -w "$file_path" ]; then
            log_error "File not writable: $file_path"
            return 1
        fi
    fi
    
    log_debug "File path validation passed: $file_path"
    return 0
}

# Validate directory path
validate_directory_path() {
    local dir_path="$1"
    local must_exist="${2:-false}"
    local must_be_writable="${3:-false}"
    
    if [ -z "$dir_path" ]; then
        log_error "Directory path cannot be empty"
        return 1
    fi
    
    # Check if directory must exist
    if [ "$must_exist" = "true" ] && [ ! -d "$dir_path" ]; then
        log_error "Directory does not exist: $dir_path"
        return 1
    fi
    
    # Check if directory must be writable
    if [ "$must_be_writable" = "true" ] && [ -d "$dir_path" ] && [ ! -w "$dir_path" ]; then
        log_error "Directory not writable: $dir_path"
        return 1
    fi
    
    log_debug "Directory path validation passed: $dir_path"
    return 0
}

# Validate URL format
validate_url() {
    local url="$1"
    
    if [ -z "$url" ]; then
        log_error "URL cannot be empty"
        return 1
    fi
    
    # Basic URL format validation
    if [[ "$url" =~ ^https?://[a-zA-Z0-9.-]+[a-zA-Z0-9]+(:[0-9]+)?(/.*)?$ ]]; then
        log_debug "URL format validation passed: $url"
        return 0
    else
        log_error "Invalid URL format: $url"
        return 1
    fi
}

# Validate version string
validate_version() {
    local version="$1"
    
    if [ -z "$version" ]; then
        log_error "Version cannot be empty"
        return 1
    fi
    
    # Semantic version format (major.minor.patch)
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]; then
        log_debug "Version format validation passed: $version"
        return 0
    else
        log_error "Invalid version format: $version (expected: major.minor.patch)"
        return 1
    fi
}

# Validate shell type
validate_shell_type() {
    local shell_path="$1"
    
    if [ -z "$shell_path" ]; then
        shell_path="$SHELL"
    fi
    
    local shell_name
    shell_name=$(basename "$shell_path")
    
    case "$shell_name" in
        bash|zsh|sh)
            log_debug "Supported shell detected: $shell_name"
            return 0
            ;;
        *)
            log_warn "Shell may not be fully supported: $shell_name"
            return 0  # Warning only, don't fail
            ;;
    esac
}

# Validate configuration completeness
validate_configuration_completeness() {
    log_progress "Validating configuration completeness..."
    
    local errors=0
    
    # Check required variables from app.conf
    local required_app_vars=(
        "APP_NAME"
        "APP_VERSION"
        "SWITCHER_DIR"
        "MODEL_CONFIG_FILE"
    )
    
    for var in "${required_app_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log_error "Required configuration variable not set: $var"
            ((errors++))
        fi
    done
    
    # Check model configuration
    if [ ${#MODEL_PROVIDERS[@]} -eq 0 ]; then
        log_error "No models configured in MODEL_PROVIDERS"
        ((errors++))
    fi
    
    # Check provider configuration
    if [ -z "$AVAILABLE_PROVIDERS" ]; then
        log_error "No providers configured in AVAILABLE_PROVIDERS"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "Configuration completeness validation passed"
        return 0
    else
        log_error "Configuration completeness validation failed with $errors errors"
        return 1
    fi
}

