# Chat Feature Integration Guide

## ✅ What's Been Implemented

1. **ChatService** - Handles all messaging operations
2. **ChatScreen** - WhatsApp-style UI for messaging
3. **ChatHelper** - Easy-to-use helper functions

## 🚀 How to Use

### 1. When Manager Accepts Application

Add this code where you handle application acceptance:

```dart
import 'package:partt/features/chat/utils/chat_helper.dart';

// When manager clicks "Accept Application"
Future<void> _acceptApplication() async {
  // ... your existing acceptance logic ...
  
  // Activate chat
  final conversationId = await ChatHelper.activateChatForAcceptedApplication(
    managerId: managerUserId,
    managerName: managerUserName,
    managerProfileImage: managerUserPhoto,
    workerId: workerUserId,
    workerName: workerUserName,
    workerProfileImage: workerUserPhoto,
    jobId: jobId,
    applicationId: applicationId,
    jobTitle: 'Waiter Position', // optional
  );
  
  print('Chat activated! Conversation ID: $conversationId');
}
```

### 2. Show Chat List (All Conversations)

Add this to your dashboard navigation:

```dart
import 'package:partt/features/chat/presentation/screens/conversations_list_screen.dart';

// Navigate to chat list
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ConversationsListScreen(),
  ),
);

// Or add as a navigation item
BottomNavigationBarItem(
  icon: Icon(Icons.chat_bubble_outline),
  label: 'Messages',
),
```

### 3. Open Specific Chat Screen

To navigate directly to a chat:

```dart
import 'package:partt/features/chat/presentation/screens/chat_screen.dart';
import 'package:partt/core/services/chat_service.dart';

// Get the conversation first
final chatService = ChatService();
final conversation = await chatService.createOrGetConversation(
  user1Id: currentUserId,
  user1Name: currentUserName,
  user2Id: otherUserId,
  user2Name: otherUserName,
);

// Navigate to chat
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatScreen(conversation: conversation),
  ),
);
```

### 4. Add Chat Button to Worker/Manager Profile

Example for showing a chat button:

```dart
ElevatedButton.icon(
  onPressed: () async {
    // Create or get conversation
    final chatService = ChatService();
    final conversation = await chatService.createOrGetConversation(
      user1Id: currentUser.id,
      user1Name: currentUser.fullName,
      user1ProfileImage: currentUser.profileImage,
      user2Id: otherUser.id,
      user2Name: otherUser.fullName,
      user2ProfileImage: otherUser.profileImage,
    );
    
    // Open chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversation: conversation),
      ),
    );
  },
  icon: Icon(Icons.chat),
  label: Text('Message'),
)
```

## 📱 Features Included

✅ Real-time messaging
✅ WhatsApp-style message bubbles  
✅ System messages (for acceptance notifications)
✅ Message timestamps
✅ Auto-mark messages as read
✅ Message history (last 50 messages)
✅ **Chat list screen** (see all conversations)
✅ **Unread message badges**
✅ **Job-related conversation tags**

## 🔧 Firebase Setup Required

Make sure your Firestore has these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participantIds;
      
      match /messages/{messageId} {
        allow read: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participantIds;
        allow create: if request.auth != null &&
          request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participantIds;
      }
    }
  }
}
```

## 🎯 Next Steps (Optional Enhancements)

- [x] ~~Chat list screen (see all conversations)~~ ✅ **DONE!**
- [ ] Image/file sharing
- [ ] Push notifications for new messages
- [ ] Typing indicators
- [ ] Message reactions
- [ ] Delete messages
- [ ] Block users

## ⚠️ Important Notes

1. Chat is automatically created when application is accepted
2. Only participants can see their conversation
3. Messages are stored in Firestore under `conversations/{id}/messages`
4. Conversations are stored in `conversations` collection
