import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/screens/register_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/screens/chat_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFormFields(),
          const SizedBox(height: 24),
          MyButton(text: 'ورود', onPressed: _loginUser),
          const SizedBox(height: 16),
          _buildRegisterLink(),
        ],
      ),
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
        _buildEmailField(),
        const SizedBox(height: 18),
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildEmailField() {
    return MyTextfield(
      label: 'ایمیل',
      hintText: 'example@domain.com',
      controller: _emailController,
      icon: const Icon(Icons.email),
      validator:
          (value) => value?.isEmpty ?? true ? 'لطفاً ایمیل را وارد کنید' : null,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return MyTextfield(
      label: 'رمز عبور',
      hintText: '******',
      controller: _passwordController,
      icon: const Icon(Icons.lock),
      validator:
          (value) =>
              value?.isEmpty ?? true ? 'لطفاً رمز عبور را وارد کنید' : null,
      obscureText: true,
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: const Text("ثبت‌نام", style: TextStyle(color: Colors.blue)),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              ),
        ),
        const Text("حساب کاربری ندارید؟"),
      ],
    );
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await AuthService().signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showMessage('با موفقیت وارد شدید');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatListScreen()),
        );
      }
    } catch (e) {
      _showMessage(e.toString(), backgroundColor: Colors.red);
    }
  }

  void _navigateToProfile() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
