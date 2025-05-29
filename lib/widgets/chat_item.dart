import 'package:flutter/material.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/models/chat_model.dart';

class ChatItem extends StatelessWidget {
  final Chat chatItem;
  final String currentUserId;

  const ChatItem({
    super.key,
    required this.chatItem,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getChatName(),
      builder: (context, snapshot) {
        // This is temperery
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final chatName = snapshot.data!;

        return StreamBuilder<int>(
          stream: FirestoreService().getUnseenMessageCount(
            chatId: chatItem.chatId,
            userId: currentUserId,
          ),
          builder: (context, unseenSnapshot) {
            final unseenCount = unseenSnapshot.data ?? 0;
            return ListTile(
              onTap: () => _navigateToChatScreen(context, chatName),
              leading: UserAvatar(name: chatName, avatarUrl: chatItem.imageUrl),
              title: Text(
                chatName,
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
              trailing: Column(
                children: [
                  Text(
                    _getMessageTimestamp(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (unseenCount > 0)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unseenCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String> _getChatName() async {
    if (chatItem.name != null) return chatItem.name!;

    final otherIds =
        chatItem.participants.where((id) => id != currentUserId).toList();

    if (otherIds.isEmpty) return 'You';

    final userFutures =
        otherIds.map((id) => FirestoreService().getUser(userId: id)).toList();
    final users = await Future.wait(userFutures);

    return users.map((user) => '${user.firstName} ${user.lastName}').join(', ');
  }

  String _getLastMessagePreview() {
    final lastMessage = chatItem.lastMessage;
    if (lastMessage == null) return 'No messages yet';
    return '${lastMessage['sender_id'] == currentUserId ? 'You: ' : ''} ${lastMessage['text']}';
  }

  String _getMessageTimestamp() {
    final now = DateTime.now();
    final time = chatItem.updatedAt;
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    }
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToChatScreen(BuildContext context, String chatName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              chatName: chatName,
              chatId: chatItem.chatId,
              chatType: chatItem.type,
            ),
      ),
    );
  }
}
