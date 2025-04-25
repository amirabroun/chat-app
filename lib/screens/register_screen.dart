import 'package:chat_app/services/auth_service.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPWController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      _navigateToProfile();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPWController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await AuthService().signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showMessage('ثبت‌نام با موفقیت انجام شد');
      _navigateToProfile();
    } catch (e) {
      _showMessage(e.toString(), backgroundColor: Colors.red);
    }
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
              _buildRegisterButton(),
              const SizedBox(height: 16),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildConfirmPasswordField(),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return MyButton(
      text: 'ثبت‌نام',
      onPressed: _registerUser,
      color: Colors.blue,
      textColor: Colors.white,
    );
  }

  Widget _buildEmailField() {
    return MyTextfield(
      label: 'ایمیل',
      hintText: 'example@domain.com',
      controller: _emailController,
      icon: const Icon(Icons.email, color: Colors.blue),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'لطفاً ایمیل را وارد کنید';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'ایمیل معتبر نیست';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return MyTextfield(
      label: 'رمز عبور',
      hintText: 'حداقل ۶ کاراکتر',
      controller: _passwordController,
      icon: const Icon(Icons.lock, color: Colors.blue),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'لطفاً رمز عبور را وارد کنید';
        }
        if (value.length < 6) {
          return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return MyTextfield(
      label: 'تکرار رمز عبور',
      hintText: 'رمز عبور را تکرار کنید',
      controller: _confirmPWController,
      icon: const Icon(Icons.lock_outline, color: Colors.blue),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'لطفاً تکرار رمز عبور را وارد کنید';
        }
        if (value != _passwordController.text) {
          return 'رمز عبور و تکرار آن یکسان نیستند';
        }
        return null;
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: const Text("ورود", style: TextStyle(color: Colors.blue)),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ),
        ),
        const Text("حساب کاربری داری؟"),
      ],
    );
  }

  void _showMessage(String message, {Color backgroundColor = Colors.green}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  void _navigateToProfile() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }
}
