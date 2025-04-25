import 'package:flutter/material.dart';
import 'package:chat_app/widgets/chat_item.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/models/chat_model.dart';

class ChatListScreen extends StatelessWidget {
  final currentUserId = 'zIWl7N0WeYSlmFhSJjWtAEkYYAg1';

  const ChatListScreen({super.key});

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
        child: StreamBuilder<List<Chat>>(
          stream: FirestoreService().getUserChatsStream(currentUserId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final chats = snapshot.data!;

            if (chats.isEmpty) {
              return const Center(child: Text('No chats yet! Start a conversation'));
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) => ChatItem(chatItem: chats[index])
            );
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
