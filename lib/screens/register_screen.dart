import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPWController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (AuthService().getCurrentUserId() != null) {
      _navigateToProfile();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPWController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFormFields(),
              const SizedBox(height: 50),
              MyButton(text: 'ثبت‌ نام', onPressed: _registerUser, width: 320),
              const SizedBox(height: 16),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(Icons.person_add, size: 80, color: colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          "ثبت‌ نام کنید",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
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
        spacing: 16,
        children: [
          _buildFirstNameField(),
          _buildLastNameField(),
          _buildEmailField(),
          _buildPasswordField(),
          _buildConfirmPasswordField(),
        ],
      ),
    );
  }

  Widget _buildFirstNameField() {
    return MyTextfield(
      label: 'نام',
      controller: _firstNameController,
      icon: const Icon(Icons.person),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'نام را وارد کنید';
        }
        return null;
      },
    );
  }

  Widget _buildLastNameField() {
    return MyTextfield(
      label: 'نام خانوادگی',
      controller: _lastNameController,
      icon: const Icon(Icons.person),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'نام خانوادگی را وارد کنید';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return MyTextfield(
      label: 'ایمیل',
      controller: _emailController,
      icon: const Icon(Icons.email),
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
      controller: _passwordController,
      icon: const Icon(Icons.lock),
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
      controller: _confirmPWController,
      icon: const Icon(Icons.lock_outline),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: Text("ورود", style: TextStyle(color: colorScheme.primary)),
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

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      final userCredential = await AuthService().signUpWithEmail(
        email: email,
        password: password,
      );

      if (!mounted) return;

      await FirestoreService().createUser(
        userId: userCredential!.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      _showMessage('ثبت‌نام با موفقیت انجام شد');
      _emailController.clear();
      _passwordController.clear();
      _confirmPWController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _navigateToProfile();
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString(), backgroundColor: Colors.red);
    }
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

  void _navigateToProfile() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }
}
