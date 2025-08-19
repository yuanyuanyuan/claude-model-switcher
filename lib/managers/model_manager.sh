#!/bin/bash

# Model Manager Module
# Handles model switching, listing, and configuration

# Source dependencies
# Note: Core modules (logger, validator, config_loader) are expected to be 
# available in the environment. This avoids circular dependencies during testing.

# List available models
list_models() {
    log_header "Available Models"
    
    # Reload configuration to get latest models
    if ! config_load "$MODEL_CONFIG_FILE" "true"; then
        log_error "Failed to load model configuration"
        return 1
    fi
    
    # Check if models are configured
    if [ ${#MODEL_PROVIDERS[@]} -eq 0 ]; then
        log_warn "No models defined in $MODEL_CONFIG_FILE"
        return 1
    fi
    
    # Display table header
    local table_width="${TABLE_WIDTH:-110}"
    printf '%*s\n' "$table_width" | tr ' ' '-'
    printf "%-12s %-12s %-25s %-25s %s\n" "Alias" "Provider" "Main Model" "Fast Model" "Context"
    printf '%*s\n' "$table_width" | tr ' ' '-'
    
    # Display models
    for alias in "${!MODEL_PROVIDERS[@]}"; do
        local provider="${MODEL_PROVIDERS[$alias]}"
        local main_model="${MODEL_API_NAMES[$alias]}"
        local fast_model="${MODEL_SMALL_FAST_NAMES[$alias]:-$main_model}"
        local context="${MODEL_CONTEXTS[$alias]:-N/A}"
        
        printf "%-12s %-12s %-25s %-25s %s\n" \
            "$alias" \
            "$provider" \
            "$main_model" \
            "$fast_model" \
            "$context"
    done
    
    printf '%*s\n' "$table_width" | tr ' ' '-'
    
    # Display additional information
    log_info "Total models configured: ${#MODEL_PROVIDERS[@]}"
    log_info "Configuration file: $MODEL_CONFIG_FILE"
    
    return 0
}

# Use/switch to a specific model
use_model() {
    local alias="$1"
    local api_key="$2"  # Optional: can be provided or prompted
    
    log_header "Model Switching: $alias"
    
    # Validate input
    if [ -z "$alias" ]; then
        log_error "Model alias is required"
        log_info "Usage: use_model <alias> [api_key]"
        list_models
        return 1
    fi
    
    # Validate alias format
    if ! validate_model_alias "$alias"; then
        return 1
    fi
    
    # Reload configuration
    if ! config_load "$MODEL_CONFIG_FILE" "true"; then
        log_error "Failed to load model configuration"
        return 1
    fi
    
    # Check if model exists
    if [ -z "${MODEL_PROVIDERS[$alias]}" ]; then
        log_error "Model alias '$alias' not found in configuration"
        list_models
        return 1
    fi
    
    # Get model properties
    local provider="${MODEL_PROVIDERS[$alias]}"
    local main_model="${MODEL_API_NAMES[$alias]}"
    local fast_model="${MODEL_SMALL_FAST_NAMES[$alias]:-$main_model}"
    local context_info="${MODEL_CONTEXTS[$alias]}"
    local description="${MODEL_DESCRIPTIONS[$alias]:-N/A}"
    
    # Validate provider
    if ! validate_provider_name "$provider"; then
        return 1
    fi
    
    # Configure provider-specific settings
    if ! _configure_provider "$provider" "$alias" "$api_key"; then
        log_error "Failed to configure provider: $provider"
        return 1
    fi
    
    # Configure Claude Code settings
    if ! _configure_claude_settings "$alias" "$main_model" "$fast_model" "$context_info"; then
        log_error "Failed to configure Claude Code settings"
        return 1
    fi
    
    # Update memory/context file
    if ! _update_model_context "$alias" "$provider" "$main_model" "$fast_model" "$context_info" "$description"; then
        log_warn "Failed to update model context file"
    fi
    
    log_success "Successfully switched to model: $alias"
    _display_active_model_info "$alias" "$provider" "$main_model" "$fast_model" "$context_info"
    
    return 0
}

# Configure provider-specific settings
_configure_provider() {
    local provider="$1"
    local alias="$2"
    local api_key="$3"
    
    log_progress "Configuring provider: $provider"
    
    # Get provider configuration
    local base_url_var="PROVIDER_${provider^^}_BASE_URL"
    local base_url="${!base_url_var}"
    
    if [ -z "$base_url" ]; then
        log_error "Base URL not configured for provider: $provider"
        return 1
    fi
    
    # Validate base URL
    if ! validate_url "$base_url"; then
        log_error "Invalid base URL for provider $provider: $base_url"
        return 1
    fi
    
    # Set base URL
    export ANTHROPIC_BASE_URL="$base_url"
    log_success "Base URL configured: $base_url"
    
    # Handle API key
    if [ -z "$api_key" ]; then
        log_info "Please enter your $provider API key (input hidden):"
        read -s api_key
        echo  # New line after hidden input
    fi
    
    # Validate API key
    if ! validate_api_key "$api_key" "$provider"; then
        log_error "Invalid API key format"
        return 1
    fi
    
    # Set API key
    export ANTHROPIC_AUTH_TOKEN="$api_key"
    log_success "API key configured for this session"
    
    return 0
}

# Configure Claude Code settings
_configure_claude_settings() {
    local alias="$1"
    local main_model="$2"
    local fast_model="$3"
    local context_info="$4"
    
    log_progress "Configuring Claude Code settings..."
    
    local claude_dir="$HOME/.claude"
    local settings_file="$claude_dir/settings.json"
    
    # Ensure Claude directory exists
    mkdir -p "$claude_dir"
    
    # Get configuration values
    local temperature="${CLAUDE_DEFAULT_TEMPERATURE:-0.6}"
    local timeout="${CLAUDE_DEFAULT_TIMEOUT:-300000}"
    
    # Create settings JSON
    local settings_content
    settings_content=$(cat << EOF
{
  "model": "$main_model",
  "env": {
    "CLAUDE_CODE_TEMPERATURE": "$temperature",
    "BASH_DEFAULT_TIMEOUT_MS": "$timeout",
    "ANTHROPIC_MODEL": "$main_model",
    "ANTHROPIC_SMALL_FAST_MODEL": "$fast_model"
  },
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "echo '🤖 Active: $main_model ($alias) | Fast: $fast_model | Context: $context_info | T:$temperature | Timeout:${timeout}ms'"
      }
    ]
  }
}
EOF
    )
    
    # Write settings file
    if echo "$settings_content" > "$settings_file"; then
        log_success "Claude Code settings updated: $settings_file"
        return 0
    else
        log_error "Failed to write Claude Code settings file"
        return 1
    fi
}

