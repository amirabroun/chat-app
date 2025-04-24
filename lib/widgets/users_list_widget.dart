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
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  late Future<List<DocumentSnapshot>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  // Main Build Methods
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildUsersList()],
    );
  }

  // Data Methods
  Future<List<DocumentSnapshot>> _fetchUsers() async {
    final currentUser = _auth.currentUser;
    final snapshot = await _firestore.collection('users').get();

    return snapshot.docs.where((doc) => doc.id != currentUser?.uid).toList();
  }

  Future<void> _promoteToAdmin(DocumentSnapshot user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'isAdmin': true,
        'updated_at': FieldValue.serverTimestamp(),
      });

      _showMessage('کاربر با موفقیت ادمین شد');
    } catch (e) {
      _showMessage('خطا در ادمین کردن کاربر: ${e.toString()}');
    }
  }

  // UI Components
  Widget _buildUsersList() {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطا در دریافت اطلاعات کاربران',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'کاربری یافت نشد',
              style: TextStyle(color: Colors.grey),
            ),
          );
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
      itemBuilder: (context, index) => _buildUserItem(users[index]),
    );
  }

  Widget _buildUserItem(DocumentSnapshot user) {
    final data = user.data() as Map<String, dynamic>;

    return ListTile(
      leading: const Icon(Icons.person_outline),
      title: Text(data['fullName'] ?? 'بدون نام'),
      subtitle: Text(data['email'] ?? 'بدون ایمیل'),
      trailing: _buildAdminAction(user, data),
    );
  }

  Widget _buildAdminAction(DocumentSnapshot user, Map<String, dynamic> data) {
    bool isAdmin = data['isAdmin'] == true;

    if (isAdmin) {
      return const Text(
        'ادمین',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    }

    return MyButton(
      text: 'ادمین کن',
      onPressed: () => _promoteToAdmin(user),
      color: Colors.blue,
      textColor: Colors.white,
    );
  }

  void _showMessage(String message, {Color backgroundColor = Colors.green}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}
