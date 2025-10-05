import '../../../core/services/chat_service.dart';
import '../../auth/data/models/user_model.dart';

class ChatHelper {
  static final ChatService _chatService = ChatService();

  /// Creates a conversation when manager accepts worker's application
  /// Call this function when the application is accepted
  static Future<String> activateChatForAcceptedApplication({
    required String managerId,
    required String managerName,
    String? managerProfileImage,
    required String workerId,
    required String workerName,
    String? workerProfileImage,
    required String jobId,
    required String applicationId,
    String? jobTitle,
  }) async {
    try {
      // Create or get conversation
      final conversation = await _chatService.createOrGetConversation(
        user1Id: managerId,
        user1Name: managerName,
        user1ProfileImage: managerProfileImage,
        user2Id: workerId,
        user2Name: workerName,
        user2ProfileImage: workerProfileImage,
        relatedJobId: jobId,
        relatedApplicationId: applicationId,
      );

      // Send system message about acceptance
      await _chatService.sendSystemMessage(
        conversationId: conversation.id,
        content: jobTitle != null
            ? '🎉 Application accepted for "$jobTitle"! You can now chat with each other.'
            : '🎉 Application accepted! You can now chat with each other.',
      );

      return conversation.id;
    } catch (e) {
      print('Error activating chat: $e');
      rethrow;
    }
  }

  /// Helper to open chat from anywhere in the app
  static Future<String> getOrCreateDirectChat({
    required String currentUserId,
    required String currentUserName,
    String? currentUserProfileImage,
    required String otherUserId,
    required String otherUserName,
    String? otherUserProfileImage,
  }) async {
    try {
      final conversation = await _chatService.createOrGetConversation(
        user1Id: currentUserId,
        user1Name: currentUserName,
        user1ProfileImage: currentUserProfileImage,
        user2Id: otherUserId,
        user2Name: otherUserName,
        user2ProfileImage: otherUserProfileImage,
      );

      return conversation.id;
    } catch (e) {
      print('Error creating chat: $e');
      rethrow;
    }
  }
}
