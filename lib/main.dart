import 'package:chat_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/chat_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAEQQihRDGBpoVAKlS9MsPxYyJ4A8OktSY",
      appId: "1:840506521711:android:1b4229d18954edd958359a",
      messagingSenderId: "840506521711",
      projectId: "chat-app-1b168",
    ),
  );

  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  Widget _handleInitialRedirect(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = Navigator.of(context);

      if (user == null) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (!navigator.canPop()) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatListScreen()),
        );
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade50, // use for background
          primary: Colors.blue.shade700,
          secondary: Colors.blueGrey,
        ),
      ),
      home: Builder(builder: _handleInitialRedirect),
    );
  }
}
