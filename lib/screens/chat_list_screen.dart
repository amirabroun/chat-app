import 'package:flutter/material.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_item.dart';
import 'package:chat_app/widgets/users_list_widget.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;

  const ChatListScreen({super.key, required this.currentUserId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildChatListBody(),
      drawer: _buildDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showParticipantsList,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.group),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(backgroundColor: Theme.of(context).colorScheme.primary);
  }

  Widget _buildChatListBody() {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: _buildChatStream(),
    );
  }

  Widget _buildChatStream() {
    return StreamBuilder<List<Chat>>(
      stream: FirestoreService().getUserChatsStream(
        userId: widget.currentUserId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return _buildEmptyState();
        }

        final chats = snapshot.data!;
        return _buildChatList(chats);
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(child: Text('Error: $error'));
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('There is no message yet!'));
  }

  Widget _buildChatList(List<Chat> chats) {
    if (chats.isEmpty) {
      return _buildEmptyChatsState();
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder:
          (context, index) => ChatItem(
            chatItem: chats[index],
            currentUserId: widget.currentUserId,
          ),
    );
  }

  Widget _buildEmptyChatsState() {
    return const Center(child: Text('No chats yet! Start a conversation'));
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 350,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: _navigateToProfile,
          ),
        ],
      ),
    );
  }

  void _showParticipantsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: UsersListWidget(),
        );
      },
    );
  }

  void _navigateToProfile() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }
}
