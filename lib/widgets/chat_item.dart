import 'package:flutter/material.dart';
import 'package:chat_app/widgets/user_avatar.dart';

class ChatItemData {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;

  ChatItemData({
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
  });
}

class ChatItem extends StatelessWidget {
  final ChatItemData chatItem;

  const ChatItem({super.key, required this.chatItem});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: UserAvatar(name: chatItem.name, avatarUrl: chatItem.avatarUrl),
      title: Text(
        chatItem.name,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        chatItem.message,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Text(chatItem.time, style: TextStyle(color: Colors.grey)),
    );
  }
}
