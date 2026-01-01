#!/bin/bash

# check-coverage.sh
# Extracts coverage from .xcresult bundle and enforces minimum threshold

set -euo pipefail

# Configuration
MINIMUM_COVERAGE=50.0
XCRESULT_PATH="${1:-}"

if [ -z "$XCRESULT_PATH" ]; then
    echo "❌ Error: Missing .xcresult path"
    echo "Usage: $0 <path-to-xcresult-bundle>"
    exit 1
fi

if [ ! -d "$XCRESULT_PATH" ]; then
    echo "❌ Error: .xcresult bundle not found at: $XCRESULT_PATH"
    exit 1
fi

echo "=== Coverage Analysis ==="
echo ""
echo "📊 Analyzing coverage from: $XCRESULT_PATH"
echo ""

# Extract coverage report using xccov
COVERAGE_REPORT=$(xcrun xccov view --report --json "$XCRESULT_PATH" 2>/dev/null || {
    echo "❌ Error: Failed to extract coverage report"
    echo "   Ensure the .xcresult bundle contains coverage data"
    echo "   Run tests with -enableCodeCoverage YES"
    exit 1
})

# Parse the line coverage percentage
# The JSON structure has a top-level "lineCoverage" field
LINE_COVERAGE=$(echo "$COVERAGE_REPORT" | python3 -c "
import sys
import json
try:
    data = json.load(sys.stdin)
    coverage = data.get('lineCoverage', 0) * 100
    print(f'{coverage:.2f}')
except Exception as e:
    print('0.00', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null || echo "0.00")

echo "📈 Line Coverage: ${LINE_COVERAGE}%"
echo "🎯 Minimum Required: ${MINIMUM_COVERAGE}%"
echo ""

# Compare coverage using bc (handles floating point)
COVERAGE_MET=$(echo "$LINE_COVERAGE >= $MINIMUM_COVERAGE" | bc -l)

if [ "$COVERAGE_MET" -eq 1 ]; then
    echo "✅ Coverage threshold met!"
    echo ""
    exit 0
else
    DEFICIT=$(echo "$MINIMUM_COVERAGE - $LINE_COVERAGE" | bc -l)
    echo "❌ Coverage below minimum threshold"
    echo "   Need ${DEFICIT}% more coverage to pass"
    echo ""
    exit 1
fi
