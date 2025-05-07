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
  final ChatType? chatType;

  const ChatScreen({
    super.key,
    String? chatName,
    required this.chatType,
    this.participantIds,
    this.chatId,
  }) : chatName = chatName ?? 'New Chat';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final TextEditingController _controller = TextEditingController();

  late final String? currentUserId = _authService.getCurrentUserId();
  late final Set<String> _participants =
      widget.participantIds != null
          ? Set<String>.from(widget.participantIds!)
          : <String>{};
  Stream<List<ChatMessage>> _messagesStream = const Stream.empty();
  bool _isSending = false;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    String? chatId = widget.chatId;

    if (chatId != null) {
      _chatId = chatId;
      _loadMessages();
    } else if (_participants.length > 1) {
      _firestoreService
          .findExistingChat(participantIds: _participants.toList())
          .then((existingChat) {
            if (existingChat != null && mounted) {
              setState(() {
                _chatId = existingChat.chatId;
                _loadMessages();
              });
            }
          })
          .catchError((e) {
            if (mounted) {
              _showErrorSnackbar('خطا در پیدا کردن چت: $e');
            }
          });
    }
  }

  void _loadMessages() {
    if (_chatId != null) {
      setState(() {
        _messagesStream = _firestoreService.getChatMessagesStream(
          chatId: _chatId!,
        );
        print('درخواست پیام‌ها ارسال شد برای chatId: $_chatId');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildChatBody());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          UserAvatar(name: widget.chatName),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.chatName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBody() {
    return Column(
      children: [Expanded(child: _buildMessageStream()), _buildInputField()],
    );
  }

  Widget _buildMessageStream() {
    return StreamBuilder<List<ChatMessage>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data ?? [];
        return messages.isEmpty
            ? const Center(child: Text('No messages yet'))
            : _buildMessageList(messages);
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
        return _buildMessageBubble(message, isMe);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
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
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe &&
                (widget.chatType == ChatType.group ||
                    widget.chatType == ChatType.direct))
              FutureBuilder(
                future: _firestoreService.getUser(userId: message.senderId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 16);
                  }
                  final user = snapshot.data;
                  return Text(
                    user?.firstName ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
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
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: _buildTextInput()),
          const SizedBox(width: 8),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Type a message...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildSendButton() {
    return _isSending
        ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
        : IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || currentUserId == null) return;

    setState(() => _isSending = true);
    _controller.clear();

    try {
      final chatId = await _getOrCreateChatId();
      await _firestoreService.sendMessage(
        chatId: chatId,
        senderId: currentUserId!,
        text: text,
      );

      if (mounted) {
        setState(() {
          _messagesStream = _firestoreService.getChatMessagesStream(
            chatId: chatId,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error sending message: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<String> _getOrCreateChatId() async {
    if (_chatId != null) return _chatId!;

    try {
      return await _firestoreService.createNewChat(
        type: ChatType.direct,
        participantIds: _participants.toList(),
        name: widget.chatName,
      );
    } catch (e) {
      debugPrint('Error creating chat: $e');
      rethrow;
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
