import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/widgets/users_list_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  bool _authIsAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
    final actions = [
      IconButton(
        icon: const Icon(Icons.check),
        onPressed: _saveUserData,
        tooltip: 'ذخیره تغییرات',
      ),
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'خروج از حساب',
        onPressed: _handleLogout,
      ),
    ];

    return AppBar(
      title: const Text('پروفایل'),
      actions: actions,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildProfileForm() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final formFields = [
      MyTextfield(
        label: 'نام',
        controller: _firstNameController,
        icon: const Icon(Icons.person),
      ),
      const SizedBox(height: 20),
      MyTextfield(
        label: 'نام خانوادگی',
        controller: _lastNameController,
        icon: const Icon(Icons.person_outline),
      ),
      const SizedBox(height: 20),
      MyTextfield(
        label: 'ایمیل',
        controller: _emailController,
        icon: const Icon(Icons.email),
        enabled: false,
      ),
      _buildAdminContent(),
    ];

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: formFields),
      ),
    );
  }

  Widget _buildAdminContent() {
    if (!_authIsAdmin) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 30),
        Text('لیست کاربران'),
        SizedBox(height: 10),
        UsersListWidget(),
      ],
    );
  }

  void _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _redirectToLogin();
        return;
      }

      _updateUserState(await FirestoreService().getUser(userId: user.uid));
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
      _authIsAdmin = user.isAdmin;
      _isLoading = false;
    });
  }

  void _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _redirectToLogin();
        return;
      }

      await FirestoreService().updateUser(
        userId: user.uid,
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

  Future<void> _handleLogout() async {
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
