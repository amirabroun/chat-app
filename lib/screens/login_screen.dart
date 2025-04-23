import 'package:chat_app/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/screens/register_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await AuthService().signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showSuccessMessage();
      _navigateToProfile();
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('با موفقیت وارد شدید'),
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

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.message, size: 80, color: Colors.blue),
        const SizedBox(height: 16),
        Text(
          "خوش آمدید",
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
          validator:
              (value) =>
                  value?.isEmpty ?? true ? 'لطفاً ایمیل را وارد کنید' : null,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'رمز عبور',
          controller: _passwordController,
          icon: const Icon(Icons.lock, color: Colors.blue),
          validator:
              (value) =>
                  value?.isEmpty ?? true ? 'لطفاً رمز عبور را وارد کنید' : null,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _navigateToRegister,
          child: const Text("ثبت‌نام", style: TextStyle(color: Colors.blue)),
        ),
        const Text("حساب کاربری ندارید؟"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildFormFields(),
                const SizedBox(height: 24),
                MyButton(
                  text: 'ورود',
                  onPressed: _loginUser,
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 16),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
