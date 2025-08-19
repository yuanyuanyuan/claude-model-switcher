#!/bin/bash

# Configuration Loader Module
# Handles loading and validation of configuration files

# Source the logger
source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# Global configuration variables
declare -A CONFIG_CACHE
declare -A CONFIG_FILE_TIMESTAMPS

# Load a configuration file
config_load() {
    local config_file="$1"
    local force_reload="${2:-false}"
    local config_name="${3:-$(basename "$config_file" .conf)}"
    
    if [ ! -f "$config_file" ]; then
        log_error "Configuration file not found: $config_file"
        return 1
    fi
    
    # Check if we need to reload based on file modification time
    local current_timestamp
    current_timestamp=$(stat -c %Y "$config_file" 2>/dev/null || echo "0")
    local cached_timestamp="${CONFIG_FILE_TIMESTAMPS[$config_name]:-0}"
    
    if [ "$force_reload" = "true" ] || [ "$current_timestamp" -gt "$cached_timestamp" ]; then
        log_debug "Loading configuration: $config_file"
        
        # Validate configuration file syntax
        if ! config_validate_syntax "$config_file"; then
            log_error "Configuration file has syntax errors: $config_file"
            return 1
        fi
        
        # Source the configuration file
        if source "$config_file"; then
            CONFIG_FILE_TIMESTAMPS[$config_name]="$current_timestamp"
            CONFIG_CACHE[$config_name]="loaded"
            log_debug "Configuration loaded successfully: $config_name"
            return 0
        else
            log_error "Failed to load configuration: $config_file"
            return 1
        fi
    else
        log_debug "Configuration already loaded and up-to-date: $config_name"
        return 0
    fi
}

# Validate configuration file syntax
config_validate_syntax() {
    local config_file="$1"
    
    # Basic shell syntax check
    if ! bash -n "$config_file" 2>/dev/null; then
        log_error "Shell syntax error in configuration file: $config_file"
        return 1
    fi
    
    # Check for required variables based on file type
    local filename=$(basename "$config_file")
    case "$filename" in
        "app.conf")
            config_validate_app_config "$config_file"
            ;;
        "models.conf")
            config_validate_models_config "$config_file"
            ;;
        "providers.conf")
            config_validate_providers_config "$config_file"
            ;;
        *)
            log_debug "No specific validation rules for: $filename"
            return 0
            ;;
    esac
}

# Validate app configuration
config_validate_app_config() {
    local config_file="$1"
    local required_vars=(
        "APP_NAME"
        "APP_VERSION"
        "SWITCHER_DIR"
        "MODEL_CONFIG_FILE"
    )
    
    # Source config in a subshell to check variables
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$config_file"; then
            log_error "Required variable '$var' not found in $config_file"
            return 1
        fi
    done
    
    log_debug "App configuration validation passed"
    return 0
}

# Validate models configuration
config_validate_models_config() {
    local config_file="$1"
    
    # Check for associative array declarations
    if ! grep -q "declare -A MODEL_PROVIDERS" "$config_file"; then
        log_error "MODEL_PROVIDERS associative array not declared in $config_file"
        return 1
    fi
    
    if ! grep -q "declare -A MODEL_API_NAMES" "$config_file"; then
        log_error "MODEL_API_NAMES associative array not declared in $config_file"
        return 1
    fi
    
    log_debug "Models configuration validation passed"
    return 0
}

# Validate providers configuration
config_validate_providers_config() {
    local config_file="$1"
    
    # Check for at least one provider configuration
    if ! grep -q "PROVIDER_.*_BASE_URL=" "$config_file"; then
        log_error "No provider configurations found in $config_file"
        return 1
    fi
    
    log_debug "Providers configuration validation passed"
    return 0
}

# Load all configuration files
config_load_all() {
    local config_dir="${1:-$HOME/.claude/claude-model-switcher/config}"
    local force_reload="${2:-false}"
    
    if [ ! -d "$config_dir" ]; then
        log_error "Configuration directory not found: $config_dir"
        return 1
    fi
    
    log_progress "Loading all configuration files from: $config_dir"
    
    # Load configurations in order of dependency
    local config_files=(
        "$config_dir/app.conf"
        "$config_dir/providers.conf"
        "$config_dir/models.conf"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            if ! config_load "$config_file" "$force_reload"; then
                log_error "Failed to load configuration: $config_file"
                return 1
            fi
        else
            log_warn "Configuration file not found (optional): $config_file"
        fi
    done
    
    log_success "All configuration files loaded successfully"
    return 0
}

# Get configuration value with fallback
config_get() {
    local var_name="$1"
    local default_value="$2"
    
    # Check if variable is set
    if [ -n "${!var_name}" ]; then
        echo "${!var_name}"
    else
        log_debug "Configuration variable '$var_name' not set, using default: $default_value"
        echo "$default_value"
    fi
}

# Set configuration value
config_set() {
    local var_name="$1"
    local value="$2"
    
    export "$var_name"="$value"
    log_debug "Configuration variable set: $var_name=$value"
}

# Check if configuration is loaded
config_is_loaded() {
    local config_name="$1"
    [ "${CONFIG_CACHE[$config_name]}" = "loaded" ]
}

# Reload specific configuration
config_reload() {
    local config_name="$1"
    local config_dir="${2:-$HOME/.claude/claude-model-switcher/config}"
    
    config_load "$config_dir/${config_name}.conf" "true" "$config_name"
}

# List loaded configurations
config_list_loaded() {
    log_info "Loaded configurations:"
    for config_name in "${!CONFIG_CACHE[@]}"; do
        if [ "${CONFIG_CACHE[$config_name]}" = "loaded" ]; then
            local timestamp="${CONFIG_FILE_TIMESTAMPS[$config_name]}"
            local date_str=$(date -d "@$timestamp" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "unknown")
            log_indent info "$config_name (loaded at: $date_str)" 2
        fi
    done
}

# Validate current environment against configuration
config_validate_environment() {
    log_progress "Validating environment against configuration..."
    
    # Check bash version for associative arrays
    local bash_version="${BASH_VERSION%%.*}"
    if [ "$bash_version" -lt 4 ]; then
        log_error "Bash 4.0+ required for associative arrays. Current version: $BASH_VERSION"
        return 1
    fi
    
    # Check required directories
    local required_dirs=(
        "$SWITCHER_DIR"
        "$CONFIG_DIR"
        "$LIB_DIR"
        "$MEMORY_DIR"
        "$LOG_DIR"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ -n "$dir" ] && [ ! -d "$dir" ]; then
            log_warn "Required directory missing: $dir"
            mkdir -p "$dir" || {
                log_error "Failed to create directory: $dir"
                return 1
            }
            log_success "Created directory: $dir"
        fi
    done
    
    log_success "Environment validation completed"
    return 0
}

