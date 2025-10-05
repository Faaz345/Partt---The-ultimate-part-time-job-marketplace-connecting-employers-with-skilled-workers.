# Firebase Cloud Messaging (FCM) Setup Guide
## Push Notifications When App is Closed

This guide explains how to add Firebase Cloud Messaging to receive notifications even when the app is closed.

## Prerequisites

- Firebase project configured (✅ Already done)
- Firebase Cloud Messaging enabled in Firebase Console
- Android/iOS configured for push notifications

## Step 1: Add FCM Dependencies

### pubspec.yaml
Add these packages:

```yaml
dependencies:
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
```

Run:
```bash
flutter pub get
```

## Step 2: Configure Android

### android/app/src/main/AndroidManifest.xml

Add inside `<application>` tag:

```xml
<!-- FCM -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />

<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />

<service
    android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### android/app/build.gradle

Ensure minimum SDK version is 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Must be 21 or higher
    }
}
```

## Step 3: Configure iOS (if targeting iOS)

### ios/Runner/Info.plist

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## Step 4: Create FCM Service

Create: `lib/core/services/fcm_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // Handle notification when app is in background/terminated
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize FCM and request permissions
  static Future<void> initialize() async {
    // Request permission (iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Get FCM token and save to Firestore
    await _saveFCMToken();
  }

  /// Initialize local notifications (for displaying notifications when app is open)
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap when app is open
        print('Notification tapped: ${details.payload}');
      },
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Save FCM token to Firestore for the current user
  static Future<void> _saveFCMToken() async {
    try {
      final token = await _messaging.getToken();
      final userId = _auth.currentUser?.uid;

      if (token != null && userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('FCM token saved: $token');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': newToken,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Handle messages when app is in foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');

    // Display local notification
    await _showLocalNotification(message);
  }

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Navigate to appropriate screen based on notification data
    // You can use Navigator or a global navigation key
  }

  /// Get FCM token for current device
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Delete FCM token (call on logout)
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': FieldValue.delete(),
        });
      }
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }
}
```

## Step 5: Initialize FCM in main.dart

Update your `main.dart`:

```dart
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize FCM
  await FCMService.initialize();
  
  runApp(const MyApp());
}
```

## Step 6: Update User Model

Add FCM token field to user documents in Firestore:

```dart
// In your user creation/update code
await FirebaseFirestore.instance.collection('users').doc(userId).set({
  // ...existing fields
  'fcmToken': null, // Will be set by FCM service
  'fcmTokenUpdatedAt': null,
}, SetOptions(merge: true));
```

## Step 7: Send Push Notifications via Cloud Functions

Create Firebase Cloud Functions to send notifications:

### functions/index.js

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Send notification when new job is posted
exports.sendJobNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    // Get user's FCM token
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(notification.userId)
      .get();
    
    const fcmToken = userDoc.data()?.fcmToken;
    
    if (!fcmToken) {
      console.log('No FCM token for user:', notification.userId);
      return null;
    }
    
    // Build notification message
    const message = {
      token: fcmToken,
      notification: {
        title: notification.title,
        body: notification.message,
      },
      data: {
        type: notification.type,
        relatedId: notification.relatedId || '',
        notificationId: snap.id,
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          priority: 'high',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };
    
    try {
      await admin.messaging().send(message);
      console.log('Notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
    
    return null;
  });
```

## Step 8: Deploy Cloud Functions

```bash
cd functions
npm install firebase-functions firebase-admin
firebase deploy --only functions
```

## Step 9: Handle Logout

Clear FCM token on logout:

```dart
// In your logout function
await FCMService.deleteToken();
await FirebaseAuth.instance.signOut();
```

## Testing Push Notifications

### Test via Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter title and message
4. Select target: Specific device (paste FCM token)
5. Send

### Test via Code

```dart
// Get your FCM token
final token = await FCMService.getToken();
print('FCM Token: $token');
// Copy this token and use it in Firebase Console
```

## Notification Behavior

| App State | Behavior |
|-----------|----------|
| **Foreground** | Local notification displayed |
| **Background** | System notification shown |
| **Terminated** | System notification shown |

## Troubleshooting

### Notifications not received

1. **Check FCM token**
   ```dart
   final token = await FCMService.getToken();
   print('Token: $token');
   ```

2. **Check Firestore rules** - Ensure users can write FCM tokens

3. **Check Android permissions** - Ensure POST_NOTIFICATIONS permission

4. **Check Cloud Functions logs**
   ```bash
   firebase functions:log
   ```

### Android 13+ Permission

For Android 13+, request notification permission:

```dart
// Add to your permission request code
if (Platform.isAndroid && Build.VERSION.SDK_INT >= 33) {
  await Permission.notification.request();
}
```

## Best Practices

1. **Update token on login** - Refresh FCM token when user logs in
2. **Clear token on logout** - Remove FCM token when user logs out
3. **Handle token refresh** - Listen for token updates
4. **Test thoroughly** - Test on real devices (emulators may not work)
5. **Rate limiting** - Don't spam users with too many notifications

## Security Rules Update

Add to `firestore.rules`:

```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
  
  // Allow user to update their own FCM token
  allow update: if request.auth != null && 
                  request.auth.uid == userId &&
                  request.resource.data.diff(resource.data).affectedKeys()
                    .hasOnly(['fcmToken', 'fcmTokenUpdatedAt']);
}
```

## Summary

✅ **Step 1:** Add dependencies to `pubspec.yaml`
✅ **Step 2:** Configure Android manifest
✅ **Step 3:** Create `FCMService` class
✅ **Step 4:** Initialize FCM in `main.dart`
✅ **Step 5:** Create Cloud Functions for sending notifications
✅ **Step 6:** Deploy Cloud Functions
✅ **Step 7:** Test on real device

**Result:** Users will receive push notifications even when the app is closed! 🎉
