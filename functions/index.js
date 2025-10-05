const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Send FCM push notification when a notification document is created
 * Triggers automatically whenever a new notification is added to Firestore
 */
exports.sendPushNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    try {
      const notification = snap.data();
      const notificationId = context.params.notificationId;
      
      console.log('Processing notification:', notificationId);
      console.log('Notification data:', notification);
      
      // Get user's FCM token
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(notification.userId)
        .get();
      
      if (!userDoc.exists) {
        console.log('User not found:', notification.userId);
        return null;
      }
      
      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;
      
      if (!fcmToken) {
        console.log('No FCM token for user:', notification.userId);
        return null;
      }
      
      // Check if user has notifications enabled
      const settingsDoc = await admin.firestore()
        .collection('notificationSettings')
        .doc(notification.userId)
        .get();
      
      if (settingsDoc.exists) {
        const settings = settingsDoc.data();
        
        // Check if user has this notification type enabled
        const notificationType = notification.type;
        if (notificationType === 'job_posted' && !settings.jobPostings) {
          console.log('Job postings disabled for user');
          return null;
        }
        if ((notificationType === 'job_applied' || notificationType === 'application_status') && !settings.applicationUpdates) {
          console.log('Application updates disabled for user');
          return null;
        }
        if (notificationType === 'chat' && !settings.chatMessages) {
          console.log('Chat messages disabled for user');
          return null;
        }
        if (!settings.pushNotifications) {
          console.log('Push notifications disabled for user');
          return null;
        }
        
        // Check quiet hours
        if (settings.quietHoursStart && settings.quietHoursEnd) {
          const now = new Date();
          const currentHour = now.getHours();
          const currentMinute = now.getMinutes();
          const currentTime = currentHour * 60 + currentMinute;
          
          const [startHour, startMinute] = settings.quietHoursStart.split(':').map(Number);
          const [endHour, endMinute] = settings.quietHoursEnd.split(':').map(Number);
          const startTime = startHour * 60 + startMinute;
          const endTime = endHour * 60 + endMinute;
          
          const isInQuietHours = startTime < endTime
            ? currentTime >= startTime && currentTime < endTime
            : currentTime >= startTime || currentTime < endTime;
          
          if (isInQuietHours) {
            console.log('User is in quiet hours');
            return null;
          }
        }
      }
      
      // Determine notification icon based on type
      let icon = 'ic_launcher';
      let color = '#6750A4';
      
      switch (notification.type) {
        case 'job_posted':
          icon = 'ic_work';
          color = '#6750A4';
          break;
        case 'job_applied':
          icon = 'ic_person_add';
          color = '#00897B';
          break;
        case 'application_status':
          icon = 'ic_assignment';
          color = '#43A047';
          break;
        case 'chat':
          icon = 'ic_chat';
          color = '#1E88E5';
          break;
        case 'job_reminder':
          icon = 'ic_alarm';
          color = '#FB8C00';
          break;
        default:
          icon = 'ic_launcher';
          color = '#6750A4';
      }
      
      // Build notification message
      const message = {
        token: fcmToken,
        notification: {
          title: notification.title,
          body: notification.message,
        },
        data: {
          notificationId: notificationId,
          type: notification.type,
          relatedId: notification.relatedId || '',
          priority: notification.priority || 'medium',
          createdAt: notification.createdAt ? notification.createdAt.toDate().toISOString() : new Date().toISOString(),
        },
        android: {
          priority: notification.priority === 'urgent' || notification.priority === 'high' ? 'high' : 'normal',
          notification: {
            channelId: 'high_importance_channel',
            priority: notification.priority === 'urgent' || notification.priority === 'high' ? 'high' : 'default',
            defaultSound: true,
            defaultVibrateTimings: true,
            color: color,
            icon: icon,
            tag: notification.type, // Group notifications by type
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              category: notification.type,
              'mutable-content': 1,
            },
          },
          headers: {
            'apns-priority': notification.priority === 'urgent' || notification.priority === 'high' ? '10' : '5',
          },
        },
      };
      
      // Send the notification
      const response = await admin.messaging().send(message);
      console.log('✅ Notification sent successfully:', response);
      
      // Update notification document with FCM message ID
      await snap.ref.update({
        fcmMessageId: response,
        fcmSentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return response;
    } catch (error) {
      console.error('❌ Error sending notification:', error);
      
      // If token is invalid, remove it from user document
      if (error.code === 'messaging/invalid-registration-token' ||
          error.code === 'messaging/registration-token-not-registered') {
        console.log('Removing invalid FCM token');
        await admin.firestore()
          .collection('users')
          .doc(notification.userId)
          .update({
            fcmToken: admin.firestore.FieldValue.delete(),
          });
      }
      
      return null;
    }
  });

/**
 * Update badge count when notification read status changes
 */
exports.updateBadgeCount = functions.firestore
  .document('notifications/{notificationId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Only proceed if isRead status changed from false to true
    if (!before.isRead && after.isRead) {
      try {
        // Get unread count
        const unreadSnapshot = await admin.firestore()
          .collection('notifications')
          .where('userId', '==', after.userId)
          .where('isRead', '==', false)
          .get();
        
        const unreadCount = unreadSnapshot.size;
        
        // Get user's FCM token
        const userDoc = await admin.firestore()
          .collection('users')
          .doc(after.userId)
          .get();
        
        if (userDoc.exists) {
          const fcmToken = userDoc.data().fcmToken;
          
          if (fcmToken) {
            // Update badge count on iOS
            await admin.messaging().send({
              token: fcmToken,
              apns: {
                payload: {
                  aps: {
                    badge: unreadCount,
                  },
                },
              },
            });
            
            console.log('✅ Badge count updated:', unreadCount);
          }
        }
      } catch (error) {
        console.error('❌ Error updating badge count:', error);
      }
    }
    
    return null;
  });

/**
 * Send batch notification to multiple users (for job postings)
 */
exports.sendBatchNotification = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { userIds, title, message, type, relatedId, priority } = data;
  
  if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'userIds must be a non-empty array');
  }
  
  try {
    const results = {
      success: 0,
      failed: 0,
      errors: [],
    };
    
    // Process in batches of 500 (FCM limit)
    const batchSize = 500;
    for (let i = 0; i < userIds.length; i += batchSize) {
      const batch = userIds.slice(i, i + batchSize);
      
      // Get FCM tokens for this batch
      const usersSnapshot = await admin.firestore()
        .collection('users')
        .where(admin.firestore.FieldPath.documentId(), 'in', batch)
        .get();
      
      const tokens = [];
      usersSnapshot.forEach(doc => {
        const fcmToken = doc.data().fcmToken;
        if (fcmToken) {
          tokens.push(fcmToken);
        }
      });
      
      if (tokens.length > 0) {
        const multicastMessage = {
          tokens: tokens,
          notification: {
            title: title,
            body: message,
          },
          data: {
            type: type,
            relatedId: relatedId || '',
            priority: priority || 'medium',
          },
        };
        
        const response = await admin.messaging().sendMulticast(multicastMessage);
        results.success += response.successCount;
        results.failed += response.failureCount;
        
        if (response.failureCount > 0) {
          response.responses.forEach((resp, idx) => {
            if (!resp.success) {
              results.errors.push({
                token: tokens[idx].substring(0, 20) + '...',
                error: resp.error?.message,
              });
            }
          });
        }
      }
    }
    
    console.log('✅ Batch notification results:', results);
    return results;
  } catch (error) {
    console.error('❌ Error sending batch notification:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
