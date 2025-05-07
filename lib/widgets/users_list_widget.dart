import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/widgets/user_avatar.dart';

class UsersListWidget extends StatefulWidget {
  const UsersListWidget({super.key});

  @override
  State<UsersListWidget> createState() => _UsersListWidgetState();
}

class _UsersListWidgetState extends State<UsersListWidget> {
  late Future<List> _usersFuture;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentUserId = _authService.getCurrentUserId()!;
      _usersFuture = _firestoreService.getUsers(excludeUserId: currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildUsersList();
  }

  Widget _buildUsersList() {
    return FutureBuilder<List>(
      future: _usersFuture,
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            return ListTile(
              leading: UserAvatar(name: '${user.firstName} ${user.lastName}'),
              title: Text('${user.firstName} ${user.lastName}'),
              subtitle: Text(
                'Online',
                style: TextStyle(color: Colors.grey[600]),
              ),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChatScreen(
                          chatName: '${user.firstName} ${user.lastName}',
                          participantIds: [currentUserId!, user.userId],
                        ),
                  ),
                );
              },
            );
          },
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
