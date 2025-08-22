#!/bin/bash
# Integration Test: test_exclusion_installation.sh
# Purpose: Test installation with exclusion rules
# Version: 1.0.0

# Load test framework
source "$(dirname "$0")/../test_runner.sh"

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
    
    # Load the copy function from install.sh
    source_copy_with_exclusion() {
        local source_dir="$1"
        local target_dir="$2"
        
        # Load exclusion rules
        local exclusion_rules=()
        if [ -f "$source_dir/.claude-exclude" ]; then
            echo "Loading exclusion rules..."
            while IFS= read -r line || [ -n "$line" ]; do
                line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
                if [ -n "$line" ] && [[ ! "$line" =~ ^# ]]; then
                    exclusion_rules+=("$line")
                    echo "Exclusion rule: $line"
                fi
            done < "$source_dir/.claude-exclude"
        fi
        
        # Copy files with exclusion
        local copied=0
        local excluded=0
        
        while IFS= read -r -d '' file; do
            local rel_path="${file#$source_dir/}"
            
            # Check if excluded with exception handling
            local exclude=false
            local include_override=false
            
            for rule in "${exclusion_rules[@]}"; do
                # Handle exception rules first
                if [[ "$rule" == !* ]]; then
                    local include_pattern="${rule:1}"
                    include_pattern=$(echo "$include_pattern" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
                    
                    if [[ "$rel_path" == $include_pattern ]] || 
                       [[ "$include_pattern" == */ && "$rel_path" == "${include_pattern%/}"* ]] ||
                       [[ "$rel_path" == *"/$include_pattern" ]]; then
                        include_override=true
                    fi
                    continue
                fi
                
                # Handle exclusion rules
                if [[ "$rel_path" == $rule ]] || 
                   [[ "$rule" == */ && "$rel_path" == "${rule%/}"* ]] ||
                   [[ "$rel_path" == *"/$rule" ]]; then
                    exclude=true
                fi
            done
            
            # If there's an include override, don't exclude
            if [ "$include_override" = true ]; then
                exclude=false
            fi
            
            if [ "$exclude" = true ]; then
                echo "EXCLUDED: $rel_path"
                excluded=$((excluded + 1))
                continue
            fi
            
            # Copy the file
            local target_file="$target_dir/$rel_path"
            mkdir -p "$(dirname "$target_file")"
            if cp "$file" "$target_file"; then
                copied=$((copied + 1))
            fi
            
        done < <(find "$source_dir" -type f -print0 2>/dev/null)
        
        echo "Copied: $copied files, Excluded: $excluded files"
    }
    
    # Test the copy function
    echo "Testing installation with exclusion rules..."
    source_copy_with_exclusion "$source_dir" "$target_dir"
    
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