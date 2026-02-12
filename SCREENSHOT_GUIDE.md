# CallAssist App Store Screenshots Guide

## 📸 Quick Start

Your app is already running in the simulator! I've taken the first screenshot.

**Simulator:** iPhone 17 Pro Max (1320x2868) - Perfect for App Store
**Screenshot Directory:** `/Users/andrewleone/projects/CallAssist/Screenshots/6.7-inch-raw/`

---

## 🎬 8 Screenshots to Capture

### Screenshot 1: New Appointment Form ✅
**Status:** Initial screenshot taken!
**File:** `00-app-launched.png`

**What to show:** Clean, professional appointment booking form

---

### Screenshot 2: Filled Appointment Form
**Actions:**
1. In the simulator, fill in these details:
   - **Business Name:** "Downtown Dental"
   - **Phone Number:** "(555) 123-4567"
   - **Service Description:** "Teeth cleaning and annual checkup"

2. Take screenshot:
```bash
xcrun simctl io 6ECF589D-26A3-49D7-8A2D-C642466146A2 screenshot ~/projects/CallAssist/Screenshots/6.7-inch-raw/01-new-appointment-filled.png
```

**Caption for App Store:** "Book appointments in seconds - just enter business details and your needs"

---

### Screenshot 3: Calendar Selection
**Actions:**
1. Tap **"Select Available Times"**
2. Choose **2-3 time slots** (e.g., Tomorrow 2-4pm, Friday 10am-12pm)
3. Screenshot shows selected times highlighted

4. Take screenshot:
```bash
xcrun simctl io 6ECF589D-26A3-49D7-8A2D-C642466146A2 screenshot ~/projects/CallAssist/Screenshots/6.7-inch-raw/02-calendar-selection.png
```

**Caption for App Store:** "Syncs with your calendar to find available times automatically"

---

### Screenshot 4: Listen In Toggle
**Actions:**
1. Go back to main form (should still have data)
2. Scroll down to **"Call Options"**
3. Toggle **"Listen In"** to ON
4. Form should show:
   - Business details filled
   - Times selected
   - Listen In enabled
   - "Place Call" button visible

5. Take screenshot:
```bash
xcrun simctl io 6ECF589D-26A3-49D7-8A2D-C642466146A2 screenshot ~/projects/CallAssist/Screenshots/6.7-inch-raw/03-ready-to-call.png
```

**Caption for App Store:** "Listen to the AI make the call in real-time or join the conversation"

---

### Screenshot 5: Call in Progress
**Actions:**
1. Tap **"Place Call"**
2. Wait for the call status screen
3. Capture when it shows:
   - Animated phone icon
   - Status: "In Progress" or "Ringing..."
   - Business name displayed

4. Take screenshot:
```bash
xcrun simctl io 6ECF589D-26A3-49D7-8A2D-C642466146A2 screenshot ~/projects/CallAssist/Screenshots/6.7-inch-raw/04-call-in-progress.png
```

**Caption for App Store:** "AI calls businesses on your behalf - track progress in real-time"

---

### Screenshot 6: Listen In Feature
**Actions:**
1. If Listen In was enabled, the sheet should open automatically
2. Shows:
   - Audio visualization (waveform circles)
   - "Listening..." text
   - "Transfer to Me" button
   - "Stop Listening" button

3. Take screenshot:
```bash
xcrun simctl io 6ECF589D-26A3-49D7-8A2D-C642466146A2 screenshot ~/projects/CallAssist/Screenshots/6.7-inch-raw/05-listen-in.png
```

**Caption for App Store:** "Hear the conversation live and take control anytime"

---

### Screenshot 7: Call History
**Actions:**
1. Close the call status (tap "Close" or wait for completion)
2. Navigate to **"History"** tab at bottom
3. Should show completed appointments with:
   - Business names
   - Service descriptions
   - Status badges
   - Timestamps

4. Take screenshot:
```bash
xcrun simctl io 6ECF589D-26A3-49D7-8A2D-C642466146A2 screenshot ~/projects/CallAssist/Screenshots/6.7-inch-raw/06-call-history.png
```

**Caption for App Store:** "Complete history of all appointments with full transcripts"

---

### Screenshot 8: Purchase Minutes
**Actions:**
1. Tap the **minute balance widget** (top right corner)
2. Shows minute packages:
   - 25 Minutes - $14.99
   - 100 Minutes - $49.99
   - 250 Minutes - $99.99 (Best Value)
   - 500 Minutes - $174.99

3. Take screenshot:
```bash
xcrun simctl io 6ECF589D-26A3-49D7-8A2D-C642466146A2 screenshot ~/projects/CallAssist/Screenshots/6.7-inch-raw/07-purchase-minutes.png
```

**Caption for App Store:** "Pay only for what you use - minutes expire in 12 months"

---

## 🎨 Adding Captions (Optional but Recommended)

After taking all screenshots, you can add text captions using this script:

```bash
# I'll create this script for you next
./add-captions.sh
```

This will overlay the captions on each screenshot for a more professional App Store presentation.

---

## ✅ Screenshot Checklist

- [ ] 01: New Appointment Form (filled)
- [ ] 02: Calendar Selection
- [ ] 03: Ready to Call (Listen In enabled)
- [ ] 04: Call in Progress
- [ ] 05: Listen In Feature
- [ ] 06: Call History
- [ ] 07: Purchase Minutes
- [ ] 08: (Bonus) Call Results/Transcript

---

## 📐 Screenshot Specifications

**Current Device:** iPhone 17 Pro Max
- **Resolution:** 1320 x 2868 pixels ✓
- **Aspect Ratio:** Perfect for App Store submission
- **Format:** PNG ✓

Apple accepts screenshots from any iPhone with 6.1" or larger display, so these are perfect!

---

## 🚀 Quick Screenshot Command

To make this easier, here's a simple command to paste after each step:

```bash
# Set screenshot number (change 01, 02, 03, etc.)
NUM=01
xcrun simctl io 6ECF589D-26A3-49D7-8A2D-C642466146A2 screenshot ~/projects/CallAssist/Screenshots/6.7-inch-raw/${NUM}-screenshot.png && echo "✅ Screenshot ${NUM} saved!"
```

---

## 💡 Pro Tips

1. **Clean Data:** Use professional-looking example data (avoid "test" or "asdf")
2. **Status Bar:** Screenshots include the status bar - make sure time looks good (11:30 AM is standard)
3. **Orientation:** Keep phone in portrait mode
4. **No Personal Info:** Don't use real phone numbers or emails
5. **Consistent Theme:** Use the same example business across screenshots when possible

---

## 🎬 Ready to Start?

The simulator is running with your app loaded. Just follow the steps above and run the screenshot commands after each action!

**Current Status:**
- ✅ App built and running
- ✅ Simulator booted (iPhone 17 Pro Max)
- ✅ Screenshot directory created
- ✅ First screenshot captured

**Next:** Fill in the appointment form and capture Screenshot 01!
