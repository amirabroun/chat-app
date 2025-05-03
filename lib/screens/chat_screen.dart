import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatName;
  final Chat chatItem;

  const ChatScreen({super.key, required this.chatName, required this.chatItem});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? currentUserId;
  List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUserId = AuthService().getCurrentUserId();
    if (currentUserId == null) {
      _navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.chatItem.participants.firstWhere((id) => id != currentUserId);
    return Scaffold(appBar: _buildAppBar(), body: _buildChatBody());
  }

  AppBar _buildAppBar() {
    final chatName = widget.chatName;
    final avatarUrl = widget.chatItem.imageUrl;
    final lastSeen = 'last seen recently';

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Row(
        children: [
          UserAvatar(name: chatName, avatarUrl: avatarUrl),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chatName, style: const TextStyle(fontSize: 16)),
              Text(lastSeen, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Column _buildChatBody() {
    return Column(
      children: [Expanded(child: _buildMessageStream()), _buildInputField()],
    );
  }

  Widget _buildMessageStream() {
    return StreamBuilder<List<ChatMessage>>(
      stream: FirestoreService().getChatMessagesStream(
        chatId: widget.chatItem.chatId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _messages = snapshot.data!;
        }

        if (_messages.isEmpty && !snapshot.hasData) {
          return _buildEmptyState();
        }

        return _buildMessageList(_messages);
      },
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    final userId = AuthService().getCurrentUserId();
    // if (messages.isEmpty) {
    //   return _buildEmptyChatsState();
    // }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == userId!;
        final colorScheme = Theme.of(context).colorScheme;
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isMe ? colorScheme.primary : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${message.text} ${message.timestamp}',
              style: TextStyle(color: isMe ? colorScheme.surface : colorScheme.onSurface),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(
                hintText: 'Write a message...',
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage, color: colorScheme.primary,),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    final chatId = widget.chatItem.chatId;
    final userId = AuthService().getCurrentUserId();

    if (text.isEmpty) return;

    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          messageId: '',
          senderId: userId!,
          text: text,
          timestamp: DateTime.now(),
        ),
      );
    });

    _controller.clear();
    FirestoreService().sendMessage(
      chatId: chatId,
      senderId: userId!,
      text: text,
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text('No message yet!'));
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
