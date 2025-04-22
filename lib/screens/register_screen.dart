import 'package:flutter/material.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/screens/login_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add, size: 100, color: Colors.blueGrey),
            const SizedBox(height: 20),
            const Text(
              "Welcome! Sign Up Below",
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
              icon: const Icon(Icons.lock, size: 30, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            MyTextfield(
              hintText: 'Confirm Password',
              controller: _confirmPasswordController,
              icon: const Icon(
                Icons.lock_outline,
                size: 30,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),
            MyButton(
              text: 'ثبت‌نام',
              onPressed: () {
                print("Email: ${_emailController.text}");
                print("Password: ${_passwordController.text}");
              },
            ),
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
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "لاگین",
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
