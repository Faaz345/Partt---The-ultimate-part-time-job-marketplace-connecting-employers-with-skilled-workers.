# Partt - Part-Time Job Marketplace 💼

<div align="center">

**Connect employers with skilled workers for part-time opportunities**

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?style=for-the-badge&logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Private-orange?style=for-the-badge)](#)

**⚠️ PRIVATE REPOSITORY - ALL RIGHTS RESERVED**

[Features](#features) • [Screenshots](#screenshots) • [Tech Stack](#tech-stack)

</div>

---

## 📱 About Partt

Partt is a modern, full-featured mobile application that revolutionizes the part-time job marketplace. Built with Flutter and Firebase, it provides a seamless platform for employers to post jobs and workers to find flexible employment opportunities.

### 🎯 Key Highlights

- **Dual User Roles**: Separate interfaces for Managers (Employers) and Workers
- **Real-Time Updates**: Instant notifications via Firebase Cloud Messaging
- **Smart Job Matching**: Location-based job discovery
- **Secure Authentication**: Firebase Auth with Google Sign-In
- **Monetization Ready**: Fully integrated Google AdMob
- **Modern UI/UX**: Built with Flutter's Material Design principles

---

## ✨ Features

### 👔 For Managers (Employers)

- 📝 **Post Jobs Quickly**: Create detailed job listings with requirements
- 👥 **Manage Applications**: Review and respond to job applications
- 💬 **Direct Messaging**: Communicate with potential employees
- 📊 **Dashboard Analytics**: Track active jobs and applications
- 🔔 **Real-Time Notifications**: Get instant alerts for new applications
- 📷 **Company Profiles**: Showcase your business with photos and details

### 💼 For Workers (Job Seekers)

- 🔍 **Discover Jobs**: Browse part-time opportunities near you
- ⚡ **Quick Apply**: Submit applications with one tap
- 📍 **Location-Based Search**: Find jobs in your area
- 🔔 **Job Alerts**: Get notified about matching opportunities
- 📊 **Application Tracking**: Monitor your application status
- 👤 **Professional Profile**: Build your profile with skills and experience

### 🎨 Core Features

- ✅ **Firebase Integration**: Auth, Firestore, Storage, Cloud Messaging
- ✅ **Google Sign-In**: Quick and secure authentication
- ✅ **Push Notifications**: Stay updated with real-time alerts
- ✅ **Image Upload**: Camera and gallery integration
- ✅ **Location Services**: Geolocation and geocoding
- ✅ **AdMob Monetization**: Banner and interstitial ads
- ✅ **Responsive Design**: Adapts to all screen sizes
- ✅ **Dark Mode Support**: Eye-friendly interface options

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: [Flutter 3.9.2](https://flutter.dev) - Cross-platform UI toolkit
- **Language**: [Dart](https://dart.dev) - Client-optimized language
- **State Management**: [Provider](https://pub.dev/packages/provider) & [Riverpod](https://pub.dev/packages/riverpod)
- **UI Components**: [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) - Responsive design
- **Navigation**: [go_router](https://pub.dev/packages/go_router) - Declarative routing

### Backend & Services
- **Authentication**: [Firebase Auth](https://firebase.google.com/products/auth) with Google Sign-In
- **Database**: [Cloud Firestore](https://firebase.google.com/products/firestore) - NoSQL cloud database
- **Storage**: [Firebase Storage](https://firebase.google.com/products/storage) - File storage
- **Push Notifications**: [Firebase Cloud Messaging](https://firebase.google.com/products/cloud-messaging)
- **Analytics**: [Firebase Analytics](https://firebase.google.com/products/analytics)

### Additional Libraries
- **Monetization**: [Google Mobile Ads](https://pub.dev/packages/google_mobile_ads) - AdMob integration
- **Location**: [Geolocator](https://pub.dev/packages/geolocator) & [Geocoding](https://pub.dev/packages/geocoding)
- **Image Processing**: [Image Picker](https://pub.dev/packages/image_picker) & [Image Cropper](https://pub.dev/packages/image_cropper)
- **Caching**: [Cached Network Image](https://pub.dev/packages/cached_network_image)
- **Animations**: [Lottie](https://pub.dev/packages/lottie) & [Shimmer](https://pub.dev/packages/shimmer)
- **Local Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Permissions**: [Permission Handler](https://pub.dev/packages/permission_handler)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.9.2 or higher)
- Android Studio / VS Code
- Firebase account
- AdMob account (for monetization)

### Installation

> **⚠️ Note**: This is a private repository. Unauthorized cloning, copying, or distribution is prohibited.

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android and iOS apps
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in respective directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Configure AdMob**
   - Create an AdMob account at [AdMob Console](https://admob.google.com)
   - Create ad units (Banner and Interstitial)
   - Update ad unit IDs in `lib/core/services/admob_service.dart`
   - Update App ID in `android/app/src/main/AndroidManifest.xml`

5. **Run the app**
   ```bash
   # Debug mode
   flutter run

   # Release mode
   flutter run --release
   ```

---

## 📦 Build & Release

### Android APK

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Bundle location: `build/app/outputs/bundle/release/app-release.aab`

---

## 🗂️ Project Structure

```
lib/
├── core/
│   ├── constants/         # App constants and themes
│   ├── helpers/           # Helper functions
│   ├── providers/         # State management providers
│   ├── services/          # Backend services (Auth, FCM, AdMob)
│   └── widgets/           # Reusable widgets
├── features/
│   ├── auth/              # Authentication screens
│   ├── dashboard/         # Dashboard screens (Manager/Worker)
│   ├── jobs/              # Job posting and search
│   ├── profile/           # User profile management
│   ├── chat/              # Messaging functionality
│   ├── notifications/     # Notification screens
│   └── ...                # Other features
└── main.dart              # App entry point
```

---

## 🔧 Configuration

### Firebase Setup

1. **Firestore Database**
   - Create collections: `users`, `jobs`, `applications`, `messages`, `notifications`
   - Set up security rules for data protection

2. **Firebase Storage**
   - Configure storage rules for profile pictures and job images

3. **Cloud Messaging**
   - Enable FCM for push notifications
   - Configure notification channels

### AdMob Configuration

Update the following files with your AdMob IDs:

**`lib/core/services/admob_service.dart`**
```dart
static const String _androidBannerAdUnitId = 'YOUR_BANNER_AD_UNIT_ID';
static const String _androidInterstitialAdUnitId = 'YOUR_INTERSTITIAL_AD_UNIT_ID';
```

**`android/app/src/main/AndroidManifest.xml`**
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_ADMOB_APP_ID"/>
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Code coverage
flutter test --coverage
```

---

## 📚 Documentation

- **Setup Guide**: [ADMOB_SETUP_GUIDE.md](ADMOB_SETUP_GUIDE.md)
- **Troubleshooting**: [ADMOB_TROUBLESHOOTING.md](ADMOB_TROUBLESHOOTING.md)
- **Release Notes**: [RELEASE_NOTES.md](RELEASE_NOTES.md)

---


## 🐛 Known Issues

- Ads may take 1-24 hours to activate after initial AdMob setup
- Some location services may not work on emulators
- Google Sign-In requires SHA-1 certificate configuration

---

## 🗺️ Roadmap

- [ ] iOS version release
- [ ] Web platform support
- [ ] In-app payment integration
- [ ] Advanced job filtering
- [ ] Job recommendations with AI
- [ ] Video profile/job previews
- [ ] Multi-language support
- [ ] Dark mode enhancements
- [ ] Offline mode support
- [ ] Analytics dashboard for managers

---

## 📄 License & Copyright

**© 2025 Faaz Razzaq. All Rights Reserved.**

This software is proprietary and confidential. Unauthorized copying, distribution, modification, or use of this software, via any medium, is strictly prohibited without the express written permission of the copyright holder.

For the complete license terms, see the [LICENSE](LICENSE) file.

---

## ⚠️ Legal Notice

**PRIVATE & CONFIDENTIAL**

This repository and its contents are private property. The source code, documentation, and all related materials are protected by copyright law and international treaties. 

**Prohibited Actions:**
- ❌ Copying or reproducing the code
- ❌ Distributing or sharing the software
- ❌ Modifying or creating derivative works
- ❌ Using the code for commercial purposes
- ❌ Reverse engineering or decompiling

Unauthorized use will result in legal action.

---

<div align="center">

**Made with ❤️ using Flutter**

**© 2025 Faaz Razzaq - Partt. All Rights Reserved.**

[⬆ Back to Top](#partt---part-time-job-marketplace-)

</div>
