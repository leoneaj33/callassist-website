# OAuth Setup Guide for CallAssist

**Purpose:** Complete guide to setting up Google Calendar and Microsoft Calendar OAuth integration

**Last Updated:** February 9, 2026

---

## 📋 OVERVIEW

CallAssist needs OAuth 2.0 credentials to access user calendars. This guide walks through:
1. **Google Calendar** setup (Google Cloud Console)
2. **Microsoft Calendar** setup (Azure AD Portal)
3. Installing required SDKs
4. Configuring your app

**Time Required:** ~30-45 minutes total

---

## 🔴 OPTION 1: Start with Apple Calendar Only (Recommended for MVP)

**Why this is easier:**
- No OAuth setup required
- No third-party SDKs needed
- Works on Simulator
- Perfect for testing and initial launch

**Your app already supports Apple Calendar!** It's built-in and requires zero setup.

### To Use Apple Calendar Only:

Just launch the app and select "Apple Calendar" during onboarding. That's it!

You can add Google/Microsoft later in a future update (v1.1).

**Recommendation:** Launch with Apple Calendar only. Add Google/Microsoft in v1.1 after you have users.

---

## 🟢 OPTION 2: Add Google Calendar OAuth (Optional)

### Prerequisites:
- Google account
- ~20 minutes
- $0 cost

---

### Step 1: Create Google Cloud Project

1. Go to: https://console.cloud.google.com/
2. Click **"Select a project"** → **"New Project"**
3. **Project Name:** "CallAssist"
4. **Organization:** Leave blank (or select if you have one)
5. Click **"Create"**
6. Wait 30 seconds for project creation

---

### Step 2: Enable Google Calendar API

1. In the Cloud Console, make sure your **"CallAssist"** project is selected
2. Go to: https://console.cloud.google.com/apis/library
3. Search for: **"Google Calendar API"**
4. Click **"Google Calendar API"**
5. Click **"Enable"**
6. Wait for API to enable (~30 seconds)

---

### Step 3: Configure OAuth Consent Screen

1. Go to: https://console.cloud.google.com/apis/credentials/consent
2. **User Type:** Select **"External"**
3. Click **"Create"**

**Page 1: App Information**
- **App name:** CallAssist
- **User support email:** (your email)
- **App logo:** (skip for now, add later)
- **Application home page:** https://leoneaj33.github.io/callassist-website/ (once GitHub Pages is live)
- **Application privacy policy link:** https://leoneaj33.github.io/callassist-website/privacy.html
- **Application terms of service link:** https://leoneaj33.github.io/callassist-website/terms.html
- **Authorized domains:** github.io
- **Developer contact information:** (your email)
- Click **"Save and Continue"**

**Page 2: Scopes**
- Click **"Add or Remove Scopes"**
- Search for: `calendar`
- Check: **"Google Calendar API"** → `.../auth/calendar` (full access)
- Click **"Update"**
- Click **"Save and Continue"**

**Page 3: Test Users**
- Click **"Add Users"**
- Add your Gmail address (for testing)
- Click **"Save and Continue"**

**Page 4: Summary**
- Review and click **"Back to Dashboard"**

---

### Step 4: Create OAuth Client ID

1. Go to: https://console.cloud.google.com/apis/credentials
2. Click **"+ Create Credentials"** → **"OAuth client ID"**
3. **Application type:** iOS
4. **Name:** "CallAssist iOS"
5. **Bundle ID:** `com.callassist.app` (must match your Xcode project)

**iOS URL scheme:**
You need your **reversed client ID**. Google will show it after you create the credential.

Example format: `com.googleusercontent.apps.123456789-abc123def456`

6. Click **"Create"**

---

### Step 5: Copy Your Client ID

After creating, you'll see a dialog with your credentials:

```
Client ID: 123456789-abc123def456.apps.googleusercontent.com
iOS URL scheme: com.googleusercontent.apps.123456789-abc123def456
```

**COPY THE CLIENT ID** - you'll add it to Secrets.plist in Step 7.

**COPY THE iOS URL SCHEME** - you'll add it to Info.plist in Step 8.

---

### Step 6: Install Google Sign-In SDK

Open Terminal and navigate to your project:

```bash
cd /Users/andrewleone/projects/CallAssist
```

Add GoogleSignIn to your Swift Package:

