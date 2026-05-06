// ─────────────────────────────────────────────────────────────────────────────
// google_services.dart — NexFlo Google OAuth Configuration
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW TO USE:
//   1. Copy this file and rename the copy to: google_services.dart
//      (google_services.dart is gitignored — never commit it)
//
//   2. Fill in your own values from Google Cloud Console.
//
// HOW TO GET YOUR serverClientId:
//   a. Go to https://console.cloud.google.com
//   b. Select your project → APIs & Services → Credentials
//   c. Under "OAuth 2.0 Client IDs", look for type "Web application"
//      (create one if it doesn't exist — choose type "Web application")
//   d. Copy the Client ID  →  format: xxxx-xxxx.apps.googleusercontent.com
//
// WHY Web application and not Android?
//   google_sign_in v7 on Android uses the Credential Manager API,
//   which requires a Web application client ID as the serverClientId.
//   The Android client ID (from google-services.json) is separate and
//   used automatically by the plugin — you don't need to reference it here.
//
// IS THIS SAFE TO COMMIT? No — use your own Google Cloud project.
//   If this were committed, forks of this repo would use your OAuth
//   consent screen name/branding. Keep it gitignored and let each
//   contributor set up their own Google Cloud project.
// ─────────────────────────────────────────────────────────────────────────────

const String googleServerClientId =
    'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
