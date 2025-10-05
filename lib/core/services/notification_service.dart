import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/notifications/data/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection references
  CollectionReference get _notificationsCollection => _firestore.collection('notifications');
  CollectionReference get _settingsCollection => _firestore.collection('notificationSettings');
  
  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;
  
  // ==================== CREATE NOTIFICATIONS ====================
  
  /// Create a notification for new job posting
  Future<void> sendJobPostedNotification({
    required String workerId,
    required String jobId,
    required String jobTitle,
    required String businessName,
    required String location,
  }) async {
    try {
      // Check if worker has job postings notifications enabled
      final settings = await getUserNotificationSettings(workerId);
      if (settings != null && !settings.jobPostings) return;
      
      final notificationRef = _notificationsCollection.doc();
      final notification = NotificationModel.jobPosted(
        id: notificationRef.id,
        workerId: workerId,
        jobId: jobId,
        jobTitle: jobTitle,
        businessName: businessName,
        location: location,
      );
      
      await notificationRef.set(notification.toFirestore());
    } catch (e) {
      print('Error sending job posted notification: $e');
    }
  }
  
  /// Create a notification when worker applies for a job
  Future<void> sendJobApplicationNotification({
    required String managerId,
    required String jobId,
    required String applicationId,
    required String workerName,
    required String jobTitle,
  }) async {
    try {
      // Check if manager has application notifications enabled
      final settings = await getUserNotificationSettings(managerId);
      if (settings != null && !settings.applicationUpdates) return;
      
      final notificationRef = _notificationsCollection.doc();
      final notification = NotificationModel.jobApplied(
        id: notificationRef.id,
        managerId: managerId,
        jobId: jobId,
        applicationId: applicationId,
        workerName: workerName,
        jobTitle: jobTitle,
      );
      
      await notificationRef.set(notification.toFirestore());
    } catch (e) {
      print('Error sending job application notification: $e');
    }
  }
  
  /// Create a notification when application status changes
  Future<void> sendApplicationStatusNotification({
    required String workerId,
    required String applicationId,
    required String jobTitle,
    required String businessName,
    required String status, // 'shortlisted', 'accepted', 'rejected'
  }) async {
    try {
      // Check if worker has application updates notifications enabled
      final settings = await getUserNotificationSettings(workerId);
      if (settings != null && !settings.applicationUpdates) return;
      
      final notificationRef = _notificationsCollection.doc();
      final notification = NotificationModel.applicationStatusUpdated(
        id: notificationRef.id,
        workerId: workerId,
        applicationId: applicationId,
        jobTitle: jobTitle,
        businessName: businessName,
        status: status,
      );
      
      await notificationRef.set(notification.toFirestore());
    } catch (e) {
      print('Error sending application status notification: $e');
    }
  }
  
  /// Create a notification for job reminder
  Future<void> sendJobReminderNotification({
    required String workerId,
    required String jobId,
    required String jobTitle,
    required String businessName,
    required DateTime startDate,
  }) async {
    try {
      // Check if worker has job reminders notifications enabled
      final settings = await getUserNotificationSettings(workerId);
      if (settings != null && !settings.jobReminders) return;
      
      final notificationRef = _notificationsCollection.doc();
      final notification = NotificationModel.jobReminder(
        id: notificationRef.id,
        workerId: workerId,
        jobId: jobId,
        jobTitle: jobTitle,
        businessName: businessName,
        startDate: startDate,
      );
      
      await notificationRef.set(notification.toFirestore());
    } catch (e) {
      print('Error sending job reminder notification: $e');
    }
  }
  
  /// Create a notification for new chat message
  Future<void> sendChatMessageNotification({
    required String recipientId,
    required String senderId,
    required String senderName,
    required String message,
    required String conversationId,
  }) async {
    try {
      // Check if recipient has chat messages notifications enabled
      final settings = await getUserNotificationSettings(recipientId);
      if (settings != null && !settings.chatMessages) return;
      
      // Check if conversation is muted
      if (settings != null && settings.mutedConversations.contains(conversationId)) return;
      
      final notificationRef = _notificationsCollection.doc();
      final notification = NotificationModel.chatMessage(
        id: notificationRef.id,
        recipientId: recipientId,
        senderId: senderId,
        senderName: senderName,
        message: message.length > 50 ? '${message.substring(0, 50)}...' : message,
        conversationId: conversationId,
      );
      
      await notificationRef.set(notification.toFirestore());
    } catch (e) {
      print('Error sending chat message notification: $e');
    }
  }
  
  /// Create a system notification
  Future<void> sendSystemNotification({
    required String userId,
    required String title,
    required String message,
    String priority = 'low',
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      // Check if user has system notifications enabled
      final settings = await getUserNotificationSettings(userId);
      if (settings != null && !settings.systemNotifications) return;
      
      final notificationRef = _notificationsCollection.doc();
      final notification = NotificationModel.systemNotification(
        id: notificationRef.id,
        userId: userId,
        title: title,
        message: message,
        priority: priority,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
      );
      
      await notificationRef.set(notification.toFirestore());
    } catch (e) {
      print('Error sending system notification: $e');
    }
  }
  
  // ==================== READ NOTIFICATIONS ====================
  
  /// Get user's notifications stream
  Stream<List<NotificationModel>> getUserNotificationsStream() {
    if (_currentUserId == null) return Stream.value([]);
    
    return _notificationsCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }
  
  /// Get unread notifications count
  Stream<int> getUnreadNotificationsCount() {
    if (_currentUserId == null) return Stream.value(0);
    
    return _notificationsCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
  
  /// Get notifications by type
  Stream<List<NotificationModel>> getNotificationsByType(String type) {
    if (_currentUserId == null) return Stream.value([]);
    
    return _notificationsCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }
  
  // ==================== UPDATE NOTIFICATIONS ====================
  
  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    
    try {
      final unreadNotifications = await _notificationsCollection
          .where('userId', isEqualTo: _currentUserId)
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
  
  // ==================== DELETE NOTIFICATIONS ====================
  
  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
  
  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    if (_currentUserId == null) return;
    
    try {
      final notifications = await _notificationsCollection
          .where('userId', isEqualTo: _currentUserId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }
  
  /// Delete old notifications (older than 30 days)
  Future<void> deleteOldNotifications() async {
    if (_currentUserId == null) return;
    
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final oldNotifications = await _notificationsCollection
          .where('userId', isEqualTo: _currentUserId)
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();
      
      final batch = _firestore.batch();
      for (var doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error deleting old notifications: $e');
    }
  }
  
  // ==================== NOTIFICATION SETTINGS ====================
  
  /// Get user's notification settings
  Future<NotificationSettings?> getUserNotificationSettings(String userId) async {
    try {
      final doc = await _settingsCollection.doc(userId).get();
      if (doc.exists) {
        return NotificationSettings.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting notification settings: $e');
      return null;
    }
  }
  
  /// Get current user's notification settings stream
  Stream<NotificationSettings?> getCurrentUserSettingsStream() {
    if (_currentUserId == null) return Stream.value(null);
    
    return _settingsCollection
        .doc(_currentUserId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return NotificationSettings.fromFirestore(doc);
          }
          return null;
        });
  }
  
  /// Update notification settings
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    if (_currentUserId == null) return;
    
    try {
      await _settingsCollection.doc(_currentUserId).set(
        settings.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error updating notification settings: $e');
    }
  }
  
  /// Initialize default notification settings for new user
  Future<void> initializeNotificationSettings(String userId) async {
    try {
      final settings = NotificationSettings(userId: userId);
      await _settingsCollection.doc(userId).set(settings.toFirestore());
    } catch (e) {
      print('Error initializing notification settings: $e');
    }
  }
  
  /// Mute a conversation
  Future<void> muteConversation(String conversationId) async {
    if (_currentUserId == null) return;
    
    try {
      await _settingsCollection.doc(_currentUserId).update({
        'mutedConversations': FieldValue.arrayUnion([conversationId]),
      });
    } catch (e) {
      print('Error muting conversation: $e');
    }
  }
  
  /// Unmute a conversation
  Future<void> unmuteConversation(String conversationId) async {
    if (_currentUserId == null) return;
    
    try {
      await _settingsCollection.doc(_currentUserId).update({
        'mutedConversations': FieldValue.arrayRemove([conversationId]),
      });
    } catch (e) {
      print('Error unmuting conversation: $e');
    }
  }
}
