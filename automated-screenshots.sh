#!/bin/bash

# CallAssist Automated Screenshot Capture
# This script fully automates taking App Store screenshots

set -e

PROJECT_PATH="/Users/andrewleone/projects/CallAssist"
APP_PATH="$PROJECT_PATH/build/Build/Products/Debug-iphonesimulator/CallAssist.app"
SCREENSHOTS_DIR="$PROJECT_PATH/Screenshots"
BUNDLE_ID="com.callassist.app"

# Use available simulators
DEVICE_LARGE_UDID="6ECF589D-26A3-49D7-8A2D-C642466146A2"  # iPhone 17 Pro Max
DEVICE_LARGE_NAME="iPhone 17 Pro Max"

echo "📸 CallAssist Automated Screenshot Capture"
echo "=========================================="
echo ""

# Create directories
mkdir -p "$SCREENSHOTS_DIR/6.7-inch-raw"
mkdir -p "$SCREENSHOTS_DIR/6.5-inch-raw"
mkdir -p "$SCREENSHOTS_DIR/final"

echo "✅ Build completed successfully"
echo "📱 Using device: $DEVICE_LARGE_NAME"
echo ""

# Function to take screenshot
take_screenshot() {
    local name=$1
    local size=$2
    local device_udid=$3

    echo "  📸 Capturing: $name"
    xcrun simctl io "$device_udid" screenshot "$SCREENSHOTS_DIR/${size}-raw/${name}.png"
    sleep 1
}

# Boot simulator
echo "🚀 Booting simulator..."
xcrun simctl boot "$DEVICE_LARGE_UDID" 2>/dev/null || echo "  (Simulator already booted)"
sleep 3

# Install app
echo "📲 Installing CallAssist..."
xcrun simctl install "$DEVICE_LARGE_UDID" "$APP_PATH"

# Launch app
echo "🎬 Launching app..."
xcrun simctl launch "$DEVICE_LARGE_UDID" "$BUNDLE_ID"
sleep 5

echo ""
echo "📸 Taking screenshots..."
echo ""

# Wait for app to load
sleep 3

echo "Screenshot 1: Home Screen / New Appointment"
echo "  → Navigate to the main 'New Appointment' screen"
echo "  → Fill in example data:"
echo "     Business: Downtown Dental"
echo "     Phone: (555) 123-4567"
echo "     Service: Teeth cleaning and checkup"
echo ""
read -p "Press ENTER when ready to capture..."
take_screenshot "01-new-appointment" "6.7-inch" "$DEVICE_LARGE_UDID"

echo ""
echo "Screenshot 2: Calendar Selection"
echo "  → Tap 'Select Available Times'"
echo "  → Select 2-3 time slots"
echo ""
read -p "Press ENTER when ready to capture..."
take_screenshot "02-calendar-selection" "6.7-inch" "$DEVICE_LARGE_UDID"

echo ""
echo "Screenshot 3: Call Options with Listen In"
echo "  → Go back to main form"
echo "  → Toggle 'Listen In' ON"
echo "  → Show the filled form ready to place call"
echo ""
read -p "Press ENTER when ready to capture..."
take_screenshot "03-call-options" "6.7-inch" "$DEVICE_LARGE_UDID"

echo ""
echo "Screenshot 4: Call in Progress"
echo "  → Tap 'Place Call'"
echo "  → Wait for call status screen to show"
echo "  → Capture when status shows 'In Progress'"
echo ""
read -p "Press ENTER when ready to capture..."
take_screenshot "04-call-in-progress" "6.7-inch" "$DEVICE_LARGE_UDID"

echo ""
echo "Screenshot 5: Listen In Feature"
echo "  → Wait for Listen In sheet to appear automatically"
echo "  → Capture the audio visualization screen"
echo ""
read -p "Press ENTER when ready to capture..."
take_screenshot "05-listen-in" "6.7-inch" "$DEVICE_LARGE_UDID"

echo ""
echo "Screenshot 6: Call History"
echo "  → Go back to main app"
echo "  → Navigate to History tab"
echo "  → Show completed appointments"
echo ""
read -p "Press ENTER when ready to capture..."
take_screenshot "06-call-history" "6.7-inch" "$DEVICE_LARGE_UDID"

echo ""
echo "Screenshot 7: Purchase Minutes"
echo "  → Tap the minute balance widget (top right)"
echo "  → Show the purchase minutes screen with packages"
echo ""
read -p "Press ENTER when ready to capture..."
take_screenshot "07-purchase-minutes" "6.7-inch" "$DEVICE_LARGE_UDID"

echo ""
echo "Screenshot 8: Call Results"
echo "  → From History, tap a completed appointment"
echo "  → Show the results screen with transcript"
echo ""
read -p "Press ENTER when ready to capture..."
take_screenshot "08-call-results" "6.7-inch" "$DEVICE_LARGE_UDID"

echo ""
echo "✅ All screenshots captured!"
echo ""
echo "📁 Screenshots saved to:"
echo "   $SCREENSHOTS_DIR/6.7-inch-raw/"
echo ""
echo "Next steps:"
echo "  1. Review screenshots"
echo "  2. Add captions/overlays (optional)"
echo "  3. Upload to App Store Connect"
echo ""