# Update model context file
_update_model_context() {
    local alias="$1"
    local provider="$2"
    local main_model="$3"
    local fast_model="$4"
    local context_info="$5"
    local description="$6"
    
    local memory_file="$MEMORY_DIR/model-context.md"
    
    # Ensure memory directory exists
    mkdir -p "$MEMORY_DIR"
    
    # Create context content
    local context_content
    context_content=$(cat << EOF
# Model Context Reference

## Current Configuration
- **Provider**: $provider
- **Alias**: $alias
- **Main Model**: $main_model
- **Fast Model**: $fast_model
- **Context Window**: $context_info
- **Description**: $description
- **Temperature**: ${CLAUDE_DEFAULT_TEMPERATURE:-0.6} (Programming Mode)
- **Timeout**: ${CLAUDE_DEFAULT_TIMEOUT:-300000}ms (5 minutes)
- **Last Updated**: $(date)

## Environment Variables
- **ANTHROPIC_BASE_URL**: ${ANTHROPIC_BASE_URL:-Not set}
- **ANTHROPIC_MODEL**: $main_model
- **ANTHROPIC_SMALL_FAST_MODEL**: $fast_model

## Usage Instructions
1. Use \`claude "your prompt here"\` for general queries
2. The system automatically selects between main and fast models based on task complexity
3. Programming assistance is optimized with temperature 0.6
4. Session timeout is set to 5 minutes for long-running tasks

## Provider Information
- **Base URL**: ${ANTHROPIC_BASE_URL:-Not configured}
- **Authentication**: Session-based (API key required per session)

---
*Generated by Claude Model Switcher v${APP_VERSION:-5.0.0}*
EOF
    )
    
    # Write context file
    if echo "$context_content" > "$memory_file"; then
        log_debug "Model context file updated: $memory_file"
        return 0
    else
        log_warn "Failed to update model context file: $memory_file"
        return 1
    fi
}

# Display active model information
_display_active_model_info() {
    local alias="$1"
    local provider="$2"
    local main_model="$3"
    local fast_model="$4"
    local context_info="$5"
    
    log_info "Active Model Configuration:"
    log_indent info "Alias: $alias" 2
    log_indent info "Provider: $provider" 2
    log_indent info "Main Model: $main_model" 2
    log_indent info "Fast Model: $fast_model" 2
    log_indent info "Context: $context_info" 2
    log_indent info "Temperature: ${CLAUDE_DEFAULT_TEMPERATURE:-0.6}" 2
    log_indent info "Timeout: ${CLAUDE_DEFAULT_TIMEOUT:-300000}ms" 2
    
    log_info "Ready to use Claude Code with: claude \"your prompt here\""
}

# Get current model status
get_model_status() {
    log_info "Current Model Status:"
    
    # Check environment variables
    if [ -n "$ANTHROPIC_MODEL" ]; then
        log_indent success "Main Model: $ANTHROPIC_MODEL" 2
    else
        log_indent warn "Main Model: Not configured" 2
    fi
    
    if [ -n "$ANTHROPIC_SMALL_FAST_MODEL" ]; then
        log_indent success "Fast Model: $ANTHROPIC_SMALL_FAST_MODEL" 2
    else
        log_indent warn "Fast Model: Not configured" 2
    fi
    
    if [ -n "$ANTHROPIC_BASE_URL" ]; then
        log_indent success "Base URL: $ANTHROPIC_BASE_URL" 2
    else
        log_indent warn "Base URL: Not configured" 2
    fi
    
    if [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
        log_indent success "API Key: Configured" 2
    else
        log_indent warn "API Key: Not configured" 2
    fi
    
    # Check settings file
    local settings_file="$HOME/.claude/settings.json"
    if [ -f "$settings_file" ]; then
        log_indent success "Settings File: $settings_file" 2
    else
        log_indent warn "Settings File: Not found" 2
    fi
    
    # Check context file
    local context_file="$MEMORY_DIR/model-context.md"
    if [ -f "$context_file" ]; then
        log_indent success "Context File: $context_file" 2
    else
        log_indent warn "Context File: Not found" 2
    fi
}

# Add a new model to configuration
add_model() {
    local alias="$1"
    local provider="$2"
    local main_model="$3"
    local fast_model="$4"
    local context="$5"
    local description="$6"
    
    log_header "Adding New Model: $alias"
    
    # Validate inputs
    if ! validate_model_alias "$alias"; then
        return 1
    fi
    
    if ! validate_provider_name "$provider"; then
        return 1
    fi
    
    if [ -z "$main_model" ]; then
        log_error "Main model name is required"
        return 1
    fi
    
    # Set defaults
    fast_model="${fast_model:-$main_model}"
    context="${context:-N/A}"
    description="${description:-Custom model configuration}"
    
    # Load current configuration
    if ! config_load "$MODEL_CONFIG_FILE"; then
        log_error "Failed to load model configuration"
        return 1
    fi
    
    # Check if alias already exists
    if [ -n "${MODEL_PROVIDERS[$alias]}" ]; then
        log_error "Model alias '$alias' already exists"
        return 1
    fi
    
    # Add model to configuration file
    log_progress "Adding model to configuration file..."
    
    local new_model_config
    new_model_config=$(cat << EOF

# Model Alias: '$alias' - $description
MODEL_PROVIDERS["$alias"]="$provider"
MODEL_API_NAMES["$alias"]="$main_model"
MODEL_SMALL_FAST_NAMES["$alias"]="$fast_model"
MODEL_CONTEXTS["$alias"]="$context"
MODEL_DESCRIPTIONS["$alias"]="$description"
EOF
    )
    
    # Append to configuration file
    if echo "$new_model_config" >> "$MODEL_CONFIG_FILE"; then
        log_success "Model '$alias' added to configuration"
        
        # Update AVAILABLE_MODELS list
        local current_models
        current_models=$(grep "AVAILABLE_MODELS=" "$MODEL_CONFIG_FILE" | cut -d'"' -f2)
        local updated_models="$current_models $alias"
        
        # Update the AVAILABLE_MODELS line
        sed -i "s/AVAILABLE_MODELS=\".*\"/AVAILABLE_MODELS=\"$updated_models\"/" "$MODEL_CONFIG_FILE"
        
        log_success "Model successfully added and configuration updated"
        return 0
    else
        log_error "Failed to add model to configuration file"
        return 1
    fi
}

# Remove a model from configuration
remove_model() {
    local alias="$1"
    
    log_header "Removing Model: $alias"
    
    if [ -z "$alias" ]; then
        log_error "Model alias is required"
        return 1
    fi
    
    # Load current configuration
    if ! config_load "$MODEL_CONFIG_FILE"; then
        log_error "Failed to load model configuration"
        return 1
    fi
    
    # Check if alias exists
    if [ -z "${MODEL_PROVIDERS[$alias]}" ]; then
        log_error "Model alias '$alias' not found"
        return 1
    fi
    
    # Create backup
    local backup_file="${MODEL_CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    if cp "$MODEL_CONFIG_FILE" "$backup_file"; then
        log_success "Configuration backup created: $backup_file"
    else
        log_warn "Failed to create backup, proceeding anyway"
    fi
    
    # Remove model entries from configuration file
    log_progress "Removing model entries from configuration..."
    
    # Remove all lines related to this model
    sed -i "/MODEL_PROVIDERS\[\"$alias\"\]/d" "$MODEL_CONFIG_FILE"
    sed -i "/MODEL_API_NAMES\[\"$alias\"\]/d" "$MODEL_CONFIG_FILE"
    sed -i "/MODEL_SMALL_FAST_NAMES\[\"$alias\"\]/d" "$MODEL_CONFIG_FILE"
    sed -i "/MODEL_CONTEXTS\[\"$alias\"\]/d" "$MODEL_CONFIG_FILE"
    sed -i "/MODEL_DESCRIPTIONS\[\"$alias\"\]/d" "$MODEL_CONFIG_FILE"
    
    # Update AVAILABLE_MODELS list
    local current_models
    current_models=$(grep "AVAILABLE_MODELS=" "$MODEL_CONFIG_FILE" | cut -d'"' -f2)
    local updated_models
    updated_models=$(echo "$current_models" | sed "s/\b$alias\b//g" | tr -s ' ' | sed 's/^ *//;s/ *$//')
    
    sed -i "s/AVAILABLE_MODELS=\".*\"/AVAILABLE_MODELS=\"$updated_models\"/" "$MODEL_CONFIG_FILE"
    
    log_success "Model '$alias' removed from configuration"
    return 0
}

