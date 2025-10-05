import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/chat_service.dart';
import '../../data/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  String get currentUserId => _authService.currentUser?.uid ?? '';
  
  String get otherUserId {
    return widget.conversation.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  void _markAsRead() {
    if (currentUserId.isNotEmpty) {
      _chatService.markMessagesAsRead(
        conversationId: widget.conversation.id,
        userId: currentUserId,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUserId.isEmpty) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    _chatService.sendMessage(
      conversationId: widget.conversation.id,
      senderId: currentUserId,
      senderName: widget.conversation.participantNames[currentUserId] ?? 'User',
      receiverId: otherUserId,
      content: text,
    );

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherUserName = widget.conversation.getDisplayName(currentUserId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          otherUserName,
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessagesStream(widget.conversation.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet.\nSay hi! 👋',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 16.sp,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(16.w),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    final isSystem = message.isSystemMessage;

                    if (isSystem) {
                      return _buildSystemMessage(message);
                    }

                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 14.sp,
                      ),
                      filled: true,
                      fillColor: AppConstants.backgroundColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                SizedBox(width: 8.w),
                CircleAvatar(
                  backgroundColor: AppConstants.primaryColor,
                  radius: 24.r,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 20.sp),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? AppConstants.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
            bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
          ),
        ),
        constraints: BoxConstraints(maxWidth: 280.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : AppConstants.textPrimary,
                fontSize: 15.sp,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message.formattedTime,
              style: TextStyle(
                color: isMe ? Colors.white70 : AppConstants.textSecondary,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMessage(MessageModel message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        message.content,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.amber.shade900,
          fontSize: 13.sp,
          fontFamily: AppConstants.fontFamily,
        ),
      ),
    );
  }
}
