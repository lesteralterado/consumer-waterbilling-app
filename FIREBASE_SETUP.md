# Firebase Cloud Messaging Setup Guide

This guide explains how to set up Firebase Cloud Messaging (FCM) for push notifications in the ANOPOG Consumer Water Billing App.

## Prerequisites

1. A Firebase project (same one used for your backend)
2. Android Studio or VS Code with Flutter extensions
3. Google Play Services on your Android device/emulator

## File Types Needed

### For Backend (Server-side)
- **`firebase-service-account.json`**: Service account key for Firebase Admin SDK
  - Used by your backend to send push notifications
  - You already have this configured ✅

### For Flutter App (Client-side)
- **`google-services.json`**: Client configuration file
  - Used by Firebase SDK in the mobile app
  - Required for FCM token generation and app initialization
  - This is what we need to add now

## Setup Steps

### 1. Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. **Use the same Firebase project** that your backend is using
3. Enable Firebase Cloud Messaging (should already be enabled for your backend)

### 2. Android Configuration

Since you already have a Firebase project set up for your backend, you just need to add the Android app to that same project:

1. **Add Android app to existing Firebase project**:
   - Go to your existing Firebase Console project
   - Go to Project Settings > General
   - Scroll down to "Your apps" section
   - Click "Add app" and select Android (⚠️ **not** "Add Firebase to an existing Google project)
   - Enter your package name: `com.anopog.app`
   - Enter an app nickname (optional)
   - **Skip the google-services.json download for now** (we'll get it in the next step)

2. **Download google-services.json**:
   - After adding the Android app, you'll see it listed in "Your apps"
   - Click on the Android app icon
   - Scroll down and click "Download google-services.json"

3. **Place google-services.json**:
   - Copy the downloaded `google-services.json` file to `android/app/google-services.json`
   - This file contains your client-side Firebase configuration

4. **Gradle Configuration (Already Done ✅)**:
   - **Root-level (project-level) Gradle file** (`android/build.gradle`):
     ```gradle
     plugins {
       id("com.google.gms.google-services") version "4.4.4" apply false
     }
     ```
   - **Module (app-level) Gradle file** (`android/app/build.gradle`):
     ```gradle
     plugins {
       id("com.android.application")
       id("kotlin-android")
       id("com.google.gms.google-services")  // Already added
       id("dev.flutter.flutter-gradle-plugin")
     }

     dependencies {
       // Import the Firebase BoM
       implementation platform('com.google.firebase:firebase-bom:34.6.0')

       // Add Firebase products you want to use
       implementation 'com.google.firebase:firebase-analytics'
       implementation 'com.google.firebase:firebase-messaging'
     }
     ```

### 3. iOS Configuration (Optional)

If you plan to support iOS:

1. In Firebase Console, add an iOS app
2. Download `GoogleService-Info.plist`
3. Add it to `ios/Runner/GoogleService-Info.plist`

### 4. Backend Configuration

**No additional backend configuration needed!** ✅

Your backend is already set up with the `firebase-service-account.json` for sending notifications. The Flutter app will automatically register device tokens with your existing backend via the `/api/register-device-token` endpoint after successful login.

## Implementation Details

### Consumer Onboarding Flow

1. **Admin Creates Consumer Account**: Admin creates accounts via web dashboard
2. **Consumer Downloads & Opens App**: Firebase services initialize automatically
3. **Consumer Logs In**: Authentication via `/api/login`
4. **Automatic Device Token Registration**: After successful login, the app:
   - Requests FCM permission
   - Gets device token from Firebase
   - Registers token with backend via `/api/register-device-token`
5. **Push Notifications Ready**: Consumer can now receive notifications for bills, payments, and issue updates

### Key Files Modified

- `pubspec.yaml`: Added Firebase dependencies
- `android/app/build.gradle`: Added Google Services plugin
- `android/build.gradle`: Added Google Services classpath
- `lib/main.dart`: Firebase initialization
- `lib/services/fcm_service.dart`: FCM token management
- `lib/presentation/login_screen/login_screen.dart`: Device token registration after login

### FCM Service Features

- Automatic permission requests
- Device token generation and management
- Backend registration of device tokens
- Message handling for foreground and background notifications

## Testing

1. Run the app on a physical Android device (emulators may not support FCM properly)
2. Log in with a consumer account
3. Check device logs for successful token registration
4. Send a test notification from Firebase Console or your backend

## Troubleshooting

### Common Issues

1. **google-services.json not found**: Ensure the file is placed in `android/app/`
2. **Permission denied**: FCM requires notification permissions
3. **Token not registering**: Check network connectivity and backend endpoint
4. **Notifications not received**: Verify FCM server key in backend and device token registration

### Debug Tips

- Check Android logs for Firebase initialization messages
- Use Firebase Console's "Send test message" feature
- Verify device token is being sent to backend correctly

## Security Notes

- Device tokens are stored securely on the backend
- Tokens are associated with user accounts for targeted notifications
- FCM handles token refresh automatically when needed

## Next Steps

1. Implement notification handling in the app UI
2. Add notification preferences for users
3. Set up notification categories (bills, payments, issues)
4. Test with production backend