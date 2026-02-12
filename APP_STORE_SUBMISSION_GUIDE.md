# App Store Submission Guide for CallAssist

**Purpose:** Complete step-by-step guide to submit CallAssist to the App Store

**Last Updated:** February 9, 2026

---

## 📋 PRE-SUBMISSION CHECKLIST

Before you start, make sure you have:

- [ ] Apple Developer account ($99/year) - https://developer.apple.com/programs/
- [ ] GitHub Pages enabled with legal documents live
- [ ] Xcode installed with latest iOS SDK
- [ ] Real iOS device for testing (Simulator is not sufficient)
- [ ] Test Apple ID for StoreKit testing
- [ ] Privacy Policy, Terms, and Support pages publicly accessible

---

## 🔴 STEP 1: Verify GitHub Pages Setup

Your legal documents **must** be live before submitting.

### Check if GitHub Pages is Enabled:

1. Go to: https://github.com/leoneaj33/callassist-website/settings/pages
2. Under **"Source"**, you should see:
   - Branch: **main**
   - Folder: **/docs**
   - Status: **"Your site is live at..."**

### If NOT Enabled:

1. Under "Source", select **"main"** branch
2. Under "Folder", select **/docs**
3. Click **"Save"**
4. Wait 1-2 minutes for deployment

### Verify URLs Work:

Open these in your browser (they should all load):
- https://leoneaj33.github.io/callassist-website/privacy.html
- https://leoneaj33.github.io/callassist-website/terms.html
- https://leoneaj33.github.io/callassist-website/support.html

**You'll need these URLs for the App Store listing!**

---

## 🔴 STEP 2: Create App Store Connect Listing

### 2.1 - Create New App

1. Go to: https://appstoreconnect.apple.com/
2. Click **"My Apps"**
3. Click **"+"** → **"New App"**

**Fill in the form:**

- **Platforms:** iOS
- **Name:** CallAssist
- **Primary Language:** English (U.S.)
- **Bundle ID:** Select `com.callassist.app` (should be in dropdown)
- **SKU:** callassist-ios-2026 (or any unique identifier)
- **User Access:** Full Access

Click **"Create"**

---

### 2.2 - App Information

Navigate to **App Information** tab:

**Category:**
- **Primary Category:** Productivity
- **Secondary Category:** Business (optional)

**Content Rights:**
- [ ] Check "Contains third-party content" (you use Vapi AI)

