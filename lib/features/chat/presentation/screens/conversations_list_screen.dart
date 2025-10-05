import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/chat_service.dart';
import '../../data/models/message_model.dart';
import 'chat_screen.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  String get currentUserId => _authService.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'Messages',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: currentUserId.isEmpty
          ? Center(
              child: Text(
                'Please login to view messages',
                style: TextStyle(
                  color: AppConstants.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
            )
          : StreamBuilder<List<ConversationModel>>(
              stream: _chatService.getConversationsStream(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppConstants.primaryColor,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: AppConstants.errorColor,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error loading conversations',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final conversations = snapshot.data ?? [];

                if (conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80.sp,
                          color: AppConstants.textSecondary.withOpacity(0.5),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Your chats will appear here',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: AppConstants.backgroundColor,
                  ),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return _buildConversationTile(conversation);
                  },
                );
              },
            ),
    );
  }

  Widget _buildConversationTile(ConversationModel conversation) {
    final otherUserName = conversation.getDisplayName(currentUserId);
    final otherUserImage = conversation.getDisplayImage(currentUserId);
    final unreadCount = conversation.getUnreadCount(currentUserId);
    final hasUnread = unreadCount > 0;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            backgroundImage:
                otherUserImage != null ? NetworkImage(otherUserImage) : null,
            child: otherUserImage == null
                ? Text(
                    otherUserName.isNotEmpty
                        ? otherUserName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  )
                : null,
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: BoxConstraints(
                  minWidth: 20.w,
                  minHeight: 20.h,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        otherUserName,
        style: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: 16.sp,
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Text(
          conversation.displayLastMessage,
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 14.sp,
            color: hasUnread
                ? AppConstants.textPrimary
                : AppConstants.textSecondary,
            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            conversation.formattedLastMessageTime,
            style: TextStyle(
              fontSize: 12.sp,
              color: hasUnread
                  ? AppConstants.primaryColor
                  : AppConstants.textSecondary,
              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (conversation.isJobRelated) ...[
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 10.sp,
                    color: AppConstants.primaryColor,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Job',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
