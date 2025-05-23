import 'package:flutter/material.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/models/chat_model.dart';

class ChatItem extends StatefulWidget {
  final Chat chatItem;
  final String currentUserId;

  const ChatItem({
    super.key,
    required this.chatItem,
    required this.currentUserId,
  });

  @override
  State<ChatItem> createState() => _ChatItem();
}

class _ChatItem extends State<ChatItem> {
  Chat? chatItem;
  String? chatName;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    chatItem = widget.chatItem;
    currentUserId = widget.currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getChatName(),
      builder: (context, snapshot) {
        // This is temperery
        if (!snapshot.hasData) {
          return Center();
        }
        chatName = snapshot.data;

        return ListTile(
          onTap: _navigateToChatScreen,
          leading: UserAvatar(
            name: snapshot.data!,
            avatarUrl: chatItem!.imageUrl,
          ),
          title: Text(
            snapshot.data!,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _getLastMessagePreview(),
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(color: Colors.grey),
          ),
          trailing: Text(
            _getMessageTimestamp(),
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }

  Future<String> _getChatName() async {
    if (chatItem!.name != null) return chatItem!.name!;

    final otherIds =
        chatItem!.participants.where((id) => id != currentUserId).toList();

    if (otherIds.isEmpty) return 'You';

    final userFutures =
        otherIds.map((id) => FirestoreService().getUser(userId: id)).toList();
    final users = await Future.wait(userFutures);

    return users.map((user) => '${user.firstName} ${user.lastName}').join(', ');
  }

  String _getLastMessagePreview() {
    final lastMessage = chatItem!.lastMessage;
    if (lastMessage == null) return 'No messages yet';
    return '${lastMessage['sender_id'] == currentUserId ? 'You: ' : ''} ${lastMessage['text']}';
  }

  String _getMessageTimestamp() {
    final now = DateTime.now();
    final time = chatItem!.updatedAt;
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    }
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToChatScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              chatName: chatName!,
              chatId: chatItem?.chatId,
              chatType: chatItem?.type,
            ),
      ),
    );
  }
}
