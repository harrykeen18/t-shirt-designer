# Pixel Tee - Design & Print

A Flutter mobile app that lets users create 20x20 pixel art designs and order custom t-shirts with instant fulfillment.

## Features

- **20x20 Pixel Grid Canvas** - Simple drawing interface with tap and drag
- **11 Color Palette** - Curated colors perfect for pixel art
- **Brush & Eraser Tools** - Easy design control
- **Undo/Redo** - Unlimited history (up to 50 states)
- **T-Shirt Preview** - Real-time mockup with 5 shirt color options
- **Secure Checkout** - Stripe payment processing
- **Print-on-Demand** - Teemill fulfillment integration

## Business Model

```
Customer pays YOU ($35)
  ↓
Stripe processes payment
  ↓
Firebase Function places order with Teemill (~$20)
  ↓
You keep ~$15 margin (before Stripe fees)
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
- **Stripe**: Payment processing (exempt from Apple's 30% per guideline 3.1.3(e))
- **Teemill**: Print-on-demand fulfillment

## Project Structure

```
├── app/                          # Flutter mobile app
│   ├── lib/
│   │   ├── core/                 # Constants & utilities
│   │   └── features/
│   │       ├── canvas/           # Pixel art drawing
│   │       ├── preview/          # T-shirt mockup
│   │       └── checkout/         # Payment & ordering
│   └── assets/
├── functions/                    # Firebase Cloud Functions
│   └── src/
│       ├── stripe/               # Payment processing
│       └── teemill/              # Order fulfillment
└── app_store_listing.md          # Submission materials
```

## Setup

### Prerequisites
- Flutter SDK 3.38.7+
- Firebase CLI
- Apple Developer Program membership ($99/year)
- Stripe account
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
# Add Stripe and Teemill keys to functions/.env
cp functions/.env.example functions/.env
# Edit functions/.env with your keys:
#   STRIPE_SECRET_KEY=sk_live_...
#   STRIPE_WEBHOOK_SECRET=whsec_...
#   TEEMILL_API_KEY=your_api_key

# Add publishable key to app/.env
cp app/.env.example app/.env
# Edit app/.env with your key:
#   STRIPE_PUBLISHABLE_KEY=pk_live_...
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

## Cost Breakdown

| Item | Cost | Notes |
|------|------|-------|
| Customer Price | $35.00 | What you charge |
| Teemill Cost | ~$20.00 | Varies by product |
| Stripe Fee | ~$1.32 | 2.9% + $0.30 |
| **Net Profit** | **~$13.68** | Per shirt |

## License

MIT License - See LICENSE file for details

## Built With

- [Flutter](https://flutter.dev) - UI framework
- [Firebase](https://firebase.google.com) - Backend services
- [Stripe](https://stripe.com) - Payment processing
- [Teemill](https://teemill.com) - Print-on-demand fulfillment

---

**Status**: Ready for App Store submission ✅

Created with [Claude Code](https://claude.com/claude-code)
