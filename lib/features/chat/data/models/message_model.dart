import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderProfileImage;
  final String content;
  final String type; // 'text', 'image', 'file', 'system'
  final DateTime sentAt;
  final DateTime? readAt;
  final bool isRead;
  final Map<String, dynamic>? metadata; // For file info, image dimensions, etc.
  final String? replyToMessageId;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderProfileImage,
    required this.content,
    this.type = 'text',
    required this.sentAt,
    this.readAt,
    this.isRead = false,
    this.metadata,
    this.replyToMessageId,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderProfileImage: data['senderProfileImage'],
      content: data['content'] ?? '',
      type: data['type'] ?? 'text',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      isRead: data['isRead'] ?? false,
      metadata: data['metadata'] != null ? Map<String, dynamic>.from(data['metadata']) : null,
      replyToMessageId: data['replyToMessageId'],
      isEdited: data['isEdited'] ?? false,
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderProfileImage': senderProfileImage,
      'content': content,
      'type': type,
      'sentAt': Timestamp.fromDate(sentAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'isRead': isRead,
      'metadata': metadata,
      'replyToMessageId': replyToMessageId,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'isDeleted': isDeleted,
    };
  }

  MessageModel copyWith({
    String? content,
    String? type,
    DateTime? readAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderProfileImage: senderProfileImage,
      content: content ?? this.content,
      type: type ?? this.type,
      sentAt: sentAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // Helper getters
  bool get isUnread => !isRead;
  bool get isTextMessage => type == 'text';
  bool get isImageMessage => type == 'image';
  bool get isFileMessage => type == 'file';
  bool get isSystemMessage => type == 'system';
  bool get hasReply => replyToMessageId != null;
  
  String get formattedTime {
    final now = DateTime.now();
    final messageDate = sentAt;
    
    if (now.day == messageDate.day && 
        now.month == messageDate.month && 
        now.year == messageDate.year) {
      return '${messageDate.hour.toString().padLeft(2, '0')}:${messageDate.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(messageDate).inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[messageDate.weekday - 1];
    } else {
      return '${messageDate.day}/${messageDate.month}/${messageDate.year}';
    }
  }

  String get displayContent {
    if (isDeleted) return 'This message was deleted';
    if (type == 'image') return '📷 Image';
    if (type == 'file') return '📎 ${metadata?['fileName'] ?? 'File'}';
    if (type == 'system') return content;
    return content;
  }

  // Factory methods for different message types
  static MessageModel textMessage({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderProfileImage,
    required String content,
    String? replyToMessageId,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderProfileImage: senderProfileImage,
      content: content,
      type: 'text',
      sentAt: DateTime.now(),
      replyToMessageId: replyToMessageId,
    );
  }

  static MessageModel imageMessage({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderProfileImage,
    required String imageUrl,
    required String fileName,
    required int fileSize,
    int? width,
    int? height,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderProfileImage: senderProfileImage,
      content: imageUrl,
      type: 'image',
      sentAt: DateTime.now(),
      metadata: {
        'fileName': fileName,
        'fileSize': fileSize,
        'width': width,
        'height': height,
      },
    );
  }

  static MessageModel fileMessage({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderProfileImage,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    required String fileType,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderProfileImage: senderProfileImage,
      content: fileUrl,
      type: 'file',
      sentAt: DateTime.now(),
      metadata: {
        'fileName': fileName,
        'fileSize': fileSize,
        'fileType': fileType,
      },
    );
  }

  static MessageModel systemMessage({
    required String id,
    required String conversationId,
    required String content,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: 'system',
      senderName: 'System',
      content: content,
      type: 'system',
      sentAt: DateTime.now(),
    );
  }
}

class ConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantProfileImages;
  final String? lastMessageId;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type; // 'direct', 'group'
  final String? title; // For group conversations
  final String? description;
  final String? groupImageUrl;
  final Map<String, DateTime> lastReadTimestamps; // userId -> timestamp
  final Map<String, int> unreadCounts; // userId -> count
  final bool isActive;
  final String? relatedJobId; // If conversation is about a job
  final String? relatedApplicationId; // If conversation is about an application

  ConversationModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantProfileImages,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    this.type = 'direct',
    this.title,
    this.description,
    this.groupImageUrl,
    this.lastReadTimestamps = const {},
    this.unreadCounts = const {},
    this.isActive = true,
    this.relatedJobId,
    this.relatedApplicationId,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ConversationModel(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      participantProfileImages: Map<String, String?>.from(data['participantProfileImages'] ?? {}),
      lastMessageId: data['lastMessageId'],
      lastMessageContent: data['lastMessageContent'],
      lastMessageSenderId: data['lastMessageSenderId'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'direct',
      title: data['title'],
      description: data['description'],
      groupImageUrl: data['groupImageUrl'],
      lastReadTimestamps: (data['lastReadTimestamps'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as Timestamp).toDate()),
      ) ?? {},
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      isActive: data['isActive'] ?? true,
      relatedJobId: data['relatedJobId'],
      relatedApplicationId: data['relatedApplicationId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantProfileImages': participantProfileImages,
      'lastMessageId': lastMessageId,
      'lastMessageContent': lastMessageContent,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'type': type,
      'title': title,
      'description': description,
      'groupImageUrl': groupImageUrl,
      'lastReadTimestamps': lastReadTimestamps.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
      'unreadCounts': unreadCounts,
      'isActive': isActive,
      'relatedJobId': relatedJobId,
      'relatedApplicationId': relatedApplicationId,
    };
  }

  ConversationModel copyWith({
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String?>? participantProfileImages,
    String? lastMessageId,
    String? lastMessageContent,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
    DateTime? updatedAt,
    String? type,
    String? title,
    String? description,
    String? groupImageUrl,
    Map<String, DateTime>? lastReadTimestamps,
    Map<String, int>? unreadCounts,
    bool? isActive,
    String? relatedJobId,
    String? relatedApplicationId,
  }) {
    return ConversationModel(
      id: id,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantProfileImages: participantProfileImages ?? this.participantProfileImages,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      groupImageUrl: groupImageUrl ?? this.groupImageUrl,
      lastReadTimestamps: lastReadTimestamps ?? this.lastReadTimestamps,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      isActive: isActive ?? this.isActive,
      relatedJobId: relatedJobId ?? this.relatedJobId,
      relatedApplicationId: relatedApplicationId ?? this.relatedApplicationId,
    );
  }

  // Helper getters
  bool get isDirectChat => type == 'direct';
  bool get isGroupChat => type == 'group';
  bool get hasLastMessage => lastMessageId != null;
  bool get isJobRelated => relatedJobId != null;
  bool get isApplicationRelated => relatedApplicationId != null;
  
  String getDisplayName(String currentUserId) {
    if (isGroupChat) {
      return title ?? 'Group Chat';
    }
    
    final otherParticipant = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    
    return participantNames[otherParticipant] ?? 'Unknown User';
  }

  String? getDisplayImage(String currentUserId) {
    if (isGroupChat) {
      return groupImageUrl;
    }
    
    final otherParticipant = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    
    return participantProfileImages[otherParticipant];
  }

  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  bool hasUnreadMessages(String userId) {
    return getUnreadCount(userId) > 0;
  }

  String get formattedLastMessageTime {
    if (lastMessageAt == null) return '';
    
    final now = DateTime.now();
    final messageDate = lastMessageAt!;
    
    if (now.day == messageDate.day && 
        now.month == messageDate.month && 
        now.year == messageDate.year) {
      return '${messageDate.hour.toString().padLeft(2, '0')}:${messageDate.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(messageDate).inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[messageDate.weekday - 1];
    } else {
      return '${messageDate.day}/${messageDate.month}/${messageDate.year}';
    }
  }

  String get displayLastMessage {
    if (lastMessageContent == null || lastMessageContent!.isEmpty) {
      return 'No messages yet';
    }
    
    return lastMessageContent!.length > 50 
        ? '${lastMessageContent!.substring(0, 50)}...'
        : lastMessageContent!;
  }

  // Factory methods
  static ConversationModel createDirectConversation({
    required String id,
    required String user1Id,
    required String user1Name,
    String? user1ProfileImage,
    required String user2Id,
    required String user2Name,
    String? user2ProfileImage,
    String? relatedJobId,
    String? relatedApplicationId,
  }) {
    return ConversationModel(
      id: id,
      participantIds: [user1Id, user2Id],
      participantNames: {
        user1Id: user1Name,
        user2Id: user2Name,
      },
      participantProfileImages: {
        user1Id: user1ProfileImage,
        user2Id: user2ProfileImage,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: 'direct',
      unreadCounts: {
        user1Id: 0,
        user2Id: 0,
      },
      relatedJobId: relatedJobId,
      relatedApplicationId: relatedApplicationId,
    );
  }

  static ConversationModel createGroupConversation({
    required String id,
    required List<String> participantIds,
    required Map<String, String> participantNames,
    required Map<String, String?> participantProfileImages,
    required String title,
    String? description,
    String? groupImageUrl,
  }) {
    return ConversationModel(
      id: id,
      participantIds: participantIds,
      participantNames: participantNames,
      participantProfileImages: participantProfileImages,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: 'group',
      title: title,
      description: description,
      groupImageUrl: groupImageUrl,
      unreadCounts: Map.fromIterable(
        participantIds,
        key: (id) => id,
        value: (_) => 0,
      ),
    );
  }
}