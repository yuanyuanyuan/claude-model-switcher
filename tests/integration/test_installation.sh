#!/bin/bash

# Integration Tests for Installation Process

setup_all() {
    # Source main script modules
    source "$PROJECT_DIR/config/app.conf"
    source "$PROJECT_DIR/lib/core/logger.sh"
    source "$PROJECT_DIR/lib/core/config_loader.sh"
    source "$PROJECT_DIR/lib/core/validator.sh"
    
    # Initialize logger for testing
    export LOG_DIR="$TEMP_DIR/logs"
    export LOG_FILE="$LOG_DIR/test.log"
    export LOG_LEVEL="INFO"
    mkdir -p "$LOG_DIR"
    logger_init
    
    # Create mock installation environment
    export MOCK_HOME="$TEMP_DIR/mock_home"
    mkdir -p "$MOCK_HOME"
    
    # Override paths for testing
    export SWITCHER_DIR="$MOCK_HOME/.claude/claude-model-switcher"
    export CONFIG_DIR="$SWITCHER_DIR/config"
    export MODEL_CONFIG_FILE="$CONFIG_DIR/models.conf"
}

teardown_all() {
    # Clean up mock environment
    rm -rf "$MOCK_HOME"
}

# Test configuration loading
describe "Integration Tests - Configuration System"

context "When loading configurations"
it "should load all configuration files successfully"
# Copy config files to test environment
mkdir -p "$CONFIG_DIR"
cp "$PROJECT_DIR/config"/*.conf "$CONFIG_DIR/"
assert_success "All configurations should load" "config_load_all '$CONFIG_DIR'"

it "should validate configuration completeness"
assert_success "Configuration should be complete" "validate_configuration_completeness"

# Test directory structure creation
describe "Integration Tests - Directory Structure"

context "When creating directory structure"
it "should create all required directories"
assert_success "Environment validation should create directories" "config_validate_environment"

it "should create switcher directory"
assert_dir_exists "Switcher directory should exist" "$SWITCHER_DIR"

it "should create config directory"
assert_dir_exists "Config directory should exist" "$CONFIG_DIR"

it "should create memory directory"
assert_dir_exists "Memory directory should exist" "$MEMORY_DIR"

it "should create log directory"
assert_dir_exists "Log directory should exist" "$LOG_DIR"

# Test model configuration
describe "Integration Tests - Model Configuration"

context "When working with model configuration"
it "should load model definitions"
assert_success "Model configuration should load" "config_load '$MODEL_CONFIG_FILE'"

it "should have default models configured"
# Source the models config to check arrays
source "$MODEL_CONFIG_FILE"
assert_success "Should have kimi model" "[ -n \"\${MODEL_PROVIDERS[kimi]}\" ]"
assert_success "Should have glm4 model" "[ -n \"\${MODEL_PROVIDERS[glm4]}\" ]"

# Test system validation
describe "Integration Tests - System Validation"

context "When validating system requirements"
it "should validate bash version"
assert_success "Bash version should be valid" "validate_shell_type"

it "should check required commands"
assert_success "Required commands should be available" "command -v curl && command -v sed && command -v grep"
