# Pixel Tee - Design & Print

A Flutter mobile app that lets users create 20x20 pixel art designs and order custom t-shirts with instant fulfillment.

## Features

- **20x20 Pixel Grid Canvas** - Simple drawing interface with tap and drag
- **11 Color Palette** - Curated colors perfect for pixel art
- **Brush & Eraser Tools** - Easy design control
- **Undo/Redo** - Unlimited history (up to 50 states)
- **T-Shirt Preview** - Real-time mockup with 5 shirt color options
- **Teemill Checkout** - Hosted checkout handles payment, shipping & fulfillment
- **Web Support** - Works on iOS, Android, and web

## How It Works

```
User creates design
  ↓
Firebase Function creates product on Teemill
  ↓
User redirected to Teemill checkout
  ↓
Teemill handles payment, printing & shipping
```

## Architecture

### Mobile App (Flutter)
- **State Management**: Riverpod 2.0
- **Navigation**: go_router
- **Image Processing**: dart image package (2000x2000px exports)

### Backend (Firebase)
- **Functions**: Node.js/TypeScript for payment & order processing
- **Storage**: Design images (PNG)
- **Firestore**: Order records and metadata

### External Services
- **Teemill**: Print-on-demand with hosted checkout (handles payment, shipping, fulfillment)

## Project Structure

```
├── app/                          # Flutter app (iOS, Android, Web)
│   ├── lib/
│   │   ├── core/                 # Constants & utilities
│   │   └── features/
│   │       ├── canvas/           # Pixel art drawing
│   │       ├── preview/          # T-shirt mockup
│   │       └── checkout/         # Teemill integration
│   └── assets/
├── functions/                    # Firebase Cloud Functions
│   └── src/
│       └── teemill/              # Product creation API
└── app_store_listing.md          # Submission materials
```

## Setup

### Prerequisites
- Flutter SDK 3.2.0+
- Firebase CLI
- Teemill API access

### 1. Firebase Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and initialize
firebase login
firebase init

# Deploy functions
cd functions && npm install
firebase deploy --only functions
```

### 2. Configure Environment Variables
```bash
# Add Teemill key to functions/.env
cp functions/.env.example functions/.env
# Edit functions/.env with your key:
#   TEEMILL_API_KEY=your_api_key
```

### 4. Run the App
```bash
cd app
flutter pub get
flutter run
```

## Deployment

### iOS App Store
```bash
# Build release IPA
cd app
flutter build ipa --release

# Upload via Transporter app or:
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/tshirt_print.ipa \
  --apiKey YOUR_KEY --apiIssuer YOUR_ISSUER
```

### Android Play Store
```bash
# Build release bundle
cd app
flutter build appbundle --release

# Upload build/app/outputs/bundle/release/app-release.aab
```

## Competitive Landscape

### Direct Competitors
- **Snaptee** - Design + marketplace (10% commission)
- **Merch Pixel** - AI-generated designs
- **TeeCraft** - Template-based design tools

### Unique Advantage
No existing app offers **simple pixel grid drawing + instant print fulfillment** in one package.

## Pricing

Set your retail price via the `price` parameter in `functions/src/teemill/createProduct.ts`. Teemill's base cost is approximately £12-15 for a basic organic t-shirt. Your profit is the difference between the retail price you set and Teemill's base cost.

## Archived Branches

### `archive/stripe-checkout`

A previous implementation that used Stripe for payment processing instead of Teemill's hosted checkout. This gave more control over the checkout flow but required:
- Collecting shipping addresses in-app
- Managing Stripe webhooks
- Calling Teemill's Orders API for fulfillment

**What it contains:**
- `functions/src/stripe/createPaymentIntent.ts` - Creates Stripe PaymentIntent
- `functions/src/stripe/webhookHandler.ts` - Handles payment confirmation
- `app/lib/features/checkout/presentation/widgets/address_form.dart` - Shipping address collection
- `app/lib/features/checkout/presentation/screens/success_screen.dart` - Order confirmation screen
- Full `flutter_stripe` integration

**To restore Stripe checkout:**
```bash
# Restore the Stripe functions
git checkout archive/stripe-checkout -- functions/src/stripe/

# Restore the Flutter checkout UI
git checkout archive/stripe-checkout -- app/lib/features/checkout/

# Restore main.dart with Stripe initialization
git checkout archive/stripe-checkout -- app/lib/main.dart

# Re-add dependencies
# In app/pubspec.yaml, add:
#   flutter_stripe: ^11.4.0
#   flutter_dotenv: ^5.1.0
#   cloud_firestore: ^5.6.7

# In functions, you'll need Stripe keys in .env:
#   STRIPE_SECRET_KEY=sk_...
#   STRIPE_WEBHOOK_SECRET=whsec_...
```

## License

MIT License - See LICENSE file for details

## Built With

- [Flutter](https://flutter.dev) - UI framework (iOS, Android, Web)
- [Firebase](https://firebase.google.com) - Backend services
- [Teemill](https://teemill.com) - Print-on-demand with hosted checkout

---

**Status**: Ready for deployment

Created with [Claude Code](https://claude.com/claude-code)
