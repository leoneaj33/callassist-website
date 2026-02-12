#!/bin/bash

# Add professional captions to CallAssist screenshots

SCREENSHOTS_DIR="/Users/andrewleone/projects/CallAssist/Screenshots"
RAW_DIR="$SCREENSHOTS_DIR/6.7-inch-raw"
OUTPUT_DIR="$SCREENSHOTS_DIR/final"

mkdir -p "$OUTPUT_DIR"

echo "🎨 Adding Captions to Screenshots"
echo "=================================="
echo ""

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "📦 Installing ImageMagick..."
    brew install imagemagick || {
        echo "⚠️  ImageMagick installation failed"
        echo "Please install manually: brew install imagemagick"
        exit 1
    }
fi

# Caption configuration
CAPTION_BG="#007AFF"          # iOS blue
CAPTION_TEXT="#FFFFFF"        # White text
CAPTION_HEIGHT=200            # Pixels
FONT_SIZE=48

echo "✅ ImageMagick ready"
echo ""

# Function to add caption
add_caption() {
    local input_file=$1
    local output_file=$2
    local caption_text=$3

    echo "  Adding caption: \"$caption_text\""

    # Create caption banner
    convert "$input_file" \
        -gravity South \
        -background "$CAPTION_BG" \
        -fill "$CAPTION_TEXT" \
        -font "Helvetica-Bold" \
        -pointsize $FONT_SIZE \
        -size 1320x$CAPTION_HEIGHT \
        -splice 0x$CAPTION_HEIGHT \
        -annotate +0+$(($CAPTION_HEIGHT/2-20)) "$caption_text" \
        "$output_file"

    echo "  ✅ Saved: $output_file"
    echo ""
}

# Screenshot 1: New Appointment
if [ -f "$RAW_DIR/01-new-appointment-filled.png" ]; then
    add_caption \
        "$RAW_DIR/01-new-appointment-filled.png" \
        "$OUTPUT_DIR/01-new-appointment.png" \
        "Book appointments in seconds"
fi

# Screenshot 2: Calendar
if [ -f "$RAW_DIR/02-calendar-selection.png" ]; then
    add_caption \
        "$RAW_DIR/02-calendar-selection.png" \
        "$OUTPUT_DIR/02-calendar.png" \
        "Syncs with your calendar automatically"
fi

# Screenshot 3: Listen In Toggle
if [ -f "$RAW_DIR/03-ready-to-call.png" ]; then
    add_caption \
        "$RAW_DIR/03-ready-to-call.png" \
        "$OUTPUT_DIR/03-listen-in-option.png" \
        "Listen to calls in real-time"
fi

# Screenshot 4: Call in Progress
if [ -f "$RAW_DIR/04-call-in-progress.png" ]; then
    add_caption \
        "$RAW_DIR/04-call-in-progress.png" \
        "$OUTPUT_DIR/04-call-progress.png" \
        "AI calls businesses on your behalf"
fi

# Screenshot 5: Listen In
if [ -f "$RAW_DIR/05-listen-in.png" ]; then
    add_caption \
        "$RAW_DIR/05-listen-in.png" \
        "$OUTPUT_DIR/05-listen-in-feature.png" \
        "Hear the conversation and take control"
fi

# Screenshot 6: History
if [ -f "$RAW_DIR/06-call-history.png" ]; then
    add_caption \
        "$RAW_DIR/06-call-history.png" \
        "$OUTPUT_DIR/06-history.png" \
        "Complete call history with transcripts"
fi

# Screenshot 7: Purchase
if [ -f "$RAW_DIR/07-purchase-minutes.png" ]; then
    add_caption \
        "$RAW_DIR/07-purchase-minutes.png" \
        "$OUTPUT_DIR/07-pricing.png" \
        "Pay only for what you use"
fi

# Screenshot 8: Results (if available)
if [ -f "$RAW_DIR/08-call-results.png" ]; then
    add_caption \
        "$RAW_DIR/08-call-results.png" \
        "$OUTPUT_DIR/08-results.png" \
        "Full transcripts of every call"
fi

echo ""
echo "✅ All captions added!"
echo ""
echo "📁 Final screenshots saved to:"
echo "   $OUTPUT_DIR/"
echo ""
echo "Next: Upload to App Store Connect"
