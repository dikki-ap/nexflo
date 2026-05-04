# NexFlo 💸

> **Next-level money flow**

A personal finance management app built with Flutter. Track your income, expenses, and transfers across multiple wallets — with beautiful charts, budget tracking, savings goals, and debt management. Your data stays on your device and syncs to your own Google Sheets.

<br/>

<!-- Badges -->

![Flutter](https://img.shields.io/badge/Flutter-3.29.x-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.7.x-0175C2?style=flat-square&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-00BCD4?style=flat-square)
![Status](https://img.shields.io/badge/Status-In%20Development-FFC107?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen?style=flat-square)

---

## 📸 Screenshots

> _Coming soon — screenshots will be added as the app is built._

---

## ✨ Features

### 💳 Wallet Management

- Multiple wallet types: Cash, Bank, E-Wallet, Credit Card, Investment, Savings
- Custom name, color, and icon per wallet
- Drag & drop reorder
- Adjust balance with or without creating a record
- Archive wallets without losing history
- Per-wallet currency support

### 💸 Transaction Tracking

- Three transaction types: **Expense**, **Income**, **Transfer**
- Category & sub-category with custom icons and colors
- Receipt photo capture with **OCR auto-fill** (on-device, no API key needed)
- Flexible date filters: This Month, 1M, 3M, 6M, 1Y, 3Y, 5Y, All Time, Custom Range
- Cutoff date setting (e.g. salary date on the 25th = your "month")
- Search, filter, and grouped transaction list

### 📊 Statistics & Reports

- Donut/Pie chart — expense by category
- Bar chart — income vs expense comparison
- Line chart — balance trend over time
- Area chart — cashflow visualization
- Net worth chart — total assets over time
- Top spending categories & transactions
- Export to **CSV** and **PDF**

### 💰 Budget Tracking

- Set budgets per category or globally
- Monthly, weekly, or yearly periods
- Rollover unused budget to next period
- Color-coded progress bars (green → yellow → orange → red)
- Notifications at 80% and 100% usage

### 🎯 Savings Goals

- Target amount, deadline, and linked wallet
- Progress tracking with projected completion date
- "On track" / "Behind schedule" indicator
- Manual allocation from wallet balance

### 💸 Debt Management

- Track debts you owe and debts owed to you
- Partial payment history
- Overdue indicator
- Settlement flow with full history

### 🔁 Recurring Transactions

- Daily, weekly, monthly, or yearly recurrence
- Auto-processed on app open and in background
- Skip or execute manually

### 💱 Multi-Currency

- Set a base currency for all statistics
- Per-wallet currency (USD wallet, IDR wallet, SGD wallet, etc.)
- Exchange rates via [Frankfurter API](https://frankfurter.app) (free, no API key)
- Historical rates preserved — old reports stay accurate

### 🎨 Theming

- Light / Dark / System mode
- Accent colors: Teal (default), Blue, Purple, Green, Orange, Pink, Custom
- Fully consistent Material 3 design

### 🔐 Security

- Google Sign-In (OAuth 2.0) — no password needed
- Biometric lock (fingerprint / face ID)
- PIN lock (4–6 digit)
- Auto-lock after configurable background timeout

### ☁️ Privacy-First Sync

- **Local-first** — all data stored on your device (SQLite)
- **Your data, your Google Drive** — syncs to a spreadsheet in your own Google account
- Works 100% offline — sync happens in background when online
- Developer has **zero access** to your financial data

---

## 🏗️ Architecture

NexFlo is built with **Clean Architecture** and **GetX** state management.

```
Presentation Layer  →  Pages, Widgets, GetX Controllers, Bindings
Domain Layer        →  Entities, Use Cases, Repository Contracts
Data Layer          →  Models, Repository Implementations, Local DS, Remote DS
```

```
lib/
└── app/
    ├── core/           # Constants, enums, extensions, utils, errors
    ├── config/         # Routes, theme
    ├── data/           # Database (Drift), models, datasources, repositories
    ├── domain/         # Entities, use cases, repository contracts
    ├── modules/        # Feature modules (splash, auth, dashboard, wallet, ...)
    └── services/       # Global GetX services (auth, sync, connectivity, ...)
```

---

## 🛠️ Tech Stack

| Category         | Technology                   |
| ---------------- | ---------------------------- |
| Framework        | Flutter 3.29.x               |
| Language         | Dart 3.7.x                   |
| State Management | GetX                         |
| Local Database   | Drift (SQLite)               |
| Auth             | Google Sign-In OAuth 2.0     |
| Cloud Sync       | Google Sheets API v4         |
| Charts           | FL Chart                     |
| OCR              | Google ML Kit (on-device)    |
| Currency Rates   | Frankfurter API (free)       |
| Background Sync  | WorkManager                  |
| Security         | local_auth (biometric + PIN) |

---

## 🚀 Getting Started

### Prerequisites

- Flutter `>=3.29.0`
- Dart `>=3.7.0`
- A Google account
- Google Cloud Console project (for OAuth + Sheets API)

### 1. Clone the repository

```bash
git clone https://github.com/dikki-ap/nexflo.git
cd nexflo
```

### 2. Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project (e.g. `NexFlo`)
3. Enable the following APIs:
   - **Google Sheets API**
   - **Google Drive API**
4. Go to **APIs & Services → OAuth consent screen**
   - User Type: External
   - Fill in app name, support email
   - Add scopes: `email`, `profile`, `spreadsheets`, `drive.file`
5. Go to **APIs & Services → Credentials → Create Credentials → OAuth 2.0 Client ID**
   - Create one for **Android** (use your app's SHA-1)
   - Create one for **iOS** (use your bundle ID)
6. Download the config files:
   - `google-services.json` → place in `android/app/`
   - `GoogleService-Info.plist` → place in `ios/Runner/`

### 3. Configure Android

**`android/app/build.gradle`**

```gradle
android {
    defaultConfig {
        minSdkVersion 24       // Required for ML Kit
        targetSdkVersion 35
    }
}
```

**`android/app/google-services.json`**

> Copy from Google Cloud Console (see step 2)

### 4. Configure iOS

**`ios/Runner/Info.plist`** — add OAuth URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

**`ios/Runner/GoogleService-Info.plist`**

> Copy from Google Cloud Console (see step 2)

Minimum iOS deployment target: **13.0**

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
# Debug
flutter run

# Release (Android)
flutter build apk --release

# Release (iOS)
flutter build ipa --release
```

---

## 📦 Key Dependencies

```yaml
# State Management
get: ^4.7.3

# Local Database
drift: ^2.32.1
drift_flutter: ^0.3.0

# Auth & Google Services
google_sign_in: ^7.2.0
googleapis: ^16.0.0
googleapis_auth: ^1.6.0
extension_google_sign_in_as_googleapis_auth: ^2.0.12

# Charts
fl_chart: ^1.2.0

# OCR
google_mlkit_text_recognition: ^0.15.1

# Security
local_auth: ^3.0.1

# Background Sync
workmanager: ^0.9.0+3

# Utilities
uuid: ^4.5.1
intl: ^0.20.2
connectivity_plus: ^6.1.3
flutter_secure_storage: ^9.2.4
```

> See [`pubspec.yaml`](pubspec.yaml) for the full list.

---

## ☁️ How Data Sync Works

```
Your Device (SQLite)
       ↕  background sync
Your Google Drive (Spreadsheet)
```

1. On first login, NexFlo **auto-creates** a spreadsheet in your Google Drive:
   `📊 NexFlo — My Financial Data`
2. All data is written to local SQLite **first** — no waiting for network
3. Changes are queued and synced to your spreadsheet in the **background**
4. If offline, the app works normally — sync resumes when you're back online
5. **You can open the spreadsheet anytime** to view or export your raw data
6. The developer has **no access** to your spreadsheet or financial data

---

## 🌐 Currency Support

NexFlo uses the [Frankfurter API](https://frankfurter.app) — a free, open-source exchange rate service with no API key required.

- Set one **base currency** (e.g. USD) for all statistics
- Each wallet can have its **own currency**
- Exchange rates are **auto-refreshed** once per day when online
- Rates at the time of each transaction are **preserved** — historical reports stay accurate

**Supported currencies (pre-seeded):**
`USD · EUR · GBP · JPY · SGD · MYR · IDR · AUD · CAD · CHF · CNY · HKD · KRW · INR · THB · PHP · VND · TWD · NZD · AED`

---

## 🔐 Security & Privacy

| Concern          | Approach                                       |
| ---------------- | ---------------------------------------------- |
| Auth             | Google OAuth 2.0 — no password stored          |
| Tokens           | Stored in `flutter_secure_storage` (encrypted) |
| PIN              | Stored as SHA-256 hash — never plain text      |
| Local data       | SQLite on device private storage               |
| Cloud data       | Your own Google Drive — private by default     |
| Developer access | **Zero** — no backend, no server, no analytics |
| Receipt images   | Stored in app private directory                |

---

## 📋 Roadmap

### Phase 1 — Foundation ✅ _planned_

- Project setup, Drift DB, GetX routing, theme system, auth, onboarding, splash

### Phase 2 — Core Features 🔄 _in progress_

- Wallet management, transaction CRUD, category management, dashboard

### Phase 3 — Planning Features 📅 _upcoming_

- Budget tracking, savings goals, debt management

### Phase 4 — Analytics 📅 _upcoming_

- Statistics page, all charts, recurring transactions, CSV export

### Phase 5 — Sync & Currency 📅 _upcoming_

- Google Sheets sync engine, multi-currency support

### Phase 6 — Smart Features 📅 _upcoming_

- OCR receipt scanning, biometric/PIN lock, notifications, PDF export, polish

---

## 🤝 Contributing

This is a personal portfolio project. Contributions are not currently open, but feel free to:

- ⭐ Star the repo if you find it useful
- 🐛 Open an issue if you find a bug
- 💡 Suggest features via GitHub Discussions

---

## 📄 License

```
MIT License

Copyright (c) 2026 [Dikki AP]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👤 Author

**[Dikki AP]**

- GitHub: [@dikki-ap](https://github.com/dikki-ap)
- LinkedIn: [Dikki AP](https://linkedin.com/in/dikki-ap)
- Portfolio: [GitHub IO](https://dikki-ap.github.io)

---

<div align="center">
  <sub>Built with ❤️ using Flutter · NexFlo © 2026</sub>
</div>
