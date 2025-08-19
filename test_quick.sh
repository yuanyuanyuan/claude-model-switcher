#!/bin/bash

# Quick test script to validate fixes
cd "$(dirname "$0")"

echo "🧪 Quick Test - Validating Fixes"
echo "================================"

# Test 1: Check if test runner executes
echo "1. Testing test runner basic execution..."
if ./tests/test_runner.sh help >/dev/null 2>&1; then
    echo "✅ Test runner help works"
else
    echo "❌ Test runner help failed"
fi

# Test 2: Check if logger module loads
echo "2. Testing logger module loading..."
if bash -c 'source lib/core/logger.sh; logger_init >/dev/null 2>&1 && echo "Logger OK"' 2>/dev/null | grep -q "Logger OK"; then
    echo "✅ Logger module loads successfully"
else
    echo "❌ Logger module loading failed"
fi

# Test 3: Check if validator module loads
echo "3. Testing validator module loading..."
if bash -c 'source lib/core/logger.sh; logger_init >/dev/null 2>&1; source lib/core/validator.sh; validate_model_alias "test" >/dev/null 2>&1 && echo "Validator OK"' 2>/dev/null | grep -q "Validator OK"; then
    echo "✅ Validator module loads successfully"
else
    echo "❌ Validator module loading failed"
fi

# Test 4: Run a single unit test
echo "4. Testing single unit test execution..."
if timeout 30s ./tests/test_runner.sh tests/unit/test_logger.sh 2>/dev/null | grep -q "TEST SUMMARY"; then
    echo "✅ Single test execution works"
else
    echo "❌ Single test execution failed"
fi

echo ""
echo "Quick validation completed!"
