#!/bin/bash

# Test Runner - Simple TDD/BDD Framework for Bash
# Supports unit tests, integration tests, and BDD scenarios

# Test framework configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$TEST_DIR")"
RESULTS_DIR="$TEST_DIR/results"
TEMP_DIR="$TEST_DIR/temp"

# Test statistics
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test framework functions

# Initialize test environment
test_init() {
    echo -e "${BLUE}🧪 Initializing Test Environment${NC}"
    
    # Create necessary directories
    mkdir -p "$RESULTS_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Clean up previous test results
    rm -f "$RESULTS_DIR"/*.log
    rm -rf "$TEMP_DIR"/*
    
    # Initialize test statistics
    TESTS_TOTAL=0
    TESTS_PASSED=0
    TESTS_FAILED=0
    TESTS_SKIPPED=0
    
    echo "Test directory: $TEST_DIR"
    echo "Project directory: $PROJECT_DIR"
    echo "Results directory: $RESULTS_DIR"
    echo ""
}

# Test assertion functions

# Assert that a command succeeds
assert_success() {
    local description="$1"
    local command="$2"
    
    ((TESTS_TOTAL++))
    
    echo -n "  ✓ $description... "
    
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "    Command: $command"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that a command fails
assert_failure() {
    local description="$1"
    local command="$2"
    
    ((TESTS_TOTAL++))
    
    echo -n "  ✗ $description... "
    
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${RED}FAIL${NC}"
        echo "    Expected command to fail: $command"
        ((TESTS_FAILED++))
        return 1
    else
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    fi
}

# Assert that two strings are equal
assert_equals() {
    local description="$1"
    local expected="$2"
    local actual="$3"
    
    ((TESTS_TOTAL++))
    
    echo -n "  = $description... "
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "    Expected: '$expected'"
        echo "    Actual: '$actual'"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that a file exists
assert_file_exists() {
    local description="$1"
    local file_path="$2"
    
    ((TESTS_TOTAL++))
    
    echo -n "  📁 $description... "
    
    if [ -f "$file_path" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "    File not found: $file_path"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that a directory exists
assert_dir_exists() {
    local description="$1"
    local dir_path="$2"
    
    ((TESTS_TOTAL++))
    
    echo -n "  📂 $description... "
    
    if [ -d "$dir_path" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "    Directory not found: $dir_path"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that a string contains a substring
assert_contains() {
    local description="$1"
    local haystack="$2"
    local needle="$3"
    
    ((TESTS_TOTAL++))
    
    echo -n "  🔍 $description... "
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "    String '$needle' not found in: '$haystack'"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Skip a test
skip_test() {
    local description="$1"
    local reason="$2"
    
    ((TESTS_TOTAL++))
    ((TESTS_SKIPPED++))
    
    echo -e "  ⏭️  $description... ${YELLOW}SKIP${NC}"
    if [ -n "$reason" ]; then
        echo "    Reason: $reason"
    fi
}

# BDD-style functions

# Describe a test suite
describe() {
    local suite_name="$1"
    echo -e "${BLUE}📋 $suite_name${NC}"
}

# Define a test context
context() {
    local context_name="$1"
    echo -e "${BLUE}  📝 $context_name${NC}"
}

# Define a test case
it() {
    local test_name="$1"
    echo -e "    🧪 $test_name"
}

# Test setup and teardown - empty by default
setup() { :; }
teardown() { :; }
setup_all() { :; }
teardown_all() { :; }

# Test discovery and execution

# Run a single test file
run_test_file() {
    local test_file="$1"
    
    if [ ! -f "$test_file" ]; then
        echo -e "${RED}❌ Test file not found: $test_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🚀 Running test file: $(basename "$test_file")${NC}"
    echo ""
    
    # Reset functions for this test file
    setup_all() { :; }
    teardown_all() { :; }
    
    # Source the test file in a controlled manner
    set +e  # Don't exit on errors
    
    # First, source only the function definitions (setup_all, teardown_all)
    # by creating a temporary file with only function definitions
    local temp_functions_file="$TEMP_DIR/$(basename "$test_file").functions"
    
    # Extract function definitions from the test file
    awk '/^(setup_all|teardown_all)\(\)/ {p=1} p && /^}$/ {print; p=0; next} p' "$test_file" > "$temp_functions_file"
    
    # Source the function definitions
    source "$temp_functions_file"
    
    # If setup_all is defined, call it first
    if declare -f setup_all >/dev/null 2>&1; then
        setup_all 2>/dev/null || echo -e "${YELLOW}⚠️  Warning: setup_all failed${NC}"
    fi
    
    # Now source the full test file to run the tests
    source "$test_file"
    
    # If teardown_all is defined, call it
    if declare -f teardown_all >/dev/null 2>&1; then
        teardown_all 2>/dev/null || echo -e "${YELLOW}⚠️  Warning: teardown_all failed${NC}"
    fi
    
    # Clean up temporary file
    rm -f "$temp_functions_file"
    
    set -e  # Re-enable exit on error
    
    echo ""
    return 0
}

# Run all test files in a directory
run_test_directory() {
    local test_dir="$1"
    
    if [ ! -d "$test_dir" ]; then
        echo -e "${RED}❌ Test directory not found: $test_dir${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🔍 Discovering tests in: $test_dir${NC}"
    
    local test_files
    test_files=($(find "$test_dir" -name "test_*.sh" -type f | sort))
    
    if [ ${#test_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No test files found in: $test_dir${NC}"
        return 0
    fi
    
    echo "Found ${#test_files[@]} test files"
    echo ""
    
    for test_file in "${test_files[@]}"; do
        run_test_file "$test_file"
    done
}

# Generate test report
generate_report() {
    local report_file="$RESULTS_DIR/test_report.txt"
    
    echo "Generating test report: $report_file"
    
    cat > "$report_file" << EOF
Claude Model Switcher - Test Report
Generated: $(date)

TEST SUMMARY:
=============
Total Tests: $TESTS_TOTAL
Passed: $TESTS_PASSED
Failed: $TESTS_FAILED
Skipped: $TESTS_SKIPPED

PASS RATE: $(( TESTS_TOTAL > 0 ? TESTS_PASSED * 100 / TESTS_TOTAL : 0 ))%

EOF

    if [ $TESTS_FAILED -gt 0 ]; then
        echo "RESULT: FAILED" >> "$report_file"
    else
        echo "RESULT: PASSED" >> "$report_file"
    fi
    
    echo "Test report generated: $report_file"
}

# Display test summary
display_summary() {
    echo ""
    echo -e "${BLUE}📊 TEST SUMMARY${NC}"
    echo "================"
    echo "Total Tests: $TESTS_TOTAL"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    echo -e "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
    
    if [ $TESTS_TOTAL -gt 0 ]; then
        local pass_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
        echo "Pass Rate: $pass_rate%"
    fi
    
    echo ""
    
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}❌ TESTS FAILED${NC}"
        return 1
    else
        echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
        return 0
    fi
}

# Cleanup test environment
test_cleanup() {
    echo -e "${BLUE}🧹 Cleaning up test environment${NC}"
    
    # Remove temporary files
    rm -rf "$TEMP_DIR"/*
    
    echo "Cleanup completed"
}

# Main test runner function
run_tests() {
    local target="${1:-all}"
    
    test_init
    
    case "$target" in
        "all")
            run_test_directory "$TEST_DIR/unit"
            run_test_directory "$TEST_DIR/integration"
            run_test_directory "$TEST_DIR/bdd"
            ;;
        "unit")
            run_test_directory "$TEST_DIR/unit"
            ;;
        "integration")
            run_test_directory "$TEST_DIR/integration"
            ;;
        "bdd")
            run_test_directory "$TEST_DIR/bdd"
            ;;
        *)
            if [ -f "$target" ]; then
                run_test_file "$target"
            elif [ -d "$target" ]; then
                run_test_directory "$target"
            else
                echo -e "${RED}❌ Unknown test target: $target${NC}"
                return 1
            fi
            ;;
    esac
    
    generate_report
    display_summary
    local result=$?
    
    test_cleanup
    
    return $result
}

# Help function
show_help() {
    cat << EOF
Test Runner - TDD/BDD Framework for Claude Model Switcher

USAGE:
    $0 [TARGET]

TARGETS:
    all           Run all tests (unit + integration + bdd)
    unit          Run unit tests only
    integration   Run integration tests only
    bdd           Run BDD tests only
    <file>        Run a specific test file
    <directory>   Run all tests in a directory

EXAMPLES:
    $0                          # Run all tests
    $0 unit                     # Run unit tests
    $0 tests/unit/test_logger.sh # Run specific test file

TEST FILE NAMING:
    test_*.sh                   # Test files must start with 'test_'

ASSERTION FUNCTIONS:
    assert_success              # Command should succeed
    assert_failure              # Command should fail
    assert_equals               # String equality
    assert_file_exists          # File exists
    assert_dir_exists           # Directory exists
    assert_contains             # String contains substring
    skip_test                   # Skip a test

BDD FUNCTIONS:
    describe                    # Test suite description
    context                     # Test context
    it                          # Test case description

SETUP/TEARDOWN:
    setup                       # Run before each test
    teardown                    # Run after each test
    setup_all                   # Run once before all tests
    teardown_all                # Run once after all tests
EOF
}

# Main execution
main() {
    local command="${1:-all}"
    
    case "$command" in
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            run_tests "$command"
            ;;
    esac
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi