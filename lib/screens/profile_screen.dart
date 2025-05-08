import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/components/my_textfield.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildProfileForm());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('پروفایل'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions:
          _isOwner
              ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: 'ذخیره تغییرات',
                  onPressed: _saveUserData,
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'خروج از حساب',
                  onPressed: _handleLogout,
                ),
              ]
              : null,
    );
  }

  Widget _buildProfileForm() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            MyTextfield(
              label: 'نام',
              controller: _firstNameController,
              icon: const Icon(Icons.person),
              enabled: _isOwner,
            ),
            const SizedBox(height: 20),
            MyTextfield(
              label: 'نام خانوادگی',
              controller: _lastNameController,
              icon: const Icon(Icons.person_outline),
              enabled: _isOwner,
            ),
            const SizedBox(height: 20),
            MyTextfield(
              label: 'ایمیل',
              controller: _emailController,
              icon: const Icon(Icons.email),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  void _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final currentUserId = AuthService().getCurrentUserId();
      if (currentUserId == null) {
        _redirectToLogin();
        return;
      }

      final targetUserId = widget.userId ?? currentUserId;
      _isOwner = (targetUserId == currentUserId);

      final user = await FirestoreService().getUser(userId: targetUserId);
      _updateUserState(user);
    } catch (e) {
      debugPrint(e.toString());
      _showMessage('خطا در بارگذاری اطلاعات کاربر');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateUserState(user) {
    if (!mounted) return;

    setState(() {
      _emailController.text = user.email;
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
    });
  }

  void _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userId = AuthService().getCurrentUserId();
      if (userId == null) {
        _redirectToLogin();
        return;
      }

      await FirestoreService().updateUser(
        userId: userId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );

      _showMessage('اطلاعات با موفقیت ذخیره شد');
    } catch (e) {
      debugPrint(e.toString());
      _showMessage(
        'خطای ناشناخته در ذخیره اطلاعات',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() async {
    await AuthService().signOut();
    _redirectToLogin();
  }

  void _redirectToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
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
