import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/screens/group_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatName;
  final String? chatId;
  final List<String>? participantIds;
  final ChatType? chatType;

  const ChatScreen({
    super.key,
    required this.chatType,
    this.participantIds,
    this.chatId,
    String? chatName,
  }) : chatName = chatName ?? 'New Chat';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = FirestoreService();
  final _auth = AuthService();
  final _controller = TextEditingController();

  late final String? _currentUserId = _auth.getCurrentUserId();
  late final String? _otherUserId;
  late final Set<String> _participantSet = Set.from(
    widget.participantIds ?? [],
  );

  Stream<List<ChatMessage>> _messagesStream = const Stream.empty();
  late String? _chatId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageStream()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: InkWell(
        onTap: _navigateToProfile,
        borderRadius: BorderRadius.circular(8),
        child: Row(
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
      ),
    );
  }

  void _navigateToProfile() {
    if (!mounted) return;

    final route =
        (widget.chatType == ChatType.group && _chatId != null)
            ? GroupProfileScreen(chatId: _chatId!)
            : ProfileScreen(userId: _otherUserId);

    Navigator.push(context, MaterialPageRoute(builder: (_) => route));
  }

  Widget _buildMessageStream() {
    return StreamBuilder<List<ChatMessage>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _centeredText('خطا: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return _centeredText('هنوز پیامی وجود ندارد');
        }
        _markMessagesAsSeen(messages);
        return _buildMessageList(messages);
      },
    );
  }

  void _markMessagesAsSeen(List<ChatMessage> messages) async {
    if (_currentUserId == null) return;
    for (final msg in messages) {
      if (!msg.seenBy.contains(_currentUserId) &&
          msg.senderId != _currentUserId) {
        await _firestore.markMessageAsSeen(
          chatId: _chatId!,
          messageId: msg.messageId,
          userId: _currentUserId,
        );
      }
    }
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == _currentUserId;
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
          color: isMe ? Colors.blueAccent[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && widget.chatType != ChatType.direct)
              _buildSenderName(message.senderId),
            Text(
              message.text,
              style: TextStyle(
                fontSize: 18,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                if (isMe) _buildSeenIndicator(message),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderName(String senderId) {
    return FutureBuilder(
      future: _firestore.getUser(userId: senderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 16);
        }

        final user = snapshot.data;
        final userName = user?.firstName ?? 'Unknown';

        return InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: senderId),
              ),
            );
          },
          child: Text(
            userName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeenIndicator(ChatMessage message) {
    final seen = message.seenBy.contains(_otherUserId);
    return Icon(
      seen ? Icons.done_all : Icons.done,
      size: 16,
      color: Colors.white70,
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[300]),
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          spacing: 8,
          children: [
            Expanded(child: _buildTextField()),
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
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      style: TextStyle(fontSize: 18, color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Message',
        hintStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _centeredText(String text) => Center(child: Text(text));

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _initializeChat() async {
    if (widget.chatId != null) {
      final chat = await _firestore.getChat(chatId: widget.chatId!);
      _setupChat(chat, widget.chatId!);
      return;
    }

    final existingChat = await _firestore.findExistingChat(
      participantIds: _participantSet.toList(),
    );

    if (!mounted) return;

    if (existingChat == null) {
      setState(() {
        _otherUserId = _participantSet.firstWhere((id) => id != _currentUserId);
      });
    } else {
      _setupChat(existingChat, existingChat.chatId);
    }
  }

  void _setupChat(Chat chat, String chatId) {
    setState(() {
      _chatId = chatId;
      _messagesStream = _firestore.getChatMessagesStream(chatId: chatId);
      _otherUserId = chat.participants.firstWhere(
        (id) => id != _currentUserId,
        orElse: () => '',
      );
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

      if (mounted) {
        setState(() {
          _messagesStream = _firestore.getChatMessagesStream(chatId: chatId);
          _isSending = false;
        });
      }
    } catch (e) {
      _showSnackbar('خطا در ارسال پیام: $e');
    }
  }

  Future<String> _getOrCreateChatId() async {
    if (_chatId != null) {
      return _chatId!;
    }

    try {
      final newChatId = await _firestore.createNewChat(
        type: widget.chatType ?? ChatType.direct,
        participantIds: _participantSet.toList(),
        name: widget.chatName,
      );
      setState(() => _chatId = newChatId);
      return newChatId;
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
