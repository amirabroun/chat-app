import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/components/my_button.dart';

class UsersListWidget extends StatefulWidget {
  const UsersListWidget({super.key});

  @override
  State<UsersListWidget> createState() => _UsersListWidgetState();
}

class _UsersListWidgetState extends State<UsersListWidget> {
  late Future<List> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = FirestoreService().getUsers(
      excludeUserId: AuthService().getCurrentUserId(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildUsersList()],
    );
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
          itemBuilder: (context, index) => _buildUserItem(users[index]),
        );
      },
    );
  }

  Widget _buildCenteredMessage(String message, {Color color = Colors.red}) {
    return Center(child: Text(message, style: TextStyle(color: color)));
  }

  Widget _buildUserItem(user) {
    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

    return ListTile(
      leading: const Icon(Icons.person_outline),
      title: Text(fullName.isNotEmpty ? fullName : 'بدون نام'),
      subtitle: Text(user.email),
      trailing: _buildAdminAction(user),
    );
  }

  Widget _buildAdminAction(user) {
    if (user.isAdmin == true) {
      return const Text(
        'ادمین',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    }

    return MyButton(
      text: 'ادمین کن',
      onPressed: () => _promoteToAdmin(user),
      color: Colors.grey,
      textColor: Colors.white,
      height: 38,
      fontSize: 12,
      borderRadius: 8,
      elevation: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  void _promoteToAdmin(user) async {
    try {
      await FirestoreService().updateUser(userId: user.userId, isAdmin: true);

      _showMessage('کاربر با موفقیت ادمین شد');
    } catch (e) {
      _showMessage(
        'خطا در ادمین کردن کاربر: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _usersFuture = FirestoreService().getUsers(
            excludeUserId: AuthService().getCurrentUserId(),
          );
        });
      }
    }
  }

  void _showMessage(
    String message, {
    Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    TextStyle? textStyle,
    double? elevation,
    EdgeInsetsGeometry? margin,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textStyle ?? const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: behavior,
        elevation: elevation,
        margin: margin,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'تایید',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
