import 'package:flutter/material.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_item.dart';
import 'package:chat_app/widgets/users_list_widget.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/my_button.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;

  const ChatListScreen({super.key, required this.currentUserId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _firestoreService = FirestoreService();
  final _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildChatList(),
      drawer: _buildDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showActionMenu,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder<List<Chat>>(
      stream: _firestoreService.getUserChatsStream(
        userId: widget.currentUserId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('در حال حاضر چتی موجود نیست.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder:
              (_, index) => ChatItem(
                chatItem: snapshot.data![index],
                currentUserId: widget.currentUserId,
              ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 350,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: ListTile(
          leading: const Icon(Icons.person, color: Colors.white),
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ),
        ),
      ),
    );
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(Icons.group, 'ساخت گروه', true),
                  _actionButton(Icons.person, 'ارسال پیام', false),
                ],
              ),
            ),
          ),
    );
  }

  Widget _actionButton(IconData icon, String label, bool isGroup) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 40),
          onPressed: () => _showParticipantsList(isGroup),
        ),
        Text(label),
      ],
    );
  }

  void _showParticipantsList(bool forGroup) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: UsersListWidget(
              forGroup: forGroup,
              onUsersSelected:
                  (selectedIds) => _handleUsersSelection(forGroup, selectedIds),
            ),
          ),
    );
  }

  Future<void> _handleUsersSelection(
    bool forGroup,
    List<String> selectedIds,
  ) async {
    Navigator.pop(context);

    if (forGroup) {
      selectedIds.add(widget.currentUserId);
      _createGroup(selectedIds);
      return;
    }

    final otherUserId = selectedIds.first;
    final user = await _firestoreService.getUser(userId: otherUserId);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatScreen(
              chatName: user.firstName,
              chatType: ChatType.direct,
              participantIds: [widget.currentUserId, otherUserId],
            ),
      ),
    );
  }

  Future<void> _createGroup(List<String> participantIds) async {
    _groupNameController.clear();
    final String? groupName = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('نام گروه'),
            content: MyTextfield(
              label: 'نام گروه',
              controller: _groupNameController,
              icon: const Icon(Icons.group),
            ),
            actions: [
              MyButton(onPressed: () => Navigator.pop(context), text: 'انصراف'),
              MyButton(
                onPressed: () {
                  if (_groupNameController.text.trim().isEmpty) return;
                  Navigator.pop(context, _groupNameController.text.trim());
                },
                text: 'تایید',
              ),
            ],
          ),
    );

    if (groupName == null || groupName.isEmpty) return;

    try {
      final chatId = await _firestoreService.createNewChat(
        participantIds: participantIds,
        type: ChatType.group,
        name: groupName,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ChatScreen(
                chatName: groupName,
                participantIds: participantIds,
                chatId: chatId,
                chatType: ChatType.group,
              ),
        ),
      );
    } catch (e) {
      _showSnackBar('خطا در ساخت گروه');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }
}
