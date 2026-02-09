# LLC Update Checklist for CallAssist

**Purpose:** Use this document when you form your LLC to update all references from personal name to business entity.

**Last Updated:** February 9, 2026

---

## 📋 QUICK REFERENCE

**Current Setup:**
- Legal Entity: Individual (Andrew Leone)
- Support Email: TBD
- Privacy Policy: TBD
- Terms of Service: TBD

**After LLC Formation:**
- Legal Entity: `[YOUR LLC NAME]` LLC
- Support Email: `support@[yourdomain].com`
- Privacy Policy URL: `https://[yourdomain].com/privacy.html`
- Terms URL: `https://[yourdomain].com/terms.html`

---

## 🔴 CRITICAL: App Store Connect Changes

### 1. Legal Entity Update
**When:** Before first app submission OR within 30 days of LLC formation

**Steps:**
1. Log into App Store Connect: https://appstoreconnect.apple.com
2. Go to **Agreements, Tax, and Banking**
3. Update **Legal Entity Information**
   - Change from: "Andrew Leone (Individual)"
   - Change to: "[Your LLC Name] LLC"
4. Update **Tax Information**
   - Change from: Personal SSN
   - Change to: Business EIN
5. Update **Banking Information**
   - Change to: Business bank account

**Documents Needed:**
- [ ] LLC Articles of Organization
- [ ] EIN Letter from IRS
- [ ] Business bank account with routing/account numbers
- [ ] W-9 form with EIN

---

## 📄 LEGAL DOCUMENTS TO UPDATE

### 2. Privacy Policy
**Location:** `docs/privacy.html` (or your hosting)

**Current References to Change:**

```html
<!-- FIND THIS: -->
<p>Contact: Andrew Leone</p>
<p>Email: your-personal-email@gmail.com</p>

<!-- REPLACE WITH: -->
<p>Contact: [Your LLC Name] LLC</p>
<p>Email: support@[yourdomain].com</p>
<p>Registered Address: [FL Business Address]</p>
```

**Full Updates Needed:**
- [ ] Company name in header/title
- [ ] Legal entity name throughout document
- [ ] Contact information (email, address)
- [ ] Last updated date
- [ ] Data controller identification

**URL to Update:**
- Old: (will be set when created)
- New: Add LLC name to URL or domain

---

### 3. Terms of Service
**Location:** `docs/terms.html`

**Current References to Change:**

```html
<!-- FIND THIS: -->
<h1>Terms of Service for CallAssist</h1>
<p>Contact: your-personal-email@gmail.com</p>

<!-- REPLACE WITH: -->
<h1>Terms of Service for CallAssist</h1>
<p>Operated by: [Your LLC Name] LLC</p>
<p>Contact: support@[yourdomain].com</p>
<p>Address: [FL Business Address]</p>
```

**Full Updates Needed:**
- [ ] Legal entity name
- [ ] Business address (can use registered agent)
- [ ] Contact email
- [ ] Last updated date
- [ ] Jurisdiction (should be Florida)

---

### 4. Support Page
**Location:** `docs/support.html`

**Updates Needed:**

```html
<!-- FIND THIS: -->
<p>Email: support@callassist.app</p>

<!-- REPLACE WITH: -->
<p>Company: [Your LLC Name] LLC</p>
<p>Email: support@[yourdomain].com</p>
<p>Business Hours: [Your hours]</p>
<p>Address: [FL Business Address]</p>
```

---

## 💼 BUSINESS INFRASTRUCTURE SETUP

### 5. Email Accounts to Create

**After LLC Formation:**

1. **Support Email** (Required)
   - Address: `support@[yourdomain].com`
   - Purpose: User support, App Store contact
   - Provider: Google Workspace ($6/mo) or Zoho (free)
   - **Update in:** App Store Connect, Privacy Policy, Terms, Support Page

2. **Legal/Compliance Email** (Recommended)
   - Address: `legal@[yourdomain].com`
   - Purpose: DMCA, privacy requests, legal notices
   - **Update in:** Privacy Policy

3. **Admin Email** (Optional)
   - Address: `admin@[yourdomain].com`
   - Purpose: Internal, billing, vendor accounts

**Action Items:**
- [ ] Register domain: `[yourllcname].com`
- [ ] Set up email hosting (Google Workspace recommended)
- [ ] Create email accounts
- [ ] Set up forwarding to personal email
- [ ] Add email signature with LLC name

---

## 🏢 APP STORE CONNECT METADATA

### 6. App Information Updates

**Location:** App Store Connect > Your App > App Information

**Update These Fields:**

1. **Seller Name**
   - Current: "Andrew Leone"
   - New: "[Your LLC Name] LLC"
   - ⚠️ This shows in the App Store under the app

2. **Support URL**
   - New: `https://[yourdomain].com/support.html`

3. **Marketing URL** (Optional)
   - New: `https://[yourdomain].com`

4. **Privacy Policy URL** (Required)
   - New: `https://[yourdomain].com/privacy.html`

5. **Copyright**
   - Current: "© 2026 Andrew Leone"
   - New: "© 2026 [Your LLC Name] LLC"

