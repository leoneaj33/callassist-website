#!/bin/bash

# CallAssist Screenshot Automation Script
# This script builds the app and prepares for screenshot capture

set -e

echo "📸 CallAssist Screenshot Automation"
echo "===================================="
echo ""

# Configuration
PROJECT_PATH="/Users/andrewleone/projects/CallAssist"
SCHEME="CallAssist"
SCREENSHOTS_DIR="$PROJECT_PATH/Screenshots"

# Device identifiers
DEVICE_67="iPhone 15 Pro Max"  # 6.7" display - 1290x2796
DEVICE_55="iPhone 8 Plus"       # 5.5" display - 1242x2208

echo "🔧 Setting up screenshot directories..."
mkdir -p "$SCREENSHOTS_DIR/6.7-inch"
mkdir -p "$SCREENSHOTS_DIR/5.5-inch"
mkdir -p "$SCREENSHOTS_DIR/Raw"

echo ""
echo "📱 Required Simulators:"
echo "  - iPhone 15 Pro Max (6.7\" display)"
echo "  - iPhone 8 Plus (5.5\" display)"
echo ""

# Check if simulators exist
echo "🔍 Checking available simulators..."
xcrun simctl list devices | grep -E "(iPhone 15 Pro Max|iPhone 8 Plus)" || {
    echo "⚠️  Required simulators not found!"
    echo "Creating simulators..."
    xcrun simctl create "$DEVICE_67" "iPhone 15 Pro Max" || true
    xcrun simctl create "$DEVICE_55" "iPhone 8 Plus" || true
}

echo ""
echo "🏗️  Building CallAssist for Simulator..."
cd "$PROJECT_PATH"

# Build for simulator
xcodebuild -project CallAssist.xcodeproj \
    -scheme "$SCHEME" \
    -sdk iphonesimulator \
    -configuration Debug \
    -derivedDataPath ./build \
    clean build | grep -E '(error|warning|succeeded|BUILD)'

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "📸 Screenshot Capture Instructions:"
echo "===================================="
echo ""
echo "I've prepared everything. Now follow these steps:"
echo ""
echo "STEP 1: Launch iPhone 15 Pro Max Simulator"
echo "  Run: open -a Simulator --args -CurrentDeviceUDID \$(xcrun simctl list devices | grep 'iPhone 15 Pro Max' | grep -v 'unavailable' | head -1 | grep -oE '\([^)]+\)' | tr -d '()')"
echo ""
echo "STEP 2: Install and Launch App"
echo "  Run: xcrun simctl install booted ./build/Build/Products/Debug-iphonesimulator/CallAssist.app"
echo "  Run: xcrun simctl launch booted com.callassist.app"
echo ""
echo "STEP 3: Take Screenshots (I'll provide commands for each screen)"
echo ""
echo "SCREENSHOTS TO CAPTURE:"
echo "  1. New Appointment Form (main screen)"
echo "  2. Calendar/Availability Selection"
echo "  3. Call in Progress"
echo "  4. Listen In Feature"
echo "  5. Call History"
echo "  6. Purchase Minutes"
echo "  7. Call Results/Transcript"
echo ""
echo "Screenshot Command Template:"
echo "  xcrun simctl io booted screenshot \"$SCREENSHOTS_DIR/Raw/01-name.png\""
echo ""
echo "Ready to begin? (I'll guide you through each screenshot)"
