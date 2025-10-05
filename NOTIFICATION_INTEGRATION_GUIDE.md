# Notification System Integration Guide

This guide explains how to integrate the notification system into your Partt app.

## Overview

The notification system provides real-time notifications for:
- **New Job Postings** - Workers get notified when new jobs matching their profile are posted
- **Job Applications** - Managers get notified when workers apply to their jobs
- **Application Status Updates** - Workers get notified when their application status changes (shortlisted, accepted, rejected)
- **Chat Messages** - Users get notified of new messages
- **Job Reminders** - Workers get notified about upcoming job starts
- **System Notifications** - Important system-wide announcements

## Files Created

1. **NotificationService** - `lib/core/services/notification_service.dart`
   - Handles all notification CRUD operations
   - Manages notification settings

2. **NotificationsScreen** - `lib/features/notifications/presentation/screens/notifications_screen.dart`
   - UI for viewing and managing notifications

3. **NotificationModel** - Already exists at `lib/features/notifications/data/models/notification_model.dart`

## Integration Steps

### Step 1: Add Notification Icon to AppBars

Add a notification bell icon with badge to your dashboard screens:

```dart
// In manager_dashboard_screen.dart and worker_dashboard_screen.dart
import '../../../../core/services/notification_service.dart';

// Add to AppBar actions
actions: [
  StreamBuilder<int>(
    stream: NotificationService().getUnreadNotificationsCount(),
    builder: (context, snapshot) {
      final unreadCount = snapshot.data ?? 0;
      
      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                constraints: BoxConstraints(
                  minWidth: 18.w,
                  minHeight: 18.h,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    },
  ),
],
```

### Step 2: Send Notifications When Jobs Are Posted

In your job posting screen or service, after successfully creating a job:

```dart
import '../../../core/services/notification_service.dart';

final _notificationService = NotificationService();

// After job is posted successfully
Future<void> _notifyMatchingWorkers(String jobId, JobModel job) async {
  // Get all workers (or filter by location, skills, etc.)
  final workers = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'worker')
      .get();
  
  // Send notification to each worker
  for (var workerDoc in workers.docs) {
    await _notificationService.sendJobPostedNotification(
      workerId: workerDoc.id,
      jobId: jobId,
      jobTitle: job.title,
      businessName: job.businessName,
      location: job.location,
    );
  }
}
```

### Step 3: Send Notifications When Workers Apply

In your job application screen, after a worker successfully applies:

```dart
// After application is created
await _notificationService.sendJobApplicationNotification(
  managerId: job.managerId,
  jobId: jobId,
  applicationId: applicationId,
  workerName: workerName,
  jobTitle: job.title,
);
```

### Step 4: Send Notifications When Application Status Changes

When a manager updates an application status (shortlists, accepts, or rejects):

```dart
// When manager changes application status
await _notificationService.sendApplicationStatusNotification(
  workerId: application.workerId,
  applicationId: application.id,
  jobTitle: job.title,
  businessName: businessName,
  status: newStatus, // 'shortlisted', 'accepted', or 'rejected'
);
```

### Step 5: Send Chat Message Notifications

In your chat service, when a message is sent:

```dart
// After sending a message
await _notificationService.sendChatMessageNotification(
  recipientId: recipientId,
  senderId: currentUserId,
  senderName: currentUserName,
  message: messageText,
  conversationId: conversationId,
);
```

### Step 6: Initialize Notification Settings for New Users

In your profile setup or signup process:

```dart
// After creating user profile
await _notificationService.initializeNotificationSettings(userId);
```

### Step 7: Add Notification Settings to Settings Screen

Create a settings screen or add to existing settings:

