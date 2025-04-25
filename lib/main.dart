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

  Widget getInitialScreen() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return const ChatListScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          brightness: Brightness.dark,
          primary: Color.fromRGBO(10, 10, 10, 1),
          onPrimary: Color.fromRGBO(250, 250, 250, 1),
          secondary: Color.fromRGBO(23, 23, 23, 1),
        ),
      ),
      home: getInitialScreen(),
    );
  }
}
