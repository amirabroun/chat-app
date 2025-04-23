import 'package:chat_app/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkIfLoggedIn() async {
    if (FirebaseAuth.instance.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      });
    }
  }

  Future<void> _registerUser() async {
    if (!_validateInputs()) return;

    try {
      await AuthService().signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showSuccessMessage();
      _navigateToProfile();
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  bool _validateInputs() {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage('رمز عبور و تکرار آن یکسان نیستند');
      return false;
    }
    return true;
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ثبت‌نام با موفقیت انجام شد'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.person_add, size: 80, color: Colors.blue),
        const SizedBox(height: 16),
        Text(
          "ثبت‌نام کنید",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        MyTextfield(
          hintText: 'ایمیل',
          controller: _emailController,
          icon: const Icon(Icons.email, color: Colors.blue),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'رمز عبور',
          controller: _passwordController,
          icon: const Icon(Icons.lock, color: Colors.blue),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'تکرار رمز عبور',
          controller: _confirmPasswordController,
          icon: const Icon(Icons.lock_outline, color: Colors.blue),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("حساب کاربری داری؟"),
        TextButton(
          onPressed: _navigateToLogin,
          child: const Text("ورود", style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildFormFields(),
              const SizedBox(height: 24),
              MyButton(
                text: 'ثبت‌نام',
                onPressed: _registerUser,
                color: Colors.blue,
                textColor: Colors.white,
              ),
              const SizedBox(height: 16),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }
}