---

## 💳 IN-APP PURCHASE METADATA

### 7. StoreKit Product Descriptions

**Location:** App Store Connect > In-App Purchases > Each Product

**For Each Package (25, 100, 250, 500 minutes):**

Update the **"Display Name"** and **"Description"** if they mention personal name:

Current:
```
Purchased from Andrew Leone
```

New:
```
Purchased from [Your LLC Name] LLC
Terms apply. See callassist.com/terms
```

**Products to Update:**
- [ ] com.callassist.minutes.25
- [ ] com.callassist.minutes.100
- [ ] com.callassist.minutes.250
- [ ] com.callassist.minutes.500

---

## 🔧 CODE CHANGES NEEDED

### 8. Hardcoded Strings in App

**Search and Replace in Xcode:**

Use Xcode's Find & Replace (Cmd+Shift+F):

#### **Search for:** References to personal information

```
Find: "Andrew Leone"
Find: "your-email@gmail.com"
```

**Files That May Contain References:**
- ✅ Check: `Info.plist` (Copyright notice)
- ✅ Check: `ContentView.swift` (About section, if any)
- ✅ Check: `SettingsView.swift` (If you add company info)
- ✅ Check: Any "About" or "Contact" views

**Likely Safe (No changes needed):**
- ❌ No changes: Code files (Swift files are business-logic only)
- ❌ No changes: `MinutePackage.swift`, `MinutesManager.swift`, etc.

---

### 9. App Bundle ID Consideration

**Current Bundle ID:** `com.callassist.app`

**Decision Point:** Should you change this when forming LLC?

**Option A: Keep Current Bundle ID (Recommended)**
- ✅ Simpler (no changes needed)
- ✅ Generic enough
- ✅ No user impact
- 📝 Note: Bundle ID doesn't have to match company name

**Option B: Change to Match LLC**
- ❌ Requires new app submission (different app)
- ❌ Lose any existing users/ratings
- ❌ More work
- Only do this if: Starting completely fresh

**Recommendation:** Keep `com.callassist.app` - it's fine for an LLC too.

---

## 🌐 WEBSITE/DOMAIN CHANGES

### 10. Domain Registration

**When LLC Formed:**

1. **Purchase Domain:**
   - Suggested: `[yourllcname].com`
   - Alternative: `callassist.com` (if available)
   - Cost: ~$12/year (Namecheap, Google Domains)

2. **Set Up Simple Website:**
   - Host on: GitHub Pages (free) or Netlify (free)
   - Pages needed:
     - Homepage (optional but nice)
     - `/privacy.html` (required)
     - `/terms.html` (required)
     - `/support.html` (required)

3. **Update All URLs:**
   - [ ] Privacy policy URL in App Store Connect
   - [ ] Support URL in App Store Connect
   - [ ] Terms URL in purchase descriptions
   - [ ] Links in app (if any)

---

## 📝 DOCUMENTATION FILES TO UPDATE

### 11. Project Documentation

**Files in Your Repository:**

1. **README.md** (if you create one)
   ```markdown
   # CallAssist

   Developed by [Your LLC Name] LLC

   © 2026 [Your LLC Name] LLC. All rights reserved.
   ```

2. **LICENSE File** (if you add one)
   ```
   Copyright (c) 2026 [Your LLC Name] LLC
   ```

3. **CHANGELOG.md** (future releases)
   ```markdown
   ## Version 1.0.0 (2026-02-XX)
   - Initial release by [Your LLC Name] LLC
   ```

---

## 💰 FINANCIAL/ACCOUNTING SETUP

### 12. Bookkeeping Preparation

**After LLC Formation:**

1. **Business Bank Account**
   - Open with EIN
   - Separate from personal
   - Use for:
     - App Store payouts
     - Business expenses
     - Minute package purchases (testing)

2. **Accounting Software**
   - Recommended: QuickBooks Self-Employed ($15/mo)
   - Alternative: Wave (free)
   - Track:
     - App Store revenue
     - Vapi API costs
     - Developer account fee ($99/year)
     - Domain/hosting costs

3. **Business Credit Card** (Optional)
   - Use for: Apple Developer, subscriptions, tools
   - Benefit: Build business credit
   - Easier expense tracking

---

## 🔐 SECURITY UPDATES

### 13. API Keys and Secrets

**After LLC Formation:**

1. **Rotate API Keys:**
   - Vapi API Key
   - Google Calendar credentials
   - Microsoft Calendar credentials
   - Reason: Switch from personal account to business account

2. **Update Vapi Account:**
   - Login to: https://dashboard.vapi.ai
   - Update account name to LLC
   - Update billing to business credit card
   - Update contact email to business email

3. **Apple Developer Account:**
   - May need to: Create new account as LLC (or migrate existing)
   - Check with Apple about migrating individual → business account

---

## 📱 APP SUBMISSION CHECKLIST

### 14. Pre-Submission Verification

**Before Submitting to App Store with LLC:**

- [ ] App Store Connect legal entity updated
- [ ] Banking/tax info updated with EIN
- [ ] Privacy Policy live with LLC name
- [ ] Terms of Service live with LLC name
- [ ] Support page live with LLC name
- [ ] Support email active (support@yourdomain.com)
- [ ] Domain registered and website live
- [ ] Copyright notices updated
- [ ] App tested with new URLs (all links work)
- [ ] Screenshot texts don't mention personal name
- [ ] App description uses LLC name

---

## 🎯 QUICK SETUP SCRIPT (After LLC Formation)

### Run This Script to Find All References:

```bash
#!/bin/bash
# Save this as check_personal_references.sh

echo "🔍 Searching for personal references in CallAssist..."
echo ""

cd /Users/andrewleone/projects/CallAssist

echo "Searching Swift files for 'Andrew Leone':"
grep -r "Andrew Leone" CallAssist --include="*.swift" || echo "  ✅ None found"

echo ""
echo "Searching for personal email patterns:"
grep -r "@gmail.com\|@yahoo.com\|@hotmail.com" CallAssist --include="*.swift" --include="*.plist" || echo "  ✅ None found"

echo ""
echo "Checking Info.plist for Copyright:"
grep -A 2 "NSHumanReadableCopyright" CallAssist/Info.plist || echo "  ℹ️ No copyright key found"

echo ""
echo "🎯 Next: Update all found references to your LLC name"
```

---

## 📞 CONTACT INFO TEMPLATE

### Fill This Out After LLC Formation:

```
LLC NAME: _________________________________
EIN: _________________________________
FLORIDA ADDRESS: _________________________________
SUPPORT EMAIL: _________________________________
WEBSITE: _________________________________
DOMAIN REGISTRAR: _________________________________
EMAIL HOST: _________________________________
BUSINESS BANK: _________________________________
```

---

## ⚡ QUICK REFERENCE: FILES TO MODIFY

When LLC is formed, update these files:

### **Legal Documents (Website):**
1. `docs/privacy.html` - Company name, contact info
2. `docs/terms.html` - Company name, address, contact
3. `docs/support.html` - Company info, email

### **App Store Connect:**
4. Legal entity information
5. Tax information (SSN → EIN)
6. Banking information
7. App Information > Seller Name
8. App Information > Support URL
9. App Information > Privacy Policy URL
10. App Information > Copyright

### **Maybe (Search to Confirm):**
11. `Info.plist` - Copyright string
12. Any About/Settings views mentioning personal info

### **Business Setup:**
13. Register domain
14. Set up business email
15. Open business bank account
16. Update Vapi account

---

## 🚀 LAUNCH CHECKLIST ORDER

**Phase 1: Before App Submission (Can Do as Individual)**
1. Build app
2. Get OAuth working
3. Create placeholder privacy/terms (can use personal name)
4. Test everything
5. Submit for review

**Phase 2: After Approval (Update to LLC)**
1. Form LLC
2. Get EIN
3. Open business bank account
4. Register domain
5. Update legal documents
6. Update App Store Connect
7. Update app in next version (v1.0.1)

OR

**Phase 1: Form LLC First (Cleaner)**
1. Form LLC (2-3 days)
2. Get EIN (same day)
3. Open business bank (1 week)
4. Register domain (same day)
5. Set up emails (same day)
6. Create legal documents with LLC name
7. Update App Store Connect before submission
8. Submit app as LLC from day 1

**Recommended:** Form LLC first if you have time. Cleaner and more professional.

---

## 📧 EMAIL TEMPLATES FOR LATER

### When Updating Users (If Needed):

**Subject:** CallAssist Update - New Legal Entity

```
Hi CallAssist Users,

Quick update: CallAssist is now operated by [Your LLC Name] LLC.

What this means for you:
- Same great service ✅
- Better legal protection ✅
- More professional structure ✅
- Your data and purchases are unaffected ✅

Our new support email: support@[yourdomain].com

Questions? Reply to this email.

Thanks for using CallAssist!
[Your Name]
[Your LLC Name] LLC
```

---

## 💡 PRO TIPS

1. **Timing:** Form LLC before first app submission if possible
2. **Domain:** Buy domain when you register LLC name (make sure it's available!)
3. **Email:** Set up business email first thing (you'll need it everywhere)
4. **Banking:** Business bank account takes 1-2 weeks - start early
5. **EIN:** Get this same day you file LLC (online at IRS.gov)
6. **Backup:** Keep personal email as backup contact for 6 months

---

## ✅ FINAL VERIFICATION CHECKLIST

Before declaring "LLC migration complete":

- [ ] All legal docs show LLC name
- [ ] All emails go to business address
- [ ] App Store shows LLC as seller
- [ ] Privacy policy shows LLC
- [ ] Terms show LLC
- [ ] Support page shows LLC
- [ ] No references to personal name in app
- [ ] Business bank receives App Store payouts
- [ ] Vapi bills business account
- [ ] You've tested support email
- [ ] All URLs work
- [ ] Bookkeeping set up

**When all boxes checked:** 🎉 LLC migration complete!

---

**Save this file and reference it when you form your LLC!**

Last Updated: February 9, 2026
