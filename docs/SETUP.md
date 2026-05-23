# Multi Payment Platform — Setup Guide

## Prerequisites
- Flutter SDK 3.16.0+
- Dart SDK 3.2.0+
- Android Studio / VS Code with Flutter plugin
- Xcode 15+ (for iOS)
- Node.js 18+ (for Firebase CLI)

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/AvinashK123-A/flutter-multi-payment-platform.git
cd flutter-multi-payment-platform
```

### 2. Environment Setup
```bash
cp .env.example .env
# Fill in your actual credentials
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Firebase Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools
firebase login

# Configure Firebase for your project
flutterfire configure

# This generates google-services.json and GoogleService-Info.plist
```

## Payment Gateway Configuration

### Razorpay Setup
1. Create account at [razorpay.com](https://razorpay.com)
2. Get API keys from Dashboard → Settings → API Keys
3. Add to .env: RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET

### Stripe Setup
1. Create account at [stripe.com](https://stripe.com)
2. Get API keys from Dashboard → Developers → API Keys
3. Add to .env: STRIPE_PUBLISHABLE_KEY, STRIPE_SECRET_KEY

### PayPal Setup
1. Create app at [developer.paypal.com](https://developer.paypal.com)
2. Get Client ID and Secret
3. Add to .env: PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET

## Run Configurations

### Development
```bash
flutter run --dart-define-from-file=.env --flavor dev -t lib/main_dev.dart
```

### Production
```bash
flutter run --dart-define-from-file=.env.prod --flavor prod -t lib/main_prod.dart
```

## Build

### Android APK (Release)
```bash
flutter build apk --flavor prod --dart-define-from-file=.env.prod
```

### iOS IPA (Release)
```bash
flutter build ipa --flavor prod --dart-define-from-file=.env.prod
```

## Project Structure
```
lib/
├── core/
│   ├── di/             # Dependency injection
│   ├── network/        # Dio HTTP client
│   ├── router/         # GoRouter navigation
│   ├── theme/          # App theming
│   ├── storage/        # Local storage
│   ├── errors/         # Error handling
│   └── widgets/        # Reusable widgets
├── features/
│   ├── auth/           # Authentication
│   ├── cart/           # Shopping cart
│   ├── payment/        # Payment processing
│   ├── home/           # Home screen
│   └── profile/        # User profile
└── main.dart
```

## Architecture
- **Pattern**: Clean Architecture + Feature-first
- **State Management**: BLoC
- **DI**: GetIt + Injectable
- **Navigation**: GoRouter
- **HTTP**: Dio with interceptors
- **Local Storage**: Hive
- **Code Gen**: build_runner + json_serializable

## Testing
```bash
# Unit tests
flutter test test/unit/

# Integration tests
flutter test integration_test/
```

## CI/CD
GitHub Actions workflows run on every push to main/develop:
- Code analysis (flutter analyze)
- Unit tests
- Build APK (dev/prod)
- Deploy to Firebase App Distribution
