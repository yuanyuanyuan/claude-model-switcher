#!/bin/bash

# Unit Tests for Logger Module

# Setup test environment
setup_all() {
    # Create temporary log directory for testing
    TEST_LOG_DIR="$TEMP_DIR/logs"
    mkdir -p "$TEST_LOG_DIR"
    
    # Set test configuration before sourcing logger
    export LOG_DIR="$TEST_LOG_DIR"
    export LOG_FILE="$TEST_LOG_DIR/test.log"
    export LOG_LEVEL="DEBUG"
    export USE_EMOJIS="true"
    
    # Source the logger module after setting environment
    source "$PROJECT_DIR/lib/core/logger.sh"
    
    # Initialize logger
    logger_init
    
    # Verify initialization
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
    fi
    
    # Export variables for test assertions
    export TEST_LOG_DIR
}

teardown_all() {
    # Clean up test logs
    rm -rf "$TEST_LOG_DIR"
}

# Test logger initialization
describe "Logger Module - Initialization"

context "When initializing logger"

it "should create log directory"
assert_dir_exists "Log directory should be created" "$TEST_LOG_DIR"

it "should create log file"
assert_file_exists "Log file should be created" "$LOG_FILE"

it "should set global variables"
assert_equals "LOGGER_FILE should be set" "$LOG_FILE" "$LOGGER_FILE"
assert_equals "LOGGER_LEVEL should be set" "DEBUG" "$LOGGER_LEVEL"

# Test logging functions
describe "Logger Module - Logging Functions"

context "When logging messages"

it "should log debug messages"
log_debug "Test debug message"
assert_success "Debug message should be logged" "grep 'Test debug message' '$LOG_FILE'"

it "should log info messages"
log_info "Test info message"
assert_success "Info message should be logged" "grep 'Test info message' '$LOG_FILE'"

it "should log warning messages"
log_warn "Test warning message"
assert_success "Warning message should be logged" "grep 'Test warning message' '$LOG_FILE'"

it "should log error messages"
log_error "Test error message"
assert_success "Error message should be logged" "grep 'Test error message' '$LOG_FILE'"

it "should log success messages"
log_success "Test success message"
assert_success "Success message should be logged" "grep 'Test success message' '$LOG_FILE'"

# Test log levels
describe "Logger Module - Log Levels"

context "When log level is INFO"

it "should not log debug messages when level is INFO"
export LOGGER_LEVEL="INFO"
log_debug "Debug message that should not appear"
assert_failure "Debug message should not be logged at INFO level" "grep 'Debug message that should not appear' '$LOG_FILE'"

it "should log info messages when level is INFO"
log_info "Info message that should appear"
assert_success "Info message should be logged at INFO level" "grep 'Info message that should appear' '$LOG_FILE'"

# Test log formatting
describe "Logger Module - Formatting"

context "When logging with timestamps"

it "should include timestamps in log file"
log_info "Timestamp test message"
assert_success "Log should contain timestamp" "grep '\\[.*\\] \\[INFO\\] Timestamp test message' '$LOG_FILE'"

# Test utility functions
describe "Logger Module - Utility Functions"

context "When using utility functions"

it "should create log separators"
log_separator "-" 10
assert_success "Log separator should be created" "grep -- '-----------*' '$LOG_FILE'"

it "should create log headers"
log_header "Test Header"
assert_success "Log header should be created" "grep 'Test Header' '$LOG_FILE'"