```dart
import '../../core/services/notification_service.dart';

class NotificationSettingsScreen extends StatelessWidget {
  final NotificationService _notificationService = NotificationService();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NotificationSettings?>(
      stream: _notificationService.getCurrentUserSettingsStream(),
      builder: (context, snapshot) {
        final settings = snapshot.data;
        if (settings == null) return CircularProgressIndicator();
        
        return ListView(
          children: [
            SwitchListTile(
              title: Text('Job Postings'),
              subtitle: Text('Get notified about new job opportunities'),
              value: settings.jobPostings,
              onChanged: (value) {
                _notificationService.updateNotificationSettings(
                  settings.copyWith(jobPostings: value),
                );
              },
            ),
            SwitchListTile(
              title: Text('Application Updates'),
              subtitle: Text('Get notified about your application status'),
              value: settings.applicationUpdates,
              onChanged: (value) {
                _notificationService.updateNotificationSettings(
                  settings.copyWith(applicationUpdates: value),
                );
              },
            ),
            SwitchListTile(
              title: Text('Chat Messages'),
              subtitle: Text('Get notified about new messages'),
              value: settings.chatMessages,
              onChanged: (value) {
                _notificationService.updateNotificationSettings(
                  settings.copyWith(chatMessages: value),
                );
              },
            ),
            // Add more switches for other notification types
          ],
        );
      },
    );
  }
}
```

## Firestore Security Rules

Add these security rules to your Firestore:

```javascript
// Notifications collection rules
match /notifications/{notificationId} {
  // Users can only read their own notifications
  allow read: if request.auth != null && 
              request.auth.uid == resource.data.userId;
  
  // Any authenticated user can create notifications
  allow create: if request.auth != null;
  
  // Users can only update/delete their own notifications
  allow update, delete: if request.auth != null && 
                          request.auth.uid == resource.data.userId;
}

// Notification settings collection rules
match /notificationSettings/{userId} {
  // Users can only read/write their own settings
  allow read, write: if request.auth != null && 
                       request.auth.uid == userId;
}
```

## Firestore Indexes

Create these composite indexes in Firebase Console:

1. **Notifications by user and time**
   - Collection: `notifications`
   - Fields: `userId` (Ascending), `createdAt` (Descending)

2. **Unread notifications by user**
   - Collection: `notifications`
   - Fields: `userId` (Ascending), `isRead` (Ascending)

3. **Notifications by user and type**
   - Collection: `notifications`
   - Fields: `userId` (Ascending), `type` (Ascending), `createdAt` (Descending)

## Testing the Notification System

### Test New Job Notification
```dart
await _notificationService.sendJobPostedNotification(
  workerId: 'test_worker_id',
  jobId: 'test_job_id',
  jobTitle: 'Part-time Cashier',
  businessName: 'Test Store',
  location: 'New York, NY',
);
```

### Test Application Status Notification
```dart
await _notificationService.sendApplicationStatusNotification(
  workerId: 'test_worker_id',
  applicationId: 'test_app_id',
  jobTitle: 'Part-time Cashier',
  businessName: 'Test Store',
  status: 'accepted',
);
```

### Test Chat Notification
```dart
await _notificationService.sendChatMessageNotification(
  recipientId: 'test_recipient_id',
  senderId: 'test_sender_id',
  senderName: 'John Doe',
  message: 'Hello! Are you available for the shift?',
  conversationId: 'test_conversation_id',
);
```

## Best Practices

1. **Batch Operations**: When notifying multiple users, use Firestore batch writes
2. **Error Handling**: Always wrap notification sends in try-catch blocks
3. **User Preferences**: Always check user notification settings before sending
4. **Rate Limiting**: Avoid sending too many notifications in a short period
5. **Clean Up**: Periodically delete old notifications (30+ days)

## Advanced Features (Optional)

### Push Notifications
To add actual push notifications (not just in-app), integrate Firebase Cloud Messaging (FCM):
- Add FCM dependencies
- Handle FCM tokens
- Send push notifications via Cloud Functions

### Cloud Functions
Create Cloud Functions to automatically send notifications:
```javascript
// Send notification when job is created
exports.onJobCreated = functions.firestore
  .document('jobs/{jobId}')
  .onCreate(async (snap, context) => {
    const job = snap.data();
    // Query matching workers and send notifications
  });
```

## Troubleshooting

### Notifications not appearing
- Check Firestore security rules
- Verify user is authenticated
- Check notification settings are enabled
- Ensure indexes are created

### Unread count not updating
- Verify stream is properly connected
- Check if markAsRead is being called
- Ensure userId matches in notifications

## Support

For issues or questions about the notification system, refer to:
- Firestore documentation
- Flutter StreamBuilder documentation
- Firebase security rules guide
