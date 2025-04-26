import 'package:flutter/material.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_item.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final currentUserId = 'zIWl7N0WeYSlmFhSJjWtAEkYYAg1';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildChatListBody(),
      drawer: _buildDrawer(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshChats),
      ],
    );
  }

  Widget _buildChatListBody() {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: _buildChatStream(),
    );
  }

  Widget _buildChatStream() {
    return StreamBuilder<List<Chat>>(
      stream: FirestoreService().getUserChatsStream(userId: currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || _isLoading) {
          return _buildLoadingState();
        }

        final chats = snapshot.data!;
        return _buildChatList(chats);
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(child: Text('Error: $error'));
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildChatList(List<Chat> chats) {
    if (chats.isEmpty) {
      return _buildEmptyChatsState();
    }

    return RefreshIndicator(
      onRefresh: _refreshChats,
      child: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) => ChatItem(chatItem: chats[index]),
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

  Future<void> _refreshChats() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToProfile() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }
}