**Age Rating:**
- Click **"Edit"** next to Age Rating
- Answer the questionnaire (all "No" for CallAssist - it's a business productivity app)
- Should result in: **4+**

---

### 2.3 - Pricing and Availability

Navigate to **Pricing and Availability**:

**Price:**
- Select **"Free"** (the app is free, in-app purchases are separate)

**Availability:**
- **All Countries and Regions** (or select specific countries)
- **Available on the App Store:** Yes

**Pre-Order:** Leave off

---

### 2.4 - App Privacy

Navigate to **App Privacy**:

This is **REQUIRED** and takes ~10 minutes. Click **"Get Started"**

#### Privacy Policy URL:
```
https://leoneaj33.github.io/callassist-website/privacy.html
```

#### Data Collection:

**Contact Info:**
- [x] Name
- [x] Email Address
- [x] Phone Number
- **How is this data used?** App Functionality
- **Is this data linked to the user?** Yes
- **Do you track this data?** No

**User Content:**
- [x] Audio Data (for Listen In feature)
- **How is this data used?** App Functionality
- **Is this data linked to the user?** Yes
- **Do you track this data?** No

- [x] Other User Content (appointment details, transcripts)
- **How is this data used?** App Functionality
- **Is this data linked to the user?** Yes
- **Do you track this data?** No

**Usage Data:**
- [x] Product Interaction (call history, minute usage)
- **How is this data used?** App Functionality, Analytics
- **Is this data linked to the user?** Yes
- **Do you track this data?** No

**Identifiers:**
- [x] User ID (for StoreKit purchases)
- **How is this data used?** App Functionality
- **Is this data linked to the user?** Yes
- **Do you track this data?** No

**Important:** Select "No" for all tracking questions since you store data locally only.

Click **"Save"** → **"Publish"**

---

## 🔴 STEP 3: In-App Purchases Configuration

### 3.1 - Create Minute Packages

Navigate to **Features** → **In-App Purchases**

For each package, click **"+"** → **"Consumable"**

---

#### Package 1: 25 Minutes

**Reference Name:** 25 Minutes Package
**Product ID:** `com.callassist.minutes.25`

**Pricing:**
- Tier 15 ($14.99 USD)

**Localizations (English U.S.):**
- **Display Name:** 25 Minutes
- **Description:**
```
25 minutes for AI-powered appointment calls. Minutes expire in 12 months. New users get 5 free trial minutes!
```

**Review Information:**
- Screenshot: (will upload later - leave blank for now)

**Save**

---

#### Package 2: 100 Minutes

**Reference Name:** 100 Minutes Package
**Product ID:** `com.callassist.minutes.100`

**Pricing:**
- Tier 50 ($49.99 USD)

**Localizations (English U.S.):**
- **Display Name:** 100 Minutes
- **Description:**
```
100 minutes for AI-powered appointment calls ($0.50/min). Minutes expire in 12 months. Best for regular users!
```

**Save**

---

#### Package 3: 250 Minutes (Best Value)

**Reference Name:** 250 Minutes Package
**Product ID:** `com.callassist.minutes.250`

**Pricing:**
- Tier 100 ($99.99 USD)

**Localizations (English U.S.):**
- **Display Name:** 250 Minutes - Best Value
- **Description:**
```
250 minutes for AI-powered appointment calls ($0.40/min). Minutes expire in 12 months. Best value - save 33%!
```

**Save**

---

#### Package 4: 500 Minutes

**Reference Name:** 500 Minutes Package
**Product ID:** `com.callassist.minutes.500`

**Pricing:**
- Custom price: $174.99 USD (use "Add Custom Price" if needed)

**Localizations (English U.S.):**
- **Display Name:** 500 Minutes
- **Description:**
```
500 minutes for AI-powered appointment calls ($0.35/min). Minutes expire in 12 months. For heavy users!
```

**Save**

---

### 3.2 - Submit In-App Purchases for Review

After creating all 4 packages:

1. Navigate to each product
2. Click **"Submit for Review"**
3. Repeat for all 4 packages

**Note:** IAPs review happens with your app submission. They'll be reviewed together.

---

## 🔴 STEP 4: Prepare App Icon

You need a **1024x1024px** app icon with no transparency.

### Design Recommendations:

**Concept Ideas:**
1. **Phone + AI Symbol** - Phone icon with circuit/brain design
2. **Phone + Calendar** - Combination showing appointment booking
3. **Speech Bubble + Phone** - Representing AI conversation
4. **Simple "CA" Monogram** - Professional and clean

**Design Tools:**

**Free Options:**
- **Canva** (easiest): https://www.canva.com/
  - Search "app icon" templates
  - Customize colors/text
  - Export as PNG 1024x1024px

- **Figma** (more control): https://www.figma.com/
  - Create 1024x1024px frame
  - Design icon
  - Export as PNG

**Paid Options:**
- **Fiverr** ($5-50): Search "app icon design"
- **99designs** ($199+): Professional design contest

### Icon Requirements:

- **Size:** 1024x1024 pixels
- **Format:** PNG (no alpha/transparency)
- **Color Space:** RGB
- **No text** (or minimal - Apple discourages text in icons)
- **Simple design** that works at small sizes
- **No Apple hardware** depicted
- **Rounded corners** are added automatically by iOS

### Quick Icon with Canva:

1. Go to: https://www.canva.com/
2. Search: "app icon"
3. Choose a template with phone/business theme
4. Customize:
   - **Colors:** Blue (#007AFF) and white (iOS standard)
   - **Icon:** Phone or microphone symbol
   - **Text:** "CA" or nothing
5. Download as PNG, 1024x1024px

### Add Icon to Xcode:

1. Open **CallAssist.xcodeproj**
2. Click **Assets.xcassets** in project navigator
3. Click **AppIcon**
4. Drag your 1024x1024 PNG to the **"App Store iOS 1024pt"** slot
5. Xcode will generate all other sizes automatically

---

## 🔴 STEP 5: Take App Store Screenshots

Apple requires screenshots for different iPhone sizes.

### Required Screenshot Sizes:

You need screenshots for **two** device sizes (minimum):

1. **6.7" Display** (iPhone 14 Pro Max, 15 Pro Max, 15 Plus)
   - Resolution: 1290 x 2796 pixels

2. **5.5" Display** (iPhone 8 Plus, older devices)
   - Resolution: 1242 x 2208 pixels

### Recommended: 5-8 Screenshots Per Device

**Screenshot Ideas:**

1. **Home Screen** - Clean overview showing "New Appointment" button and minute balance
2. **New Appointment Form** - Show the business details and service description fields
3. **Calendar Selection** - Show available time slots being selected
4. **Call in Progress** - Show the animated call status screen
5. **Listen In Feature** - Show the audio visualization and "Transfer to Me" button
6. **Call History** - Show completed appointments with swipe actions
7. **Purchase Minutes** - Show the minute packages screen
8. **Results/Transcript** - Show a successful appointment with transcript

### How to Take Screenshots:

#### Option A: Use Simulator (Quick & Easy)

1. Open **Xcode**
2. Select **Simulator:** iPhone 15 Pro Max (6.7")
3. Run your app (⌘R)
4. Navigate to each screen
5. Press **⌘S** to save screenshot
6. Screenshots save to Desktop

Repeat with iPhone 8 Plus simulator for 5.5" size.

#### Option B: Use Real Device + Mac

1. Connect iPhone via USB
2. Open **QuickTime Player** on Mac
3. **File** → **New Movie Recording**
4. Click dropdown next to record → Select your iPhone
5. Navigate through app on phone
6. Take screenshots: **⌘⌃⌘S** (or use iPhone's screenshot button)

### Screenshot Best Practices:

- **Clean data:** Use realistic but clean example data
- **Good timing:** Show features at their best (e.g., call "In Progress" not "Failed")
- **Text overlays:** Consider adding text captions (optional but helpful)
- **Consistent theme:** Use the same example business across screenshots
- **No personal info:** Don't use real phone numbers or emails

### Add Screenshots to App Store Connect:

1. Go to **App Store** → **iOS App** → **Screenshots and Preview**
2. Upload screenshots for each device size
3. Drag to reorder (first screenshot is featured)
4. **Save**

---

## 🔴 STEP 6: Write App Store Metadata

### App Name (30 chars max):
```
CallAssist
```

### Subtitle (30 chars max):
```
AI Books Your Appointments
```

### Promotional Text (170 chars - can update anytime):
```
Never waste time on hold again! CallAssist's AI calls businesses for you and books appointments while you stay in control.
```

### Description (4000 chars max):

```
CallAssist makes scheduling appointments effortless. Our AI-powered assistant calls businesses on your behalf, finds available times that fit your calendar, and books appointments—all while you listen in real-time.

SMART FEATURES

• AI-Powered Calls: Our AI converses naturally with businesses to schedule, reschedule, or cancel appointments
• Calendar Integration: Syncs with Google, Microsoft, and Apple Calendar to find your availability
• Listen In Real-Time: Hear the conversation live and join the call if needed
• Voice Input: Describe appointments by speaking—we handle the rest
• Full Transcripts: Get complete records of every call
• Pay Per Minute: Only pay for actual call time, no subscriptions

HOW IT WORKS

1. Enter the business name, phone number, and what you need
2. Select your available times from your synced calendar
3. Our AI calls the business and books your appointment
4. Receive a confirmation with full transcript

PERFECT FOR

• Medical appointments (dentist, doctor, specialist)
• Home services (plumber, electrician, repairs)
• Personal care (haircut, massage, spa)
• Auto services (mechanic, inspection, detailing)
• Any business that books by phone

PRICING

Buy minute packages that work for you:
• 25 Minutes: $14.99 ($0.60/min)
• 100 Minutes: $49.99 ($0.50/min)
• 250 Minutes: $99.99 ($0.40/min) - Best Value
• 500 Minutes: $174.99 ($0.35/min)

New users get 5 free trial minutes! Minutes expire in 12 months.

YOUR PRIVACY MATTERS

• All data stored locally on your device
• No cloud storage of personal information
• Calendar access is read-only
• Full transparency with every call

SUPPORT

Questions? Email us at support@callassist.app
We respond within 48 hours.

REQUIREMENTS

• iOS 17.0 or later
• Internet connection for calls
• Microphone permission for voice input (optional)
• Calendar access for availability sync (optional)

---

Download CallAssist today and take back your time!
```

### Keywords (100 chars max, comma-separated):

```
appointment,booking,AI,assistant,schedule,calendar,phone,calls,automation,productivity
```

**Note:** Choose keywords carefully - they can't be changed after approval without a new version.

### Support URL:
```
https://leoneaj33.github.io/callassist-website/support.html
```

### Marketing URL (optional):
```
https://leoneaj33.github.io/callassist-website/
```

### Copyright:
```
© 2026 CallAssist. All rights reserved.
```

---

## 🔴 STEP 7: Build and Upload to App Store Connect

### 7.1 - Configure Build Settings in Xcode

1. Open **CallAssist.xcodeproj** in Xcode
2. Select the **CallAssist** project (top of navigator)
3. Select **CallAssist** target
4. Go to **General** tab

**Identity:**
- **Display Name:** CallAssist
- **Bundle Identifier:** com.callassist.app
- **Version:** 1.0.0
- **Build:** 1

**Deployment Info:**
- **Minimum Deployments:** iOS 17.0
- **iPhone Orientation:** Portrait only (recommended)
- **iPad:** Uncheck if iPhone only

**Signing & Capabilities:**
- **Team:** Select your Apple Developer team
- **Signing Certificate:** Automatically manage signing (recommended)

---

### 7.2 - Archive Your App

1. In Xcode, select **Any iOS Device (arm64)** as the build destination (NOT Simulator)
2. **Product** → **Clean Build Folder** (⌘⇧K)
3. **Product** → **Archive** (⌘B then Archive)
4. Wait for archive to complete (~2-5 minutes)

The **Organizer** window will appear showing your archive.

---

### 7.3 - Validate Archive (Important!)

Before uploading, validate to catch errors:

1. In **Organizer**, select your archive
2. Click **"Validate App"**
3. **Distribution Method:** App Store Connect
4. **Options:**
   - Upload symbols: ✓ (recommended)
   - Manage Version and Build: Automatically manage
5. Click **"Validate"**

Wait for validation (~2-5 minutes). Fix any errors before proceeding.

---

### 7.4 - Upload to App Store Connect

1. Click **"Distribute App"**
2. **Distribution Method:** App Store Connect
3. **Options:** (same as validation)
   - Upload symbols: ✓
   - Automatically manage
4. Click **"Upload"**

Wait for upload (~5-10 minutes depending on connection).

You'll get an email when the build is processed (usually within 30 minutes).

---

### 7.5 - Select Build in App Store Connect

1. Go back to: https://appstoreconnect.apple.com/
2. **My Apps** → **CallAssist**
3. Click **"+"** next to **iOS App** → **"1.0.0 Prepare for Submission"**
4. Scroll to **"Build"** section
5. Click **"+"** next to Build
6. Select your uploaded build (Version 1.0.0, Build 1)
7. **Save**

---

## 🔴 STEP 8: Final Review Information

Navigate to **App Review Information**:

**Contact Information:**
- **First Name:** [Your first name]
- **Last Name:** [Your last name]
- **Phone Number:** [Your phone number]
- **Email:** support@callassist.app (or your business email)

**Sign-In Information:**
- **Sign-in required:** No
- **Notes:**
```
CallAssist does not require account creation. Users can start using the app immediately.

To test in-app purchases, please use the sandbox test account:
Email: [create a sandbox tester in App Store Connect]

For full functionality testing:
1. Grant microphone permission for voice input
2. Grant calendar permission for availability sync
3. Purchase test minutes using sandbox account
4. Place a test call to any business phone number

The app uses Vapi AI for phone calls. All features work in production environment.
```

**Demo Account:** Not required (app works without login)

**Notes:**
```
IMPORTANT: To fully test the app, you'll need:

1. An active internet connection
2. Microphone and calendar permissions (app will request these)
3. A sandbox test account for in-app purchase testing

The app makes real phone calls via Vapi AI API. During review, calls will connect to real businesses, so please use non-emergency business phone numbers for testing.

Features to test:
- Voice input for appointment description
- Calendar integration (Google/Microsoft/Apple)
- Minute package purchases (sandbox environment)
- Live call placement and monitoring
- Call transcripts and history

Contact support@callassist.app for any questions during review.
```

---

## 🔴 STEP 9: Export Compliance

Navigate to **App Store** → **Export Compliance Information**:

**Does your app use encryption?**
- Select **"No"** (CallAssist uses standard HTTPS which is exempt)

---

## 🔴 STEP 10: Submit for Review

### Final Checklist:

- [ ] App icon uploaded (1024x1024px in Xcode)
- [ ] Screenshots uploaded (6.7" and 5.5" displays)
- [ ] App description written
- [ ] Keywords selected
- [ ] Support URL working (https://leoneaj33.github.io/callassist-website/support.html)
- [ ] Privacy Policy URL working
- [ ] All 4 in-app purchases created and submitted
- [ ] Build uploaded and selected
- [ ] Age rating completed (should be 4+)
- [ ] Pricing set (Free)
- [ ] App Privacy questionnaire completed
- [ ] Review notes written
- [ ] Export compliance completed

### Submit!

1. Review everything one final time
2. Click **"Add for Review"** (top right)
3. Click **"Submit to App Review"**

---

## ⏰ WHAT HAPPENS NEXT?

### Review Timeline:

- **Waiting for Review:** 1-3 days typically
- **In Review:** 1-2 days typically
- **Total:** Usually 2-5 days from submission to decision

### Possible Outcomes:

**✅ Approved (Best Case)**
- You'll get an email: "Your app status is Ready for Sale"
- App goes live on the App Store automatically (or on your scheduled date)
- Celebrate! 🎉

**⚠️ Metadata Rejected**
- Minor issues with screenshots, description, or keywords
- Easy to fix - update and resubmit
- Usually approved within 24 hours

**❌ Binary Rejected**
- Issues with the app code itself
- Common reasons:
  - Crash on launch
  - Feature doesn't work as described
  - Privacy permissions not explained
  - In-app purchase issues
- Fix the issue, rebuild, upload new build, resubmit

### How to Check Status:

1. Go to: https://appstoreconnect.apple.com/
2. **My Apps** → **CallAssist**
3. Status shown at top:
   - **Waiting for Review** - In queue
   - **In Review** - Apple is testing now!
   - **Ready for Sale** - LIVE! 🎉
   - **Rejected** - Needs fixes
   - **Metadata Rejected** - Minor fixes needed

---

## 🐛 COMMON REJECTION REASONS & FIXES

### Issue: "App crashes on launch"
**Fix:** Test on real device (not Simulator) before submitting

### Issue: "IAP doesn't work"
**Fix:** Make sure you submitted all 4 IAP products for review

### Issue: "Privacy permissions not explained"
**Fix:** Check Info.plist has clear descriptions for microphone, calendar, speech recognition

### Issue: "Misleading description"
**Fix:** Make sure description accurately reflects app features

### Issue: "Missing functionality"
**Fix:** Ensure all features mentioned in description actually work

### Issue: "3rd party login required"
**Fix:** CallAssist doesn't require login - mention this in review notes

---

## 💰 POST-APPROVAL CHECKLIST

Once approved:

- [ ] Test download from App Store on real device
- [ ] Test in-app purchases in production (buy smallest package)
- [ ] Verify all features work in production environment
- [ ] Share link with friends/family for beta testing
- [ ] Monitor App Store Connect for crashes/analytics
- [ ] Respond to user reviews
- [ ] Plan v1.1 updates based on feedback

---

## 📧 SUPPORT DURING REVIEW

If Apple has questions during review, they'll email you. Respond quickly:

- Check **support@callassist.app** (or your registered email) daily
- Response time impacts review speed
- Be helpful and professional
- Provide any requested info promptly

---

## 🎯 APP STORE OPTIMIZATION (ASO) TIPS

**After Launch:**

1. **Encourage Reviews**
   - Ask happy users to leave reviews
   - Use SKStoreReviewController in app (after successful appointment)

2. **Update Screenshots**
   - Test different screenshots to see what converts better
   - Update seasonally or for major features

3. **A/B Test Metadata**
   - Test different descriptions
   - Try different keywords
   - Monitor conversion rate in App Store Connect

4. **Monitor Keywords**
   - Check keyword rankings in App Store Connect
   - Adjust in future versions

---

**🚀 Good luck with your submission!**

Questions during the process? Contact support or check Apple's App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/

---

**Last Updated:** February 9, 2026
