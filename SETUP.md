# NexFlo — First-Time Setup Guide

Steps to run the project on a new device.

## Prerequisites
- Flutter >= 3.29.0 installed
- Android Studio with Flutter plugin
- Google Cloud project with Sheets + Drive API enabled
- `google-services.json` placed at `android/app/google-services.json`

## Steps

### 1. Generate native project files
```bash
flutter create . --project-name nexflo --org com.nexflo --platforms android,ios
```

### 2. Restore plan files overwritten by flutter create
```bash
git checkout -- pubspec.yaml lib/main.dart
```

### 3. Set minSdkVersion (required for ML Kit)
In `android/app/build.gradle`, change:
```gradle
minSdkVersion 24
```

### 4. Configure Google Services

```bash
cp lib/app/core/constants/google_services.example.dart \
   lib/app/core/constants/google_services.dart
```

Open `lib/app/core/constants/google_services.dart` and fill in your **Web application** OAuth Client ID from Google Cloud Console:

```dart
const String googleServerClientId =
    'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
```

**Where to find it:**
- Google Cloud Console → APIs & Services → Credentials
- Under "OAuth 2.0 Client IDs", find or create type **Web application**
- Copy the Client ID

> This file is gitignored. Do not commit it.

### 5. Install dependencies
```bash
flutter pub get
```

### 6. Generate Drift database code
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 7. Run the app
```bash
flutter run
```

## Notes
- `lib/app/data/database/app_database.g.dart` is generated — do not edit manually
- All generated `.g.dart` files are git-ignored
- `google_services.dart` is git-ignored — never commit it
- See `plans/plan.md` for full architecture documentation
