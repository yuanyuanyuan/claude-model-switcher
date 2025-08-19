#!/bin/bash

# BDD Tests - User Scenarios

setup_all() {
    # Initialize test environment variables first
    export LOG_DIR="$TEMP_DIR/logs"
    export LOG_FILE="$LOG_DIR/test.log"
    export LOG_LEVEL="ERROR"  # Reduce noise
    export USE_EMOJIS="false"
    mkdir -p "$LOG_DIR"
    
    # Source app configuration first
    source "$PROJECT_DIR/config/app.conf"
    
    # Source and initialize logger first
    source "$PROJECT_DIR/lib/core/logger.sh"
    logger_init
    
    # Ensure log file exists
    touch "$LOG_FILE"
    
    # Source other modules after logger is ready
    source "$PROJECT_DIR/lib/core/config_loader.sh"
    source "$PROJECT_DIR/lib/core/validator.sh"
    source "$PROJECT_DIR/lib/managers/model_manager.sh"
    
    # Create mock environment
    export MOCK_HOME="$TEMP_DIR/mock_home"
    mkdir -p "$MOCK_HOME"
    export SWITCHER_DIR="$MOCK_HOME/.claude/claude-model-switcher"
    export CONFIG_DIR="$SWITCHER_DIR/config"
    export MODEL_CONFIG_FILE="$CONFIG_DIR/models.conf"
    export MEMORY_DIR="$SWITCHER_DIR/memory"
    
    # Setup configuration
    mkdir -p "$CONFIG_DIR"
    cp "$PROJECT_DIR/config"/*.conf "$CONFIG_DIR/"
    config_load_all "$CONFIG_DIR"
}

# Scenario: User wants to list available models
describe "BDD Scenario: Listing Available Models"

context "Given that the system is properly configured"

it "should have model configuration loaded"
assert_success "Model configuration should be loaded" "[ \${#MODEL_PROVIDERS[@]} -gt 0 ]"

context "When the user runs list_models command"

it "should display available models without errors"
# Capture output to verify content
output=$(list_models 2>&1)
assert_success "list_models should execute successfully" "list_models >/dev/null 2>&1"

it "should show model information in table format"
output=$(list_models 2>&1)
assert_contains "Output should contain table header" "$output" "Alias"
assert_contains "Output should contain provider column" "$output" "Provider"
assert_contains "Output should contain kimi model" "$output" "kimi"
assert_contains "Output should contain glm4 model" "$output" "glm4"

# Scenario: User wants to switch to a model (dry run)
describe "BDD Scenario: Model Switching (Validation Only)"

context "Given that models are configured"

it "should validate model alias before switching"
assert_success "Valid alias should pass validation" "validate_model_alias 'kimi'"
assert_failure "Invalid alias should fail validation" "validate_model_alias 'invalid@model'"

context "When user provides a valid model alias"

it "should find the model in configuration"
source "$MODEL_CONFIG_FILE"
assert_success "kimi model should exist in configuration" "[ -n \"\${MODEL_PROVIDERS[kimi]}\" ]"

it "should validate the provider"
provider="${MODEL_PROVIDERS[kimi]}"
assert_success "Provider should be valid" "validate_provider_name '$provider' '$AVAILABLE_PROVIDERS'"

# Scenario: User adds a custom model
describe "BDD Scenario: Adding Custom Model"

context "Given that the user wants to add a new model"

it "should validate new model parameters"
assert_success "New alias should be valid" "validate_model_alias 'custom-model'"
assert_success "Provider should be valid" "validate_provider_name 'moonshot' '$AVAILABLE_PROVIDERS'"

context "When the user adds the model"

it "should accept valid model configuration"
# Test the validation logic that would be used in add_model function
alias="custom-model"
provider="moonshot"
main_model="custom-api-model"
fast_model="custom-api-model-fast"
context="100K tokens"
description="Custom test model"

assert_success "All parameters should validate" "
    validate_model_alias '$alias' && 
    validate_provider_name '$provider' '$AVAILABLE_PROVIDERS' &&
    [ -n '$main_model' ] &&
    [ -n '$fast_model' ]
"

# Scenario: System health check
describe "BDD Scenario: System Health Check"

context "Given that the system is installed"

it "should have all required directories"
config_validate_environment >/dev/null 2>&1
assert_dir_exists "Switcher directory should exist" "$SWITCHER_DIR"
assert_dir_exists "Config directory should exist" "$CONFIG_DIR"
assert_dir_exists "Memory directory should exist" "$MEMORY_DIR"

context "When checking configuration files"

it "should have all required configuration files"
assert_file_exists "App config should exist" "$CONFIG_DIR/app.conf"
assert_file_exists "Models config should exist" "$CONFIG_DIR/models.conf"
assert_file_exists "Providers config should exist" "$CONFIG_DIR/providers.conf"

context "When validating configuration content"

it "should have valid configuration syntax"
assert_success "App config should have valid syntax" "config_validate_syntax '$CONFIG_DIR/app.conf'"
assert_success "Models config should have valid syntax" "config_validate_syntax '$CONFIG_DIR/models.conf'"
assert_success "Providers config should have valid syntax" "config_validate_syntax '$CONFIG_DIR/providers.conf'"

# Scenario: Error handling
describe "BDD Scenario: Error Handling"

context "Given that user provides invalid input"

it "should handle empty model alias gracefully"
# This should fail gracefully, not crash
assert_failure "Empty alias should be rejected" "validate_model_alias ''"

it "should handle unknown model alias gracefully"
# Load config first
source "$MODEL_CONFIG_FILE"
# Check for non-existent model
assert_equals "Unknown model should return empty provider" "" "${MODEL_PROVIDERS[nonexistent]}"

context "When configuration files are missing"

it "should handle missing config files gracefully"
# Test with non-existent config file
assert_failure "Missing config file should fail gracefully" "config_load '/nonexistent/path/config.conf'"