import 'package:chat_app/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/components/my_textfield.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = true;

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

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _redirectToLogin();
        return;
      }

      final userData = await _fetchUserData(user.uid);
      _updateUserInfo(user, userData);
    } catch (e) {
      _handleLoadError();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  void _updateUserInfo(User user, Map<String, dynamic>? userData) {
    setState(() {
      _firstNameController.text = userData?['first_name']?.toString() ?? '';
      _lastNameController.text = userData?['last_name']?.toString() ?? '';
      _emailController.text = user.email ?? '';
    });
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;
      if (user == null) {
        _redirectToLogin();
        return;
      }

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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _handleLoadError() {
    if (mounted) {
      _showSnackBar('خطا در بارگذاری اطلاعات کاربر');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

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

  Future<void> _handleLogout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildProfileForm();
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFirstNameField(),
            const SizedBox(height: 20),
            _buildLastNameField(),
            const SizedBox(height: 20),
            _buildEmailField(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstNameField() {
    return MyTextfield(
      label: 'نام',
      controller: _firstNameController,
      icon: const Icon(Icons.person, color: Colors.white),
      onChanged: (value) {},
    );
  }

  Widget _buildLastNameField() {
    return MyTextfield(
      label: 'نام خانوادگی',
      controller: _lastNameController,
      icon: const Icon(Icons.person_outline, color: Colors.white),
      onChanged: (value) {},
    );
  }

  Widget _buildEmailField() {
    return MyTextfield(
      label: 'ایمیل',
      controller: _emailController,
      icon: const Icon(Icons.email, color: Colors.white),
      onChanged: (value) {},
      enabled: false,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
