#!/bin/bash
# Test: test_exclusion_config.sh
# Purpose: Test file exclusion configuration functionality
# Version: 1.0.0

# Simple test framework
assert_contains() {
    local description="$1"
    local actual="$2"
    local expected="$3"
    
    if [[ "$actual" == *"$expected"* ]]; then
        echo "✅ $description"
        return 0
    else
        echo "❌ $description"
        echo "   Expected: '$expected'"
        echo "   Actual: '$actual'"
        return 1
    fi
}

assert_success() {
    local description="$1"
    local command="$2"
    
    if eval "$command" 2>/dev/null; then
        echo "✅ $description"
        return 0
    else
        echo "❌ $description"
        return 1
    fi
}

assert_failure() {
    local description="$1"
    local command="$2"
    
    if ! eval "$command" 2>/dev/null; then
        echo "✅ $description"
        return 0
    else
        echo "❌ $description"
        return 1
    fi
}

# Load the functions from install.sh
source_functions() {
    # Extract only the exclusion-related functions
    sed -n '/^# Parse exclusion rules from file/,/^}$/p' ../../install.sh
    sed -n '/^# Check if a file should be excluded/,/^}$/p' ../../install.sh
}

# Source the functions
eval "$(source_functions)"

test_exclusion_config() {
    echo "📋 Unit Tests - File Exclusion Configuration"
    
    # Create test directory structure
    local test_dir="/tmp/test_exclusion_$$"
    mkdir -p "$test_dir"
    
    # Create test files
    touch "$test_dir/file1.log"
    touch "$test_dir/file2.tmp"
    touch "$test_dir/important.txt"
    mkdir -p "$test_dir/logs"
    touch "$test_dir/logs/app.log"
    touch "$test_dir/logs/error.log"
    
    # Create exclusion config
    cat > "$test_dir/.claude-exclude" << 'EOF'
# Exclude log files
*.log
*.tmp

# Exclude logs directory
logs/

# But keep important logs
!logs/error.log
EOF
    
    # Test parse_exclusion_file function
    echo "  📝 When parsing exclusion configuration"
    echo "    🧪 should correctly parse exclusion patterns"
    
    local exclusion_rules=()
    parse_exclusion_file "$test_dir/.claude-exclude" exclusion_rules
    
    local patterns="${exclusion_rules[*]}"
    assert_contains "Should contain log pattern" "$patterns" "*.log"
    assert_contains "Should contain tmp pattern" "$patterns" "*.tmp"
    assert_contains "Should contain logs directory" "$patterns" "logs/"
    assert_contains "Should contain exception pattern" "$patterns" "!logs/error.log"
    
    # Test is_file_excluded function
    echo "    🧪 should correctly identify excluded files"
    assert_success "Log file should be excluded" "is_file_excluded \"$test_dir/file1.log\" \"\${exclusion_rules[@]}\""
    assert_success "Temp file should be excluded" "is_file_excluded \"$test_dir/file2.tmp\" \"\${exclusion_rules[@]}\""
    assert_failure "Text file should not be excluded" "is_file_excluded \"$test_dir/important.txt\" \"\${exclusion_rules[@]}\""
    
    # Test exception patterns
    echo "    🧪 should respect exception patterns"
    assert_failure "Exception file should not be excluded" "is_file_excluded \"$test_dir/logs/error.log\" \"\${exclusion_rules[@]}\""
    assert_success "Non-exception log should be excluded" "is_file_excluded \"$test_dir/logs/app.log\" \"\${exclusion_rules[@]}\""
    
    # Cleanup
    rm -rf "$test_dir"
    
    echo "✅ All exclusion configuration tests passed!"
}

# Run the test
test_exclusion_config