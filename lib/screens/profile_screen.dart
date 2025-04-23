import 'package:chat_app/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
      _firstName = userData?['first_name']?.toString() ?? '';
      _lastName = userData?['last_name']?.toString() ?? '';
      _email = user.email ?? '';
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
        'first_name': _firstName,
        'last_name': _lastName,
        'email': _email,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() => _isEditing = false);
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
        if (_isEditing)
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUserData,
            tooltip: 'ذخیره تغییرات',
          )
        else
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = true),
            tooltip: 'ویرایش پروفایل',
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

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'نام',
              value: _firstName,
              icon: Icons.person,
              onChanged: (value) => _firstName = value,
              enabled: _isEditing,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'نام خانوادگی',
              value: _lastName,
              icon: Icons.person_outline,
              onChanged: (value) => _lastName = value,
              enabled: _isEditing,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'ایمیل',
              value: _email,
              icon: Icons.email,
              onChanged: (value) => _email = value,
              enabled: false, 
            ),
            if (_isEditing) ...[
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveUserData,
                  child: const Text('ذخیره تغییرات'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required IconData icon,
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      enabled: enabled,
      validator: (value) {
        if (label == 'ایمیل' && (value == null || value.isEmpty)) {
          return 'لطفا ایمیل را وارد کنید';
        }
        return null;
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
