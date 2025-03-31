import 'dart:math';
import 'package:flutter/material.dart';

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
      leading: _buildAvatar(chatItem.name, chatItem.avatarUrl),
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

// generate an avatar
Widget _buildAvatar(String name, String? avatarUrl) {
  return CircleAvatar(
    backgroundColor: _getRandomColor(name),
    child:
        avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
              avatarUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackText(name);
              },
            )
            : _buildFallbackText(name),
  );
}

// extract first letter of name
Widget _buildFallbackText(String name) {
  return Text(
    name.isNotEmpty ? name[0].toUpperCase() : "?",
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
}

// generate random colors based on name
Color _getRandomColor(String name) {
  final random = Random(name.hashCode);
  return Color.fromARGB(
    255,
    100 + random.nextInt(156),
    100 + random.nextInt(156),
    100 + random.nextInt(156),
  );
}
