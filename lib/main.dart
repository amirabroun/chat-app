import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_app/screens/chat_list_screen.dart';
import 'package:chat_app/constant/colors.dart';

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
    final userId = AuthService().getCurrentUserId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = Navigator.of(context);

      if (userId == null) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (!navigator.canPop()) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => ChatListScreen(currentUserId: userId)),
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
      theme: MaterialTheme(TextTheme()).light(),
      home: Builder(builder: _handleInitialRedirect),
    );
  }
}
