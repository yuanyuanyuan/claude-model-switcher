#!/bin/bash

# Unit Tests for Validator Module

setup_all() {
    # Initialize logger for testing first
    export LOG_DIR="$TEMP_DIR/logs"
    export LOG_FILE="$LOG_DIR/test.log"
    export LOG_LEVEL="ERROR"  # Reduce noise in tests
    export USE_EMOJIS="false"  # Reduce noise in test output
    mkdir -p "$LOG_DIR"
    
    # Source required modules in correct order
    source "$PROJECT_DIR/lib/core/logger.sh"
    logger_init
    
    # Ensure log file exists
    touch "$LOG_FILE"
    
    # Now source validator after logger is initialized
    source "$PROJECT_DIR/lib/core/validator.sh"
}

# Test model alias validation
describe "Validator Module - Model Alias Validation"

context "When validating model aliases"

it "should accept valid aliases"
assert_success "Valid alias 'kimi' should pass" "validate_model_alias 'kimi'"
assert_success "Valid alias 'glm4' should pass" "validate_model_alias 'glm4'"
assert_success "Valid alias 'my-model' should pass" "validate_model_alias 'my-model'"
assert_success "Valid alias 'model_123' should pass" "validate_model_alias 'model_123'"

it "should reject invalid aliases"
assert_failure "Empty alias should fail" "validate_model_alias ''"
assert_failure "Alias with spaces should fail" "validate_model_alias 'my model'"
assert_failure "Alias with special chars should fail" "validate_model_alias 'model@123'"
assert_failure "Too long alias should fail" "validate_model_alias 'this_is_a_very_long_model_alias_name'"

# Test provider name validation
describe "Validator Module - Provider Validation"

context "When validating provider names"

it "should accept valid providers"
export AVAILABLE_PROVIDERS="moonshot zhipu openai"
assert_success "Valid provider 'moonshot' should pass" "validate_provider_name 'moonshot'"
assert_success "Valid provider 'zhipu' should pass" "validate_provider_name 'zhipu'"

it "should reject invalid providers"
assert_failure "Empty provider should fail" "validate_provider_name ''"
assert_failure "Unknown provider should fail" "validate_provider_name 'unknown'"

# Test API key validation
describe "Validator Module - API Key Validation"

context "When validating API keys"

it "should accept valid API keys"
assert_success "Valid generic API key should pass" "validate_api_key 'sk-1234567890abcdef1234567890abcdef12345678'"
assert_success "Long API key should pass" "validate_api_key '1234567890abcdef1234567890abcdef12345678901234567890'"

it "should reject invalid API keys"
assert_failure "Empty API key should fail" "validate_api_key ''"
assert_failure "Too short API key should fail" "validate_api_key '123'"

# Test URL validation
describe "Validator Module - URL Validation"

context "When validating URLs"

it "should accept valid URLs"
assert_success "HTTPS URL should pass" "validate_url 'https://api.example.com'"
assert_success "HTTP URL should pass" "validate_url 'http://api.example.com'"
assert_success "URL with port should pass" "validate_url 'https://api.example.com:8080'"
assert_success "URL with path should pass" "validate_url 'https://api.example.com/v1/api'"

it "should reject invalid URLs"
assert_failure "Empty URL should fail" "validate_url ''"
assert_failure "Invalid protocol should fail" "validate_url 'ftp://example.com'"
assert_failure "No protocol should fail" "validate_url 'example.com'"
assert_failure "Invalid format should fail" "validate_url 'https://'"

# Test version validation
describe "Validator Module - Version Validation"

context "When validating version strings"

it "should accept valid versions"
assert_success "Semantic version should pass" "validate_version '1.0.0'"
assert_success "Version with pre-release should pass" "validate_version '1.0.0-alpha'"
assert_success "Version with build should pass" "validate_version '1.0.0-alpha.1'"

it "should reject invalid versions"
assert_failure "Empty version should fail" "validate_version ''"
assert_failure "Invalid format should fail" "validate_version '1.0'"
assert_failure "Non-numeric should fail" "validate_version 'v1.0.0'"

# Test file path validation
describe "Validator Module - File Path Validation"

context "When validating file paths"

it "should accept valid file paths"
assert_success "Absolute path should pass" "validate_file_path '/tmp/test.txt'"
assert_success "Relative path should pass" "validate_file_path 'config/app.conf'"

it "should reject invalid file paths"
assert_failure "Empty path should fail" "validate_file_path ''"

it "should check file existence when required"
# Create a test file
touch "$TEMP_DIR/existing_file.txt"
assert_success "Existing file should pass existence check" "validate_file_path '$TEMP_DIR/existing_file.txt' true"
assert_failure "Non-existing file should fail existence check" "validate_file_path '$TEMP_DIR/missing_file.txt' true"