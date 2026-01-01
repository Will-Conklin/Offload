#!/bin/bash

# setup-simulator.sh
# Validates iOS simulator availability and confirms target device exists

set -euo pipefail

echo "=== iOS Simulator Setup ==="
echo ""

# Check if Xcode is available
if ! command -v xcrun &> /dev/null; then
    echo "❌ Error: xcrun not found. Xcode Command Line Tools are not installed."
    exit 1
fi

echo "✅ Xcode Command Line Tools found"
echo ""

# List all available iOS simulators
echo "📱 Available iOS Simulators:"
echo ""
xcrun simctl list devices available iPhone | grep -v "^--" | grep "iPhone" || {
    echo "❌ Error: No iPhone simulators found"
    exit 1
}
echo ""

# Preferred devices in order of preference
PREFERRED_DEVICES=(
    "iPhone 16 Pro"
    "iPhone 16"
    "iPhone 15 Pro"
    "iPhone 15"
    "iPhone 14 Pro"
    "iPhone 14"
)

# Check for preferred devices
echo "🔍 Checking for preferred devices..."
FOUND_DEVICE=""

for device in "${PREFERRED_DEVICES[@]}"; do
    if xcrun simctl list devices available | grep -q "$device"; then
        FOUND_DEVICE="$device"
        echo "✅ Found: $device"
        break
    fi
done

if [ -z "$FOUND_DEVICE" ]; then
    echo "⚠️  Warning: None of the preferred devices found"
    echo "    Using any available iPhone simulator"
    FOUND_DEVICE=$(xcrun simctl list devices available iPhone | grep "iPhone" | head -n 1 | sed 's/^[[:space:]]*//' | cut -d '(' -f1 | sed 's/[[:space:]]*$//')
    echo "    Selected: $FOUND_DEVICE"
else
    echo ""
    echo "✅ Simulator validation complete"
fi

echo ""
echo "📋 Recommended xcodebuild destination:"
echo "   -destination 'platform=iOS Simulator,name=$FOUND_DEVICE,OS=latest'"
echo ""

exit 0
