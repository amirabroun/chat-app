import 'package:chat_app/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await AuthService().signInWithEmail(email: email, password: password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('با موفقیت وارد شدید'),
          backgroundColor: Colors.green,
        ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.message, size: 100, color: Colors.blueGrey),
            const SizedBox(height: 20),
            const Text(
              "Hi my friend",
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            MyTextfield(
              hintText: 'Email',
              controller: _emailController,
              icon: const Icon(Icons.email, size: 30, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            MyTextfield(
              hintText: 'Password',
              controller: _passwordController,
              icon: const Icon(
                Icons.password,
                size: 30,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),
            MyButton(text: 'ارسال', onPressed: () => login()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "حساب کاربری نداری؟",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "ثبت‌نام",
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
