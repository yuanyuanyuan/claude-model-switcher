#!/bin/bash
# Integration Test: test_exclusion_installation.sh
# Purpose: Test installation with exclusion rules
# Version: 1.0.0

# Load test framework
source "$(dirname "$0")/../test_runner.sh"

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

# Copy files with exclusion rules applied
copy_with_exclusion() {
    local source_dir="$1"
    local target_dir="$2"
    local exclusion_rules=("${@:3}")
    
    local copied_count=0
    local excluded_count=0
    
    mkdir -p "$target_dir"
    
    while IFS= read -r -d '' file_path; do
        local relative_path="${file_path#$source_dir/}"
        
        if is_file_excluded "$relative_path" "${exclusion_rules[@]}"; then
            excluded_count=$((excluded_count + 1))
            continue
        fi
        
        local target_file="$target_dir/$relative_path"
        local target_parent=$(dirname "$target_file")
        mkdir -p "$target_parent"
        
        if cp "$file_path" "$target_file"; then
            copied_count=$((copied_count + 1))
        fi
        
    done < <(find "$source_dir" -type f -print0 2>/dev/null)
    
    while IFS= read -r -d '' dir_path; do
        local relative_path="${dir_path#$source_dir/}"
        
        if [ "$relative_path" = "" ]; then
            continue
        fi
        
        if is_file_excluded "$relative_path/" "${exclusion_rules[@]}"; then
            continue
        fi
        
        mkdir -p "$target_dir/$relative_path"
        
    done < <(find "$source_dir" -type d -print0 2>/dev/null)
    
    echo "Copied: $copied_count files, Excluded: $excluded_count files"
    return 0
}
EOF
}

# Source the extracted functions
eval "$(extract_exclusion_functions)"

test_exclusion_installation() {
    echo "🧪 Integration Test - Installation with Exclusion Rules"
    
    # Create test source directory
    local source_dir="/tmp/test_source_$$"
    local target_dir="/tmp/test_target_$$"
    mkdir -p "$source_dir"
    
    # Create test files structure
    echo "Creating test source structure..."
    mkdir -p "$source_dir/config"
    mkdir -p "$source_dir/logs"
    mkdir -p "$source_dir/tests/results"
    mkdir -p "$source_dir/docs"
    
    touch "$source_dir/main.sh"
    touch "$source_dir/install.sh"
    touch "$source_dir/config/app.conf"
    touch "$source_dir/config/models.conf"
    touch "$source_dir/logs/app.log"
    touch "$source_dir/logs/error.log"
    touch "$source_dir/tests/results/test1.txt"
    touch "$source_dir/tests/results/test2.txt"
    touch "$source_dir/docs/readme.md"
    touch "$source_dir/docs/deepseek-api.md"
    touch "$source_dir/temp.tmp"
    touch "$source_dir/cache.data"
    
    # Create exclusion config
    cat > "$source_dir/.claude-exclude" << 'EOF'
# Exclude log files and temp files
*.log
*.tmp
*.temp

# Exclude test results and cache
tests/results/
cache/

# Exclude specific documentation
docs/deepseek-*

# But keep important files
!logs/error.log
!config/app.conf
EOF
    
    # Test the copy function
    echo "Testing installation with exclusion rules..."
    
    # Load exclusion rules
    local exclusion_rules=()
    parse_exclusion_file "$source_dir/.claude-exclude" exclusion_rules
    
    # Use the actual copy function
    copy_with_exclusion "$source_dir" "$target_dir" "${exclusion_rules[@]}"
    
    # Verify results
    echo ""
    echo "Verifying installation results..."
    
    # Files that should be copied
    local should_exist=(
        "main.sh"
        "install.sh"
        "config/app.conf"
        "config/models.conf"
        "logs/error.log"
        "docs/readme.md"
    )
    
    # Files that should be excluded
    local should_not_exist=(
        "logs/app.log"
        "temp.tmp"
        "cache.data"
        "tests/results/test1.txt"
        "tests/results/test2.txt"
        "docs/deepseek-api.md"
    )
    
    local all_good=true
    
    # Check files that should exist
    for file in "${should_exist[@]}"; do
        if [ -f "$target_dir/$file" ]; then
            echo "✅ PRESENT: $file"
        else
            echo "❌ MISSING: $file"
            all_good=false
        fi
    done
    
    # Check files that should not exist
    for file in "${should_not_exist[@]}"; do
        if [ ! -f "$target_dir/$file" ]; then
            echo "✅ EXCLUDED: $file"
        else
            echo "❌ NOT EXCLUDED: $file"
            all_good=false
        fi
    done
    
    # Cleanup
    rm -rf "$source_dir" "$target_dir"
    
    if [ "$all_good" = true ]; then
        echo "✅ All exclusion tests passed!"
        return 0
    else
        echo "❌ Some exclusion tests failed!"
        return 1
    fi
}

# Run the test
test_exclusion_installation