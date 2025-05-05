import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatName;
  final String? chatId;
  final List<String>? participantIds;

  const ChatScreen({
    super.key,
    required this.chatName,
    this.participantIds,
    this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? currentUserId;
  final _controller = TextEditingController();
  late Stream<List<ChatMessage>> _messagesStream;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    currentUserId = AuthService().getCurrentUserId();
    _initializeChat();
  }

  void _initializeChat() {
    if (widget.chatId != null) {
      _messagesStream = FirestoreService().getChatMessagesStream(
        chatId: widget.chatId!,
      );
    } else {
      _messagesStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildChatBody());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: ListTile(
        leading: UserAvatar(name: widget.chatName),
        title: Text(widget.chatName),
        subtitle: const Text('last seen recently'),
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
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (widget.chatId == null) {
          return const Center(child: Text('Start a new conversation'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        return _buildMessageList(messages);
      },
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUserId;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(message.text),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isSending
              ? const CircularProgressIndicator()
              : IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _controller.clear();

    try {
      final chatId = await _getOrCreateChatId();

      await FirestoreService().sendMessage(
        chatId: chatId,
        senderId: currentUserId!,
        text: text,
      );

      if (widget.chatId == null) {
        setState(() {
          _messagesStream = FirestoreService().getChatMessagesStream(
            chatId: chatId,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ارسال پیام: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<String> _getOrCreateChatId() async {
    if (widget.chatId != null) {
      return widget.chatId!;
    }

    if (widget.participantIds == null || widget.participantIds!.isEmpty) {
      throw ArgumentError('برای ساخت چت جدید، participantIds الزامی است');
    }

    final participants = widget.participantIds!.toSet()..add(currentUserId!);

    try {
      final existingChat = await FirestoreService().findExistingChat(
        participantIds: participants.toList(),
      );

      if (existingChat != null) {
        return existingChat.chatId;
      }
    } catch (e) {
      debugPrint('Error searching for existing chat: $e');
    }

    return await FirestoreService().createNewChat(
      type: ChatType.direct,
      participantIds: participants.toList(),
      name: widget.chatName,
    );
  }
}
