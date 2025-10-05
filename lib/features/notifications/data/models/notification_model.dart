import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'job_posted', 'job_applied', 'application_status', 'job_reminder', 'system', 'chat'
  final String? relatedId; // jobId, applicationId, etc.
  final Map<String, dynamic>? data; // Additional data based on type
  final bool isRead;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final DateTime createdAt;
  final DateTime? readAt;
  final String? imageUrl;
  final String? actionUrl; // Deep link or route

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    this.data,
    this.isRead = false,
    this.priority = 'medium',
    required this.createdAt,
    this.readAt,
    this.imageUrl,
    this.actionUrl,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'system',
      relatedId: data['relatedId'],
      data: data['data'] != null ? Map<String, dynamic>.from(data['data']) : null,
      isRead: data['isRead'] ?? false,
      priority: data['priority'] ?? 'medium',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'relatedId': relatedId,
      'data': data,
      'isRead': isRead,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  NotificationModel copyWith({
    String? title,
    String? message,
    String? type,
    String? relatedId,
    Map<String, dynamic>? data,
    bool? isRead,
    String? priority,
    DateTime? readAt,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  // Helper getters
  bool get isUnread => !isRead;
  bool get isJobRelated => ['job_posted', 'job_applied', 'application_status', 'job_reminder'].contains(type);
  bool get isChatRelated => type == 'chat';
  bool get isSystemNotification => type == 'system';
  bool get isHighPriority => priority == 'high' || priority == 'urgent';
  
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Factory methods for common notification types
  static NotificationModel jobPosted({
    required String id,
    required String workerId,
    required String jobId,
    required String jobTitle,
    required String businessName,
    required String location,
  }) {
    return NotificationModel(
      id: id,
      userId: workerId,
      title: 'New Job Posted',
      message: '$jobTitle at $businessName in $location',
      type: 'job_posted',
      relatedId: jobId,
      data: {
        'jobId': jobId,
        'jobTitle': jobTitle,
        'businessName': businessName,
        'location': location,
      },
      priority: 'medium',
      createdAt: DateTime.now(),
      actionUrl: '/job-details/$jobId',
    );
  }

  static NotificationModel jobApplied({
    required String id,
    required String managerId,
    required String jobId,
    required String applicationId,
    required String workerName,
    required String jobTitle,
  }) {
    return NotificationModel(
      id: id,
      userId: managerId,
      title: 'New Job Application',
      message: '$workerName applied for $jobTitle',
      type: 'job_applied',
      relatedId: applicationId,
      data: {
        'jobId': jobId,
        'applicationId': applicationId,
        'workerName': workerName,
        'jobTitle': jobTitle,
      },
      priority: 'high',
      createdAt: DateTime.now(),
      actionUrl: '/applications/$applicationId',
    );
  }

  static NotificationModel applicationStatusUpdated({
    required String id,
    required String workerId,
    required String applicationId,
    required String jobTitle,
    required String businessName,
    required String status, // 'shortlisted', 'accepted', 'rejected'
  }) {
    final statusMessages = {
      'shortlisted': 'You have been shortlisted for $jobTitle at $businessName',
      'accepted': 'Congratulations! You have been selected for $jobTitle at $businessName',
      'rejected': 'Your application for $jobTitle at $businessName was not selected',
    };

    final priorities = {
      'shortlisted': 'high',
      'accepted': 'urgent',
      'rejected': 'medium',
    };

    return NotificationModel(
      id: id,
      userId: workerId,
      title: 'Application Update',
      message: statusMessages[status] ?? 'Your application status has been updated',
      type: 'application_status',
      relatedId: applicationId,
      data: {
        'applicationId': applicationId,
        'jobTitle': jobTitle,
        'businessName': businessName,
        'status': status,
      },
      priority: priorities[status] ?? 'medium',
      createdAt: DateTime.now(),
      actionUrl: '/application-details/$applicationId',
    );
  }

  static NotificationModel jobReminder({
    required String id,
    required String workerId,
    required String jobId,
    required String jobTitle,
    required String businessName,
    required DateTime startDate,
  }) {
    final daysUntilStart = startDate.difference(DateTime.now()).inDays;
    String message;
    
    if (daysUntilStart == 0) {
      message = 'Your job at $businessName starts today!';
    } else if (daysUntilStart == 1) {
      message = 'Your job at $businessName starts tomorrow!';
    } else {
      message = 'Your job at $businessName starts in $daysUntilStart days';
    }

    return NotificationModel(
      id: id,
      userId: workerId,
      title: 'Job Reminder',
      message: message,
      type: 'job_reminder',
      relatedId: jobId,
      data: {
        'jobId': jobId,
        'jobTitle': jobTitle,
        'businessName': businessName,
        'startDate': startDate.toIso8601String(),
      },
      priority: daysUntilStart <= 1 ? 'high' : 'medium',
      createdAt: DateTime.now(),
      actionUrl: '/job-details/$jobId',
    );
  }

  static NotificationModel chatMessage({
    required String id,
    required String recipientId,
    required String senderId,
    required String senderName,
    required String message,
    required String conversationId,
  }) {
    return NotificationModel(
      id: id,
      userId: recipientId,
      title: 'New Message',
      message: '$senderName: $message',
      type: 'chat',
      relatedId: conversationId,
      data: {
        'senderId': senderId,
        'senderName': senderName,
        'conversationId': conversationId,
        'messagePreview': message,
      },
      priority: 'medium',
      createdAt: DateTime.now(),
      actionUrl: '/chat/$conversationId',
    );
  }

  static NotificationModel systemNotification({
    required String id,
    required String userId,
    required String title,
    required String message,
    String priority = 'low',
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: 'system',
      priority: priority,
      createdAt: DateTime.now(),
      imageUrl: imageUrl,
      actionUrl: actionUrl,
    );
  }
}

// Notification Settings Model
class NotificationSettings {
  final String userId;
  final bool jobPostings;
  final bool applicationUpdates;
  final bool jobReminders;
  final bool chatMessages;
  final bool systemNotifications;
  final bool pushNotifications;
  final bool emailNotifications;
  final String quietHoursStart; // "22:00"
  final String quietHoursEnd; // "08:00"
  final List<String> mutedConversations;

  NotificationSettings({
    required this.userId,
    this.jobPostings = true,
    this.applicationUpdates = true,
    this.jobReminders = true,
    this.chatMessages = true,
    this.systemNotifications = true,
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.mutedConversations = const [],
  });

  factory NotificationSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NotificationSettings(
      userId: doc.id,
      jobPostings: data['jobPostings'] ?? true,
      applicationUpdates: data['applicationUpdates'] ?? true,
      jobReminders: data['jobReminders'] ?? true,
      chatMessages: data['chatMessages'] ?? true,
      systemNotifications: data['systemNotifications'] ?? true,
      pushNotifications: data['pushNotifications'] ?? true,
      emailNotifications: data['emailNotifications'] ?? false,
      quietHoursStart: data['quietHoursStart'] ?? '22:00',
      quietHoursEnd: data['quietHoursEnd'] ?? '08:00',
      mutedConversations: List<String>.from(data['mutedConversations'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'jobPostings': jobPostings,
      'applicationUpdates': applicationUpdates,
      'jobReminders': jobReminders,
      'chatMessages': chatMessages,
      'systemNotifications': systemNotifications,
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'mutedConversations': mutedConversations,
    };
  }

  NotificationSettings copyWith({
    bool? jobPostings,
    bool? applicationUpdates,
    bool? jobReminders,
    bool? chatMessages,
    bool? systemNotifications,
    bool? pushNotifications,
    bool? emailNotifications,
    String? quietHoursStart,
    String? quietHoursEnd,
    List<String>? mutedConversations,
  }) {
    return NotificationSettings(
      userId: userId,
      jobPostings: jobPostings ?? this.jobPostings,
      applicationUpdates: applicationUpdates ?? this.applicationUpdates,
      jobReminders: jobReminders ?? this.jobReminders,
      chatMessages: chatMessages ?? this.chatMessages,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      mutedConversations: mutedConversations ?? this.mutedConversations,
    );
  }

  bool isInQuietHours() {
    final now = TimeOfDay.now();
    final startTime = _parseTime(quietHoursStart);
    final endTime = _parseTime(quietHoursEnd);
    
    if (startTime.hour > endTime.hour || 
        (startTime.hour == endTime.hour && startTime.minute > endTime.minute)) {
      // Quiet hours span midnight
      return (now.hour > startTime.hour || (now.hour == startTime.hour && now.minute >= startTime.minute)) ||
             (now.hour < endTime.hour || (now.hour == endTime.hour && now.minute < endTime.minute));
    } else {
      // Quiet hours within same day
      return (now.hour > startTime.hour || (now.hour == startTime.hour && now.minute >= startTime.minute)) &&
             (now.hour < endTime.hour || (now.hour == endTime.hour && now.minute < endTime.minute));
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  static TimeOfDay now() {
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }
}