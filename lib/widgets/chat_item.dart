import 'package:flutter/material.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:chat_app/models/chat_model.dart';

class ChatItem extends StatelessWidget {
  final Chat chatItem;
  final currentUserId = 'zIWl7N0WeYSlmFhSJjWtAEkYYAg1';

  const ChatItem({super.key, required this.chatItem});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: UserAvatar(name: chatItem.name ?? _getParticipantNames(), avatarUrl: chatItem.imageUrl),
      title: Text(
        chatItem.name ?? _getParticipantNames(),
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
  }

  String _getParticipantNames() {
    final otherParticipants = chatItem.participants
        .where((id) => id != currentUserId)
        .join(', ');
    return otherParticipants.isNotEmpty ? otherParticipants : 'You';
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
