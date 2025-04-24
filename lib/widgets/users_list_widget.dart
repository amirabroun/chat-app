import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/components/my_button.dart';

class UsersListWidget extends StatefulWidget {
  const UsersListWidget({super.key});

  @override
  State<UsersListWidget> createState() => _UsersListWidgetState();
}

class _UsersListWidgetState extends State<UsersListWidget> {
  late Future<List<DocumentSnapshot>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsersData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildUsersFutureBuilder()],
    );
  }

  Future<List<DocumentSnapshot>> _fetchUsersData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    return snapshot.docs.where((doc) => doc.id != currentUser?.uid).toList();
  }

  Widget _buildUsersFutureBuilder() {
    return FutureBuilder(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('کاربری یافت نشد.');
        }

        return _buildUsersListView(snapshot.data!);
      },
    );
  }

  Widget _buildUsersListView(List<DocumentSnapshot> users) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _buildUserListItem(users[index]);
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot user) {
    final userData = user.data() as Map<String, dynamic>;

    return ListTile(
      leading: const Icon(Icons.person_outline),
      title: Text(userData['fullName'] ?? 'بدون نام'),
      subtitle: Text(userData['email'] ?? 'بدون ایمیل'),
      trailing: _buildUserAdminStatus(user, userData),
    );
  }

  Widget _buildUserAdminStatus(
    DocumentSnapshot user,
    Map<String, dynamic> userData,
  ) {
    if (userData['isAdmin'] == true) {
      return const Text('ادمین', style: TextStyle(color: Colors.green));
    }

    return MyButton(
      text: 'ادمین کن',
      onPressed: () => _promoteToAdmin(user),
      color: Colors.blue,
      textColor: Colors.white,
    );
  }

  void _promoteToAdmin(DocumentSnapshot user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'isAdmin': true,
      });

      _showSnackBar('ادمین شد');

      setState(() {
        _usersFuture = _fetchUsersData();
      });
    } catch (e) {
      _showSnackBar('خطا در ادمین کردن کاربر: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
