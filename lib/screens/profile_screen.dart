import 'package:chat_app/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/my_button.dart';

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

  List<Map<String, dynamic>> users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final data =
        snapshot.docs.map((doc) {
          final userData = doc.data();
          userData['uid'] = doc.id;
          return userData;
        }).toList();

    setState(() {
      users = data;
      _isLoading = false;
    });
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
    return _isLoading ? _buildLoadingIndicator() : _buildProfileForm();
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
            const SizedBox(height: 30),
            const Text('لیست کاربران'),
            const SizedBox(height: 10),
            _buildUsersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('کاربری یافت نشد.');
        }

        return _buildUsersListView(snapshot.data!.docs);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildUsersListView(List<QueryDocumentSnapshot> users) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _buildUserListItem(users[index], context);
      },
    );
  }

  Widget _buildUserListItem(QueryDocumentSnapshot user, BuildContext context) {
    final userData = user.data() as Map<String, dynamic>;

    return ListTile(
      leading: const Icon(Icons.person_outline),
      title: Text(userData['fullName'] ?? 'بدون نام'),
      subtitle: Text(userData['email'] ?? 'بدون ایمیل'),
      trailing: _buildUserAdminStatus(user, userData, context),
    );
  }

  Widget _buildUserAdminStatus(
    QueryDocumentSnapshot user,
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    if (userData['isAdmin'] == true) {
      return _buildAdminLabel();
    } else {
      return _buildMakeAdminButton(user, context);
    }
  }

  Widget _buildAdminLabel() {
    return const Text('ادمین', style: TextStyle(color: Colors.green));
  }

  Widget _buildMakeAdminButton(
    QueryDocumentSnapshot user,
    BuildContext context,
  ) {
    return MyButton(
      text: 'ادمین کن',
      onPressed: () => _promoteToAdmin(user, context),
      color: Colors.blue,
      textColor: Colors.white,
    );
  }

  Future<void> _promoteToAdmin(
    QueryDocumentSnapshot user,
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'isAdmin': true,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ادمین شد')));

      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ادمین کردن کاربر: ${e.toString()}')),
      );
    }
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