1. Open **CallAssist.xcodeproj** in Xcode
2. Go to **File** → **Add Package Dependencies**
3. Enter URL: `https://github.com/google/GoogleSignIn-iOS`
4. **Dependency Rule:** "Up to Next Major Version" → 7.0.0
5. Click **"Add Package"**
6. Select **"GoogleSignIn"** and **"GoogleSignInSwift"**
7. Click **"Add Package"**

---

### Step 7: Add Google Client ID to Secrets.plist

Open `CallAssist/Secrets.plist` and update:

```xml
<key>GOOGLE_CLIENT_ID</key>
<string>123456789-abc123def456.apps.googleusercontent.com</string>
```

Replace with YOUR actual client ID from Step 5.

---

### Step 8: Configure Info.plist

You need to add the reversed client ID as a URL scheme.

1. Open **CallAssist/Info.plist** in Xcode
2. Right-click in the file → **"Add Row"**
3. Select **"URL types"** (or "CFBundleURLTypes")
4. Expand the array → Click **"+"** to add Item 0
5. Expand Item 0 → Click **"+"** to add **"URL Schemes"**
6. Expand URL Schemes → Click **"+"** to add Item 0
7. Set Item 0 value to: `com.googleusercontent.apps.123456789-abc123def456`

Replace with YOUR iOS URL scheme from Step 5.

**Visual Guide:**
```
URL types (Array)
  └── Item 0 (Dictionary)
       └── URL Schemes (Array)
            └── Item 0 (String): com.googleusercontent.apps.YOUR-CLIENT-ID
```

---

### Step 9: Update GoogleCalendarService.swift

Open `CallAssist/Services/GoogleCalendarService.swift` and add this import at the top:

```swift
import GoogleSignIn
```

Replace the `requestAccess()` function with:

```swift
func requestAccess() async throws -> Bool {
    let config = AppConfig.shared
    guard !config.googleClientId.isEmpty else {
        throw GoogleCalendarError.notConfigured
    }

    // Configure Google Sign-In
    let configuration = GIDConfiguration(clientID: config.googleClientId)
    GIDSignIn.sharedInstance.configuration = configuration

    // Get the root view controller
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        throw GoogleCalendarError.apiFailed
    }

    // Request sign-in with calendar scope
    let result = try await GIDSignIn.sharedInstance.signIn(
        withPresenting: rootViewController,
        hint: nil,
        additionalScopes: ["https://www.googleapis.com/auth/calendar"]
    )

    // Store the access token
    self.accessToken = result.user.accessToken.tokenString
    return true
}
```

---

### Step 10: Test Google Calendar Integration

