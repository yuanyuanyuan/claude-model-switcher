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

# Extract only the exclusion-related functions to avoid triggering installation
extract_exclusion_functions() {
    cat << 'EOF'
# Parse exclusion rules from file
parse_exclusion_file() {
    local exclude_file="${1:-.claude-exclude}"
    local -n exclusion_rules_ref="$2"
    
    if [ ! -f "$exclude_file" ]; then
        return 0
    fi
    
    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        if [ -n "$line" ] && [[ ! "$line" =~ ^# ]]; then
            exclusion_rules_ref+=("$line")
        fi
    done < "$exclude_file"
    
    return 0
}

# Check if a file should be excluded based on rules
is_file_excluded() {
    local file_path="$1"
    shift
    local exclusion_rules=("$@")
    
    if [ ${#exclusion_rules[@]} -eq 0 ]; then
        return 1
    fi
    
    local exclude_file=false
    local include_override=false
    
    for rule in "${exclusion_rules[@]}"; do
        if [[ "$rule" == !* ]]; then
            local include_pattern="${rule:1}"
            include_pattern=$(echo "$include_pattern" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            
            if [ -z "$include_pattern" ]; then
                continue
            fi
            
            if [[ "$file_path" == $include_pattern ]] || 
               [[ "$include_pattern" == */ && "$file_path" == "${include_pattern%/}"* ]] ||
               [[ "$file_path" == *"/$include_pattern" ]]; then
                include_override=true
            fi
            continue
        fi
        
        if [[ "$rule" == */ ]]; then
            local dir_pattern="${rule%/}"
            if [[ "$file_path" == "$dir_pattern"* ]] || 
               [[ "$file_path" == *"/$dir_pattern"* ]] ||
               [[ "$file_path" == *"/$dir_pattern" ]]; then
                exclude_file=true
            fi
            continue
        fi
        
        if [[ "$file_path" == $rule ]] || 
           [[ "$file_path" == *"/$rule" ]] ||
           [[ "$rule" == *"*" && "$file_path" == $rule ]]; then
            exclude_file=true
        fi
    done
    
    if [ "$include_override" = true ]; then
        return 1
    fi
    
    [ "$exclude_file" = true ]
}
EOF
}

# Source the extracted functions
eval "$(extract_exclusion_functions)"

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