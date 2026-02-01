# Firebase Setup Guide

## Step 1: Login to Firebase CLI

```bash
firebase login
```

This will open a browser window. Sign in with your Google account.

---

## Step 2: Create a Firebase Project

### Option A: Via Firebase Console (Recommended)

1. Go to https://console.firebase.google.com
2. Click "Add project" or "Create a project"
3. Project name: **tshirt-print** (or your preferred name)
4. Click "Continue"
5. **Disable** Google Analytics (optional, can enable later)
6. Click "Create project"
7. Wait for project creation (~30 seconds)

### Option B: Via CLI

```bash
# List existing projects
firebase projects:list

# Create new project (if you have Firebase Blaze plan)
firebase projects:create tshirt-print
```

---

## Step 3: Link Your Local Project

```bash
cd /Users/harry/Developement/tshirt-print

# Initialize Firebase (select existing project)
firebase use --add

# When prompted:
# - Select your project from the list
# - Alias: "default"
```

This updates `.firebaserc` with your project ID.

---

## Step 4: Add iOS App to Firebase

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your **tshirt-print** project
3. Click the iOS icon (⊕ Add app)
4. Fill in:
   - **iOS bundle ID**: `com.tshirtprint.tshirtPrint`
   - **App nickname**: T-Shirt Print iOS
   - **App Store ID**: (leave blank for now)
5. Click "Register app"
6. **Download GoogleService-Info.plist**
7. Move the file:
   ```bash
   # Move downloaded file to iOS project
   mv ~/Downloads/GoogleService-Info.plist app/ios/Runner/
   ```
8. Click "Next" through remaining steps

---

## Step 5: Add Android App to Firebase

1. In Firebase Console, click Android icon (⊕ Add app)
2. Fill in:
   - **Android package name**: `com.tshirtprint.tshirt_print`
   - **App nickname**: T-Shirt Print Android
   - **Debug signing certificate**: (leave blank for now)
3. Click "Register app"
4. **Download google-services.json**
5. Move the file:
   ```bash
   mv ~/Downloads/google-services.json app/android/app/
   ```
6. Click "Next" through remaining steps

---

## Step 6: Enable Firebase Services

### 6.1 Enable Firestore

1. In Firebase Console, go to **Build > Firestore Database**
2. Click "Create database"
3. Choose **Start in production mode** (we have custom rules)
4. Select location: **us-central** (or nearest to you)
5. Click "Enable"

### 6.2 Enable Storage

1. Go to **Build > Storage**
2. Click "Get started"
3. Choose **Start in production mode**
4. Use same location as Firestore
5. Click "Done"

### 6.3 Enable Functions (Blaze Plan Required)

1. Go to **Build > Functions**
2. Click "Get started"
3. **Upgrade to Blaze plan** if prompted
   - Pay-as-you-go (free tier: 2M invocations/month)
   - Required for external API calls (Stripe, Teemill)
4. Click "Continue" through setup

---

## Step 7: Deploy Firebase Security Rules

```bash
# Deploy Firestore and Storage rules
firebase deploy --only firestore:rules,storage
```

Expected output:
```
✔ Deploy complete!
```

---

## Step 8: Install Firebase Dependencies in Flutter App

```bash
cd app

# Add Firebase packages back to pubspec.yaml
# Uncomment the Firebase dependencies
```

Edit `app/pubspec.yaml` and uncomment:
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_storage: ^11.6.0
  cloud_firestore: ^4.14.0
  cloud_functions: ^4.6.0
  flutter_stripe: ^10.1.0
  flutter_dotenv: ^5.1.0
```

Then run:
```bash
flutter pub get

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate Firebase options file
flutterfire configure
```

---

## Step 9: Deploy Cloud Functions

```bash
cd functions

# Install dependencies
npm install

# Deploy functions
firebase deploy --only functions
```

Expected functions:
- ✅ createPaymentIntent
- ✅ stripeWebhook

---

## Step 10: Configure Environment Variables

### 10.1 Stripe Keys

```bash
# Get your keys from: https://dashboard.stripe.com/apikeys

# Set secret key for functions
firebase functions:config:set stripe.secret_key="sk_test_YOUR_KEY_HERE"

# Set webhook secret (from Stripe webhooks dashboard)
firebase functions:config:set stripe.webhook_secret="whsec_YOUR_SECRET_HERE"
```

### 10.2 Teemill API Key

```bash
# Get API key from: https://teemill.com/api-signup/

firebase functions:config:set teemill.api_key="YOUR_TEEMILL_KEY"
```

### 10.3 App Environment File

Create `app/.env`:
```bash
echo "STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_PUBLISHABLE_KEY" > app/.env
echo "FIREBASE_PROJECT_ID=your-project-id" >> app/.env
```

---

## Step 11: Set Up Stripe Webhook

1. Go to https://dashboard.stripe.com/webhooks
2. Click "+ Add endpoint"
3. Endpoint URL: `https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/stripeWebhook`
   - Replace YOUR_PROJECT_ID with your Firebase project ID
4. Description: "T-Shirt Print Orders"
5. Events to send:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
6. Click "Add endpoint"
7. Copy the **Signing secret** (starts with `whsec_`)
8. Update Firebase config:
   ```bash
   firebase functions:config:set stripe.webhook_secret="whsec_YOUR_SECRET"
   firebase deploy --only functions
   ```

---

## Step 12: Test the Setup

```bash
cd app

# Run on iOS simulator
flutter run -d "iPhone 14 Pro"

# Or run on Android emulator
flutter run -d emulator-5554
```

### Test Checklist:
- [ ] App launches without Firebase errors
- [ ] Can draw on pixel canvas
- [ ] Preview shows t-shirt mockup
- [ ] Checkout loads (even if payment fails in demo mode)

---

## Step 13: Enable Real Payments

Once ready for production:

1. Switch Stripe from test mode to live mode
2. Update function configs with live keys:
   ```bash
   firebase functions:config:set stripe.secret_key="sk_live_..."
   firebase functions:config:set stripe.webhook_secret="whsec_..."
   firebase deploy --only functions
   ```
3. Update `app/.env` with live publishable key
4. Rebuild the app: `flutter build ipa --release`

---

## Troubleshooting

### "Firebase not found" in app
- Run `flutterfire configure` again
- Make sure `GoogleService-Info.plist` is in `app/ios/Runner/`
- Make sure `google-services.json` is in `app/android/app/`

### Functions deployment fails
- Check you're on Blaze plan: https://console.firebase.google.com/project/_/usage
- Run `firebase login` again if authentication expired

### Stripe webhook not receiving events
- Check endpoint URL matches your deployed function
- Verify webhook secret in Firebase config: `firebase functions:config:get`

---

## Quick Reference

```bash
# View current Firebase project
firebase projects:list
firebase use

# View function logs
firebase functions:log

# View function config
firebase functions:config:get

# Deploy everything
firebase deploy

# Deploy specific service
firebase deploy --only functions
firebase deploy --only firestore:rules
firebase deploy --only storage
```

---

## Cost Estimates (Blaze Plan)

**Free Tier:**
- Firestore: 50K reads, 20K writes/day
- Storage: 5GB storage, 1GB/day download
- Functions: 2M invocations, 400K GB-seconds/month

**Expected Costs (100 orders/month):**
- Firestore: ~$0.50
- Storage: ~$0.10
- Functions: ~$0.20
- **Total: < $1/month** (well within free tier)

Your profit margin ($13.68/shirt) easily covers Firebase costs!
