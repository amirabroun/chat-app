import 'package:chat_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/widgets/users_list_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
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

  // Main Build Methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildProfileForm(),
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileField(
              label: 'نام',
              controller: _firstNameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            _buildProfileField(
              label: 'نام خانوادگی',
              controller: _lastNameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildProfileField(
              label: 'ایمیل',
              controller: _emailController,
              icon: Icons.email,
              enabled: false,
            ),
            _buildAdminContent(),
          ],
        ),
      ),
    );
  }

  // UI Components
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('پروفایل'),
      actions: [
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
      ],
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
  }) {
    return MyTextfield(
      label: label,
      controller: controller,
      icon: Icon(icon, color: Colors.white),
      enabled: enabled,
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

  // Data Methods
  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return _redirectToLogin();

      final userData = await _fetchUserData(user.uid);
      if (userData == null) throw Exception('User data not found');

      _updateUserState(user, userData);
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _handleDataError();
    }
  }

  Future<Map<String, dynamic>?> _fetchUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  void _updateUserState(User user, Map<String, dynamic> userData) {
    if (!mounted) return;

    setState(() {
      _authIsAdmin = userData['isAdmin'] == true;
      _isLoading = false;
      _firstNameController.text = userData['first_name']?.toString() ?? '';
      _lastNameController.text = userData['last_name']?.toString() ?? '';
      _emailController.text = user.email ?? '';
    });
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;
      if (user == null) return _redirectToLogin();

      await _firestore.collection('users').doc(user.uid).set({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _showSnackBar('اطلاعات با موفقیت ذخیره شد');
    } catch (e) {
      _showSnackBar('خطا در ذخیره اطلاعات');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Auth Method
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

  // Utility Methods
  void _handleDataError() {
    if (!mounted) return;
    setState(() {
      _authIsAdmin = false;
      _isLoading = false;
    });
    _showSnackBar('خطا در بارگذاری اطلاعات کاربر');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