1. Build and run on a **real iOS device** (OAuth doesn't work on Simulator)
2. Go through app onboarding
3. Select **"Google Calendar"**
4. Google sign-in screen should appear
5. Sign in with your Google account
6. Grant calendar permission
7. App should connect successfully

**If it fails:**
- Check that your Gmail is added as a test user (Step 3)
- Verify Client ID matches in Secrets.plist
- Verify URL scheme is correct in Info.plist
- Check Xcode console for error messages

---

## 🟡 OPTION 3: Add Microsoft Calendar OAuth (Optional)

### Prerequisites:
- Microsoft account (personal or work)
- ~20 minutes
- $0 cost

---

### Step 1: Register App in Azure AD

1. Go to: https://portal.azure.com/
2. Sign in with Microsoft account
3. Search for: **"Azure Active Directory"** (or "Microsoft Entra ID")
4. Click on **"App registrations"** in left sidebar
5. Click **"+ New registration"**

**Register an application:**
- **Name:** CallAssist
- **Supported account types:** "Accounts in any organizational directory and personal Microsoft accounts"
- **Redirect URI:** Leave blank for now (we'll add it later)
- Click **"Register"**

---

### Step 2: Copy Application (client) ID

After registration, you'll see the **Overview** page.

**COPY THIS:**
- **Application (client) ID:** `12345678-1234-1234-1234-123456789abc`

Save this - you'll add it to Secrets.plist later.

---

### Step 3: Add Redirect URI for iOS

Still on the app registration page:

1. Click **"Authentication"** in left sidebar
2. Click **"+ Add a platform"**
3. Select **"iOS / macOS"**
4. **Bundle ID:** `com.callassist.app`
5. Click **"Configure"**
6. Azure will generate redirect URI for you

---

### Step 4: Configure API Permissions

1. Click **"API permissions"** in left sidebar
2. Click **"+ Add a permission"**
3. Select **"Microsoft Graph"**
4. Select **"Delegated permissions"**
5. Search for: `Calendars`
6. Check:
   - **Calendars.Read**
   - **Calendars.ReadWrite**
7. Click **"Add permissions"**

**Grant Admin Consent (Optional but Recommended):**
- Click **"Grant admin consent for [Your Organization]"**
- Click **"Yes"** to confirm
- This prevents users from seeing a scary consent screen

---

### Step 5: Install Microsoft Authentication Library (MSAL)

Open Terminal and navigate to your project:

```bash
cd /Users/andrewleone/projects/CallAssist
```

Add MSAL to your Swift Package:

1. Open **CallAssist.xcodeproj** in Xcode
2. Go to **File** → **Add Package Dependencies**
3. Enter URL: `https://github.com/AzureAD/microsoft-authentication-library-for-objc`
4. **Dependency Rule:** "Up to Next Major Version" → 1.0.0
5. Click **"Add Package"**
6. Select **"MSAL"**
7. Click **"Add Package"**

---

### Step 6: Add Microsoft Client ID to Secrets.plist

Open `CallAssist/Secrets.plist` and update:

```xml
<key>MICROSOFT_CLIENT_ID</key>
<string>12345678-1234-1234-1234-123456789abc</string>
```

Replace with YOUR Application (client) ID from Step 2.

---

### Step 7: Configure Info.plist for Microsoft

Add the MSAL redirect URL scheme:

1. Open **CallAssist/Info.plist** in Xcode
2. If you already added URL types for Google, add another item to the array
3. Otherwise, add **"URL types"** (CFBundleURLTypes)
4. Add a new URL Scheme:

**Value:** `msauth.com.callassist.app`

**Visual Guide:**
```
URL types (Array)
  └── Item 0 (Dictionary) [Google - if you added it]
       └── URL Schemes (Array)
            └── Item 0: com.googleusercontent.apps.YOUR-GOOGLE-ID
  └── Item 1 (Dictionary) [Microsoft]
       └── URL Schemes (Array)
            └── Item 0 (String): msauth.com.callassist.app
```

**Also add LSApplicationQueriesSchemes:**

1. Right-click in Info.plist → **"Add Row"**
2. Key: **"LSApplicationQueriesSchemes"** (Queried URL Schemes)
3. Type: Array
4. Add these items:
   - `msauthv2`
   - `msauthv3`

```
LSApplicationQueriesSchemes (Array)
  └── Item 0 (String): msauthv2
  └── Item 1 (String): msauthv3
```

---

### Step 8: Update MicrosoftCalendarService.swift

Open `CallAssist/Services/MicrosoftCalendarService.swift` and add this import at the top:

```swift
import MSAL
```

Replace the `requestAccess()` function with:

```swift
func requestAccess() async throws -> Bool {
    let config = AppConfig.shared
    guard !config.microsoftClientId.isEmpty else {
        throw MicrosoftCalendarError.notConfigured
    }

    // Configure MSAL
    let authority = try MSALAuthority(url: URL(string: "https://login.microsoftonline.com/common")!)
    let msalConfig = MSALPublicClientApplicationConfig(clientId: config.microsoftClientId, redirectUri: "msauth.com.callassist.app://auth", authority: authority)
    let application = try MSALPublicClientApplication(configuration: msalConfig)

    // Get the root view controller
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        throw MicrosoftCalendarError.apiFailed
    }

    // Request token interactively
    let parameters = MSALInteractiveTokenParameters(scopes: ["Calendars.ReadWrite"], webviewParameters: MSALWebviewParameters(authPresentationViewController: rootViewController))

    return try await withCheckedThrowingContinuation { continuation in
        application.acquireToken(with: parameters) { result, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }

            guard let result = result else {
                continuation.resume(throwing: MicrosoftCalendarError.apiFailed)
                return
            }

            self.accessToken = result.accessToken
            continuation.resume(returning: true)
        }
    }
}
```

---

### Step 9: Test Microsoft Calendar Integration

1. Build and run on a **real iOS device** (OAuth doesn't work on Simulator)
2. Go through app onboarding
3. Select **"Microsoft Calendar"**
4. Microsoft sign-in screen should appear
5. Sign in with your Microsoft account
6. Grant calendar permission
7. App should connect successfully

---

## ⚠️ COMMON ISSUES & TROUBLESHOOTING

### Issue: "Google sign-in requires a real device"
**Solution:** OAuth doesn't work on iOS Simulator. Test on a real iPhone/iPad.

### Issue: "The app bundle identifier does not match the one in the OAuth client"
**Solution:** Verify your Bundle ID in Xcode matches exactly:
1. Open CallAssist.xcodeproj
2. Select project → Target: CallAssist → General
3. **Bundle Identifier** should be: `com.callassist.app`

### Issue: "Redirect URI mismatch"
**Solution:** Check that URL schemes in Info.plist match your OAuth configuration:
- Google: `com.googleusercontent.apps.YOUR-CLIENT-ID`
- Microsoft: `msauth.com.callassist.app`

### Issue: Google says "Access blocked: CallAssist has not completed verification"
**Solution:** Your app is in "Testing" mode. Add your Gmail as a test user:
1. Go to: https://console.cloud.google.com/apis/credentials/consent
2. Under "Test users" → Click "Add Users"
3. Add your Gmail address

### Issue: Microsoft login shows "AADSTS700016: Application not found in directory"
**Solution:** Your Azure app registration might be in the wrong tenant. Make sure you selected "Personal Microsoft accounts" when registering.

### Issue: Calendar permissions not being requested
**Solution:** Check that you're requesting the right scopes:
- Google: `https://www.googleapis.com/auth/calendar`
- Microsoft: `Calendars.ReadWrite`

---

## 📝 FINAL CHECKLIST

### Google Calendar Setup:
- [ ] Created Google Cloud project
- [ ] Enabled Google Calendar API
- [ ] Configured OAuth consent screen
- [ ] Created iOS OAuth client ID
- [ ] Copied Client ID to Secrets.plist
- [ ] Added URL scheme to Info.plist
- [ ] Installed GoogleSignIn SDK
- [ ] Updated GoogleCalendarService.swift
- [ ] Tested on real device

### Microsoft Calendar Setup:
- [ ] Registered app in Azure AD
- [ ] Copied Application ID to Secrets.plist
- [ ] Added redirect URI for iOS
- [ ] Configured Microsoft Graph API permissions
- [ ] Added URL schemes to Info.plist (msauth, msauthv2, msauthv3)
- [ ] Installed MSAL SDK
- [ ] Updated MicrosoftCalendarService.swift
- [ ] Tested on real device

---

## 🚀 WHAT'S NEXT?

Once OAuth is set up:

1. **Test on real device** (Simulator won't work for OAuth)
2. **Verify calendar sync works** (check free slots are detected)
3. **Test appointment booking** (ensure times are added to calendar)
4. **Update App Store screenshots** showing calendar integration

---

## 💡 PRO TIPS

1. **Start with Apple Calendar** for your initial launch. Add Google/Microsoft in v1.1.
2. **OAuth Testing** must be done on a real iOS device - Simulator always fails.
3. **Privacy Review** - Google/Apple may review your OAuth usage before launch. Have clear explanations ready.
4. **Expiring Tokens** - Production apps should refresh tokens. Current implementation stores access tokens temporarily (lost when app restarts).
5. **Multiple Accounts** - Users can only connect one calendar provider at a time currently. Consider adding multi-account support in v2.

---

## 📚 OFFICIAL DOCUMENTATION

**Google Sign-In for iOS:**
- Setup Guide: https://developers.google.com/identity/sign-in/ios/start-integrating
- API Reference: https://developers.google.com/identity/sign-in/ios/reference

**Microsoft MSAL for iOS:**
- Setup Guide: https://learn.microsoft.com/en-us/azure/active-directory/develop/tutorial-v2-ios
- API Reference: https://azuread.github.io/microsoft-authentication-library-for-objc/

**Google Calendar API:**
- Documentation: https://developers.google.com/calendar/api/guides/overview
- Scopes: https://developers.google.com/calendar/api/auth

**Microsoft Graph Calendar API:**
- Documentation: https://learn.microsoft.com/en-us/graph/api/resources/calendar
- Permissions: https://learn.microsoft.com/en-us/graph/permissions-reference#calendars-permissions

---

**Last Updated:** February 9, 2026

**Questions?** Check the troubleshooting section or search Stack Overflow for specific error messages.
