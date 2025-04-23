import 'package:chat_app/auth/auth_service.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رمز عبور و تکرار آن یکسان نیستند'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authService = AuthService();
      await authService.signUpWithEmail(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ثبت‌نام با موفقیت انجام شد'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 100, color: Colors.blueGrey),
              const SizedBox(height: 20),
              const Text(
                "ثبت‌نام کنید",
                style: TextStyle(color: Colors.blueGrey, fontSize: 18),
              ),
              const SizedBox(height: 20),
              MyTextfield(
                hintText: 'ایمیل',
                controller: _emailController,
                icon: const Icon(Icons.email, size: 30, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              MyTextfield(
                hintText: 'رمز عبور',
                controller: _passwordController,
                icon: const Icon(Icons.lock, size: 30, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              MyTextfield(
                hintText: 'تکرار رمز عبور',
                controller: _confirmPasswordController,
                icon: const Icon(
                  Icons.lock_outline,
                  size: 30,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 20),
              MyButton(text: 'ثبت‌نام', onPressed: register),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "حساب کاربری داری؟",
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "ورود",
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
