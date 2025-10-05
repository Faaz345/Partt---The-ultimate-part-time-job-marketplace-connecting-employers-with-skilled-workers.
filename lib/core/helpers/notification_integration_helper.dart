import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import '../../features/notifications/data/models/notification_model.dart';

/// Helper class for easy notification integration across the app
class NotificationIntegrationHelper {
  static final NotificationService _notificationService = NotificationService();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // ==================== JOB POSTING NOTIFICATIONS ====================
  
  /// Send notifications to all workers when a new job is posted
  /// Call this after successfully creating a job
  static Future<void> notifyWorkersAboutNewJob({
    required String jobId,
    required String jobTitle,
    required String businessName,
    required String location,
    List<String>? specificWorkerIds, // Optional: target specific workers
  }) async {
    try {
      print('Sending job posted notifications...');
      
      Query<Map<String, dynamic>> workersQuery = _firestore
          .collection('users')
          .where('role', isEqualTo: 'worker');
      
      // If specific workers are provided, filter by those IDs
      if (specificWorkerIds != null && specificWorkerIds.isNotEmpty) {
        // Note: 'whereIn' has a limit of 10 items
        if (specificWorkerIds.length <= 10) {
          workersQuery = workersQuery.where(FieldPath.documentId, whereIn: specificWorkerIds);
        }
      }
      
      final workersSnapshot = await workersQuery.get();
      
      print('Found ${workersSnapshot.docs.length} workers to notify');
      
      // Send notification to each worker
      for (var workerDoc in workersSnapshot.docs) {
        await _notificationService.sendJobPostedNotification(
          workerId: workerDoc.id,
          jobId: jobId,
          jobTitle: jobTitle,
          businessName: businessName,
          location: location,
        );
      }
      
      print('Notifications sent successfully');
    } catch (e) {
      print('Error sending job posted notifications: $e');
    }
  }
  
  // ==================== JOB APPLICATION NOTIFICATIONS ====================
  
  /// Send notification to manager when a worker applies
  /// Call this after successfully creating a job application
  static Future<void> notifyManagerAboutApplication({
    required String managerId,
    required String jobId,
    required String applicationId,
    required String workerName,
    required String jobTitle,
  }) async {
    try {
      await _notificationService.sendJobApplicationNotification(
        managerId: managerId,
        jobId: jobId,
        applicationId: applicationId,
        workerName: workerName,
        jobTitle: jobTitle,
      );
      print('Manager notified about new application');
    } catch (e) {
      print('Error notifying manager about application: $e');
    }
  }
  
  // ==================== APPLICATION STATUS NOTIFICATIONS ====================
  
  /// Send notification to worker when application status changes
  /// Call this after updating an application status
  static Future<void> notifyWorkerAboutApplicationStatus({
    required String workerId,
    required String applicationId,
    required String jobTitle,
    required String businessName,
    required String status, // 'shortlisted', 'accepted', 'rejected'
  }) async {
    try {
      await _notificationService.sendApplicationStatusNotification(
        workerId: workerId,
        applicationId: applicationId,
        jobTitle: jobTitle,
        businessName: businessName,
        status: status,
      );
      print('Worker notified about application status: $status');
    } catch (e) {
      print('Error notifying worker about application status: $e');
    }
  }
  
  // ==================== CHAT MESSAGE NOTIFICATIONS ====================
  
  /// Send notification when a new chat message is sent
  /// Call this after sending a chat message
  static Future<void> notifyUserAboutChatMessage({
    required String recipientId,
    required String senderId,
    required String senderName,
    required String message,
    required String conversationId,
  }) async {
    try {
      // Don't send notification to yourself
      if (recipientId == senderId) return;
      
      await _notificationService.sendChatMessageNotification(
        recipientId: recipientId,
        senderId: senderId,
        senderName: senderName,
        message: message,
        conversationId: conversationId,
      );
      print('Chat notification sent to recipient');
    } catch (e) {
      print('Error sending chat notification: $e');
    }
  }
  
  // ==================== USER INITIALIZATION ====================
  
  /// Initialize notification settings for a new user
  /// Call this during signup or profile setup
  static Future<void> initializeUserNotificationSettings(String userId) async {
    try {
      await _notificationService.initializeNotificationSettings(userId);
      print('Notification settings initialized for user: $userId');
    } catch (e) {
      print('Error initializing notification settings: $e');
    }
  }
  
  // ==================== BATCH NOTIFICATIONS ====================
  
  /// Send notifications to multiple workers efficiently using batches
  static Future<void> batchNotifyWorkers({
    required List<String> workerIds,
    required String jobId,
    required String jobTitle,
    required String businessName,
    required String location,
  }) async {
    try {
      // Process in batches of 10 (Firestore limit)
      final batchSize = 10;
      for (var i = 0; i < workerIds.length; i += batchSize) {
        final end = (i + batchSize < workerIds.length) ? i + batchSize : workerIds.length;
        final batch = workerIds.sublist(i, end);
        
        await Future.wait(
          batch.map((workerId) => _notificationService.sendJobPostedNotification(
            workerId: workerId,
            jobId: jobId,
            jobTitle: jobTitle,
            businessName: businessName,
            location: location,
          )),
        );
      }
      print('Batch notifications sent to ${workerIds.length} workers');
    } catch (e) {
      print('Error sending batch notifications: $e');
    }
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Get current user's notification settings
  static Future<NotificationSettings?> getCurrentUserSettings() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    
    return await _notificationService.getUserNotificationSettings(userId);
  }
  
  /// Check if user has specific notification type enabled
  static Future<bool> isNotificationTypeEnabled(String notificationType) async {
    final settings = await getCurrentUserSettings();
    if (settings == null) return true; // Default to enabled
    
    switch (notificationType) {
      case 'job_posted':
        return settings.jobPostings;
      case 'application_status':
        return settings.applicationUpdates;
      case 'chat':
        return settings.chatMessages;
      case 'system':
        return settings.systemNotifications;
      default:
        return true;
    }
  }
  
  /// Mark all notifications as read for current user
  static Future<void> markAllNotificationsAsRead() async {
    await _notificationService.markAllAsRead();
  }
  
  /// Delete old notifications (30+ days old)
  static Future<void> cleanupOldNotifications() async {
    await _notificationService.deleteOldNotifications();
  }
  
  // ==================== EXAMPLE USAGE ====================
  
  /*
  
  // Example 1: After posting a job
  await NotificationIntegrationHelper.notifyWorkersAboutNewJob(
    jobId: createdJobId,
    jobTitle: 'Part-time Cashier',
    businessName: 'ABC Store',
    location: 'New York, NY',
  );
  
  // Example 2: After worker applies for a job
  await NotificationIntegrationHelper.notifyManagerAboutApplication(
    managerId: job.managerId,
    jobId: jobId,
    applicationId: applicationId,
    workerName: currentUserName,
    jobTitle: job.title,
  );
  
  // Example 3: After manager updates application status
  await NotificationIntegrationHelper.notifyWorkerAboutApplicationStatus(
    workerId: application.workerId,
    applicationId: application.id,
    jobTitle: job.title,
    businessName: businessName,
    status: 'accepted', // or 'shortlisted', 'rejected'
  );
  
  // Example 4: After sending a chat message
  await NotificationIntegrationHelper.notifyUserAboutChatMessage(
    recipientId: otherUserId,
    senderId: currentUserId,
    senderName: currentUserName,
    message: messageText,
    conversationId: conversationId,
  );
  
  // Example 5: During user signup
  await NotificationIntegrationHelper.initializeUserNotificationSettings(newUserId);
  
  */
}
