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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    return AppBar(title: const Text('پروفایل'), actions: actions);
  }

  Widget _buildProfileForm() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final formFields = [
      MyTextfield(
        label: 'نام',
        controller: _firstNameController,
        icon: const Icon(Icons.person, color: Colors.white),
      ),
      const SizedBox(height: 20),
      MyTextfield(
        label: 'نام خانوادگی',
        controller: _lastNameController,
        icon: const Icon(Icons.person_outline, color: Colors.white),
      ),
      const SizedBox(height: 20),
      MyTextfield(
        label: 'ایمیل',
        controller: _emailController,
        icon: const Icon(Icons.email, color: Colors.white),
        enabled: false,
      ),
      _buildAdminContent(),
    ];

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20), // پدینگ 20 برای همه جهات
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

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return _redirectToLogin();

      final userData = await _fetchUserData(user.uid);
      if (userData == null) throw Exception('User data not found');

      _updateUserState(user, userData);
    } catch (e) {
      if (!mounted) return;

      _showMessage('خطا در بارگذاری اطلاعات کاربر : $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        debugPrint('User document with ID $uid does not exist');
        return null;
      }

      final data = doc.data();
      debugPrint('Fetched user data for ID $uid: ${data.toString()}');
      return data;
    } catch (e) {
      debugPrint('Error fetching user data for ID $uid: $e');
      return null;
    }
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

      _showMessage('اطلاعات با موفقیت ذخیره شد');
    } catch (e) {
      _showMessage('خطا در ذخیره اطلاعات');
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

  void _showMessage(String message, {Color backgroundColor = Colors.green}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}
