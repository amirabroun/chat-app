import 'package:flutter/material.dart';
import 'package:chat_app/widgets/chat_item.dart';
import 'package:chat_app/widgets/user_avatar.dart';

class ChatListScreen extends StatelessWidget {
  final List<ChatItemData> chatItems;

  const ChatListScreen({super.key, required this.chatItems});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("My Chats"),
        backgroundColor: colorScheme.secondary,
      ),
      body: Container(
        decoration: BoxDecoration(color: colorScheme.primary),
        child: ListView.builder(
          itemCount: chatItems.length,
          itemBuilder: (context, index) {
            return ChatItem(chatItem: chatItems[index]);
          },
        ),
      ),
      drawer: Drawer(
        width: 350,
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.secondary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    name: 'username placeholder',
                    avatarUrl: "https://example.com/avatar.jpg",
                  ),
                  Text(
                    'username placeholder',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
