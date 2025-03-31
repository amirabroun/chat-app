import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  final List<ChatItemData> chatItems;

  const ChatListScreen({super.key, required this.chatItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Chats"),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: chatItems.length,
        itemBuilder: (context, index) {
          return ChatItem(chatItem: chatItems[index]);
        },
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final ChatItemData chatItem;

  const ChatItem({super.key, required this.chatItem});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(chatItem.avatarUrl)),
      title: Text(
        chatItem.name,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chatItem.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Text(
        chatItem.time,
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        // Navigate to chat screen
      },
    );
  }
}

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
