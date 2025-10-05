import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/chat/data/models/message_model.dart';
import '../helpers/notification_integration_helper.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get existing conversation
  Future<ConversationModel> createOrGetConversation({
    required String user1Id,
    required String user1Name,
    String? user1ProfileImage,
    required String user2Id,
    required String user2Name,
    String? user2ProfileImage,
    String? relatedJobId,
    String? relatedApplicationId,
  }) async {
    try {
      // Create conversation ID by sorting user IDs (ensures same ID regardless of who initiates)
      final sortedIds = [user1Id, user2Id]..sort();
      final conversationId = '${sortedIds[0]}_${sortedIds[1]}';

      // Check if conversation already exists
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (conversationDoc.exists) {
        return ConversationModel.fromFirestore(conversationDoc);
      }

      // Create new conversation
      final newConversation = ConversationModel.createDirectConversation(
        id: conversationId,
        user1Id: user1Id,
        user1Name: user1Name,
        user1ProfileImage: user1ProfileImage,
        user2Id: user2Id,
        user2Name: user2Name,
        user2ProfileImage: user2ProfileImage,
        relatedJobId: relatedJobId,
        relatedApplicationId: relatedApplicationId,
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .set(newConversation.toFirestore());

      return newConversation;
    } catch (e) {
      print('Error creating conversation: $e');
      rethrow;
    }
  }

  // Send a text message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderProfileImage,
    required String receiverId,
    required String content,
  }) async {
    try {
      // Create message
      final messageRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();

      final message = MessageModel.textMessage(
        id: messageRef.id,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderProfileImage: senderProfileImage,
        content: content,
      );

      // Save message
      await messageRef.set(message.toFirestore());

      // Update conversation with last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessageId': message.id,
        'lastMessageContent': content,
        'lastMessageSenderId': senderId,
        'lastMessageAt': Timestamp.fromDate(message.sentAt),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'unreadCounts.$receiverId': FieldValue.increment(1),
      });
      
      // Send notification to receiver
      await NotificationIntegrationHelper.notifyUserAboutChatMessage(
        recipientId: receiverId,
        senderId: senderId,
        senderName: senderName,
        message: content,
        conversationId: conversationId,
      );
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages stream for a conversation
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get user's conversations stream
  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList();
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCounts.$userId': 0,
      });
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Send system message (e.g., "Application accepted")
  Future<void> sendSystemMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final messageRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();

      final message = MessageModel.systemMessage(
        id: messageRef.id,
        conversationId: conversationId,
        content: content,
      );

      await messageRef.set(message.toFirestore());

      // Update conversation
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessageId': message.id,
        'lastMessageContent': content,
        'lastMessageSenderId': 'system',
        'lastMessageAt': Timestamp.fromDate(message.sentAt),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error sending system message: $e');
    }
  }
}
