import 'package:chat_app/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/widgets/user_avatar.dart';

class UsersListWidget extends StatefulWidget {
  final void Function(List<String> selectedUserIds) onUsersSelected;
  final bool forGroup;

  const UsersListWidget({
    super.key,
    required this.onUsersSelected,
    required this.forGroup,
  });

  @override
  State<UsersListWidget> createState() => _UsersListWidgetState();
}

class _UsersListWidgetState extends State<UsersListWidget> {
  String? currentUserId;
  final Set<String> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    currentUserId = AuthService().getCurrentUserId()!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildUsersList()),
        if (widget.forGroup && _selectedUserIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onUsersSelected(_selectedUserIds.toList());
              },
              child: const Text('ساخت گروه'),
            ),
          ),
      ],
    );
  }

  Widget _buildUsersList() {
    return FutureBuilder<List>(
      future: FirestoreService().getUsers(excludeUserId: currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildCenteredMessage('خطا در دریافت اطلاعات کاربران');
        }

        final users = snapshot.data;
        if (users == null || users.isEmpty) {
          return _buildCenteredMessage('کاربری یافت نشد', color: Colors.grey);
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userId = user.userId;
            final fullName = '${user.firstName} ${user.lastName}';

            return buildUserListItem(userId, fullName);
          },
        );
      },
    );
  }

  Widget buildUserListItem(String userId, String fullName) {
    if (widget.forGroup) {
      return buildUserTileForGroup(userId, fullName);
    } else {
      return buildUserTileForMessage(userId, fullName);
    }
  }

  Widget buildUserTileForGroup(String userId, String fullName) {
    final isSelected = _selectedUserIds.contains(userId);
    return ListTile(
      leading: UserAvatar(name: fullName),
      title: Text(fullName),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() {
          isSelected
              ? _selectedUserIds.remove(userId)
              : _selectedUserIds.add(userId);
        });
      },
    );
  }

  Widget buildUserTileForMessage(String userId, String fullName) {
    return ListTile(
      leading: UserAvatar(name: fullName),
      title: Text(fullName),
      subtitle: Text('Online', style: TextStyle(color: Colors.grey[600])),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatScreen(
                  chatName: fullName,
                  participantIds: [currentUserId!, userId],
                  chatType: ChatType.direct,
                ),
          ),
        );
      },
    );
  }

  Widget _buildCenteredMessage(String message, {Color color = Colors.red}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: TextStyle(color: color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
