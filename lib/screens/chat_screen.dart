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
  final _firestore = FirestoreService();
  final _auth = AuthService();
  final _controller = TextEditingController();

  late final String? _currentUserId = _auth.getCurrentUserId();
  late final Set<String> _participants = Set.from(widget.participantIds ?? []);
  Stream<List<ChatMessage>> _messagesStream = const Stream.empty();
  bool _isSending = false;
  String? _chatId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
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

  Widget _buildBody() {
    return Column(
      children: [Expanded(child: _buildMessageStream()), _buildMessageInput()],
    );
  }

  Widget _buildMessageStream() {
    return StreamBuilder<List<ChatMessage>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildCenterText('خطا: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data ?? [];
        return messages.isEmpty
            ? _buildCenterText('هنوز پیامی وجود ندارد')
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
        final msg = messages[index];
        final isMe = msg.senderId == _currentUserId;
        return _buildMessageBubble(msg, isMe);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isMe ? Colors.blue : Colors.grey[300];
    final textColor = isMe ? Colors.white70 : Colors.grey[600];

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && widget.chatType != ChatType.direct)
              FutureBuilder(
                future: _firestore.getUser(userId: message.senderId),
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
              style: TextStyle(fontSize: 10, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(child: _buildTextField()),
          const SizedBox(width: 8),
          _isSending
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: '...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildCenterText(String text) {
    return Center(child: Text(text));
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _initChat() async {
    if (widget.chatId != null) {
      _chatId = widget.chatId;
      _subscribeToMessages();
    } else if (_participants.length > 1) {
      try {
        final chat = await _firestore.findExistingChat(
          participantIds: _participants.toList(),
        );
        if (chat != null && mounted) {
          setState(() {
            _chatId = chat.chatId;
            _subscribeToMessages();
          });
        }
      } catch (e) {
        _showSnackbar('خطا در پیدا کردن چت: $e');
      }
    }
  }

  void _subscribeToMessages() {
    if (_chatId == null) return;
    setState(() {
      _messagesStream = _firestore.getChatMessagesStream(chatId: _chatId!);
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _currentUserId == null) return;

    setState(() => _isSending = true);
    _controller.clear();

    try {
      final chatId = await _getOrCreateChatId();
      await _firestore.sendMessage(
        chatId: chatId,
        senderId: _currentUserId,
        text: text,
      );
      if (mounted) _subscribeToMessages();
    } catch (e) {
      _showSnackbar('خطا در ارسال پیام: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<String> _getOrCreateChatId() async {
    if (_chatId != null) return _chatId!;
    try {
      return await _firestore.createNewChat(
        type: widget.chatType ?? ChatType.direct,
        participantIds: _participants.toList(),
        name: widget.chatName,
      );
    } catch (e) {
      debugPrint('Chat creation failed: $e');
      rethrow;
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }
}
