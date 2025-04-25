import 'package:flutter/material.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/services/firestore_service.dart';

class ChatItem extends StatelessWidget {
  final Chat chatItem;
  final currentUserId = 'zIWl7N0WeYSlmFhSJjWtAEkYYAg1';

  const ChatItem({super.key, required this.chatItem});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<String>(
      future: _getChatName(),
      builder: (context, snapshot) {
        return ListTile(
          leading: UserAvatar(
            name: snapshot.connectionState == ConnectionState.waiting ? "?": snapshot.data!,
            avatarUrl: chatItem.imageUrl,
          ),
          title: Text(
            snapshot.connectionState == ConnectionState.waiting ? "...": snapshot.data!,
            style: TextStyle(
              color: colorScheme.onPrimary,
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
    if (chatItem.name != null) return chatItem.name!;

    final otherIds =
        chatItem.participants.where((id) => id != currentUserId).toList();

    if (otherIds.isEmpty) return 'You';

    final userFutures =
        otherIds.map((id) => FirestoreService().getUser(id)).toList();
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
}
