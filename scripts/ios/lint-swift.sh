#!/bin/bash

# lint-swift.sh
# Runs SwiftFormat and SwiftLint in check mode (no modifications)

set -euo pipefail

TARGET_PATH="${1:-ios/Offload}"

echo "=== Swift Linting ==="
echo ""
echo "📁 Target: $TARGET_PATH"
echo ""

# Track overall status
LINT_PASSED=true

# Run SwiftFormat in lint mode
echo "🔍 Running SwiftFormat (lint mode)..."
if swiftformat --lint "$TARGET_PATH" 2>&1; then
    echo "✅ SwiftFormat: All files formatted correctly"
else
    echo "❌ SwiftFormat: Formatting issues found"
    LINT_PASSED=false
fi
echo ""

# Run SwiftLint in strict mode
echo "🔍 Running SwiftLint (strict mode)..."
if swiftlint lint --strict "$TARGET_PATH" 2>&1; then
    echo "✅ SwiftLint: No violations found"
else
    echo "❌ SwiftLint: Violations found"
    LINT_PASSED=false
fi
echo ""

# Final result
if [ "$LINT_PASSED" = true ]; then
    echo "✅ All linting checks passed!"
    exit 0
else
    echo "❌ Linting failed. Please fix the issues above."
    exit 1
fi
