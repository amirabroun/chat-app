import 'package:flutter/material.dart';
import 'screens/chat_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          brightness: Brightness.dark,
          primary: Color.fromRGBO(10, 10, 10, 1),
          onPrimary: Color.fromRGBO(250, 250, 250, 1),
          secondary: Color.fromRGBO(23, 23, 23, 1),
        ),
      ),
      home: ChatListScreen(chatItems: sampleChats),
    );
  }
}

// Dummy data for testing
List<ChatItemData> sampleChats = [
  ChatItemData(
    name: "Proxy MTProto",
    message: "Server: Unknown Port: 443...",
    time: "1:00 PM",
    avatarUrl: "https://example.com/proxy.png",
  ),
  ChatItemData(
    name: "Mooji Coach",
    message: "طبق این نمودار هرچی آی کیو بالاتر...",
    time: "12:44 PM",
    avatarUrl: "https://example.com/mooji.png",
  ),
  ChatItemData(
    name: "Vigato | ویجیاتو",
    message: "شو رانر سریال The Boys تایید کرد که...",
    time: "12:30 PM",
    avatarUrl: "https://example.com/vigato.png",
  ),
  ChatItemData(
    name: "Digiato | دیجیاتو",
    message: "سامسونگ ظاهراً روی توسعه گوشی تاشوی جدید...",
    time: "12:10 PM",
    avatarUrl: "https://example.com/digiato.png",
  ),
  ChatItemData(
    name: "melobit | ملو بیت",
    message: "Voice message",
    time: "12:00 PM",
    avatarUrl: "https://example.com/melobit.png",
  ),
  ChatItemData(
    name: "Highroad Whispers",
    message: "احتمالا امشب از 7 تا فردا عصر ساعت 8...",
    time: "11:12 AM",
    avatarUrl: "https://example.com/highroad.png",
  ),
  ChatItemData(
    name: "Crypto Oxygen",
    message: "#VIDT +70%",
    time: "8:33 AM",
    avatarUrl: "https://example.com/crypto.png",
  ),
  ChatItemData(
    name: "Mini شعر",
    message: "سیری در پیوند تو ندارد نگاه من...",
    time: "10:10 AM",
    avatarUrl: "https://example.com/minipoetry.png",
  ),
  ChatItemData(
    name: "Ali Reza",
    message: "Hey, did you check the new update?",
    time: "9:45 AM",
    avatarUrl: "https://example.com/alireza.png",
  ),
  ChatItemData(
    name: "Sara K.",
    message: "I’ll send the report in 10 minutes.",
    time: "9:30 AM",
    avatarUrl: "https://example.com/sarak.png",
  ),
  ChatItemData(
    name: "John Doe",
    message: "Let's meet at 5 PM.",
    time: "8:00 AM",
    avatarUrl: "https://example.com/johndoe.png",
  ),
  ChatItemData(
    name: "John Doe",
    message: "Let's meet at 5 PM.",
    time: "8:00 AM",
    avatarUrl: "https://example.com/johndoe.png",
  ),
  ChatItemData(
    name: "John Doe",
    message: "Let's meet at 5 PM.",
    time: "8:00 AM",
    avatarUrl: "https://example.com/johndoe.png",
  ),
];
