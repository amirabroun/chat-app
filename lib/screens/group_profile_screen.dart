import 'package:flutter/material.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:chat_app/screens/chat_list_screen.dart';

class GroupProfileScreen extends StatefulWidget {
  final String chatId;

  const GroupProfileScreen({super.key, required this.chatId});

  @override
  State<GroupProfileScreen> createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  String? currentUserId;
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _firestoreService = FirestoreService();

  List<User> _groupMembers = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCurrentUserId();
    _fetchGroupData();
  }

  Future<void> _initializeCurrentUserId() async {
    currentUserId = AuthService().getCurrentUserId();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchGroupData() async {
    try {
      final chat = await _firestoreService.getChat(chatId: widget.chatId);
      final allUsers = await _firestoreService.getChatUsers(widget.chatId);

      setState(() {
        _groupNameController.text = chat.name ?? '';
        _groupMembers = allUsers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching group data: $e');
      setState(() {
        _errorMessage = 'خطا در بارگیری اطلاعات گروه';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGroupName() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _firestoreService.updateChat(
        chatId: widget.chatId,
        name: _groupNameController.text.trim(),
      );
      _showSnackbar('نام گروه با موفقیت ذخیره شد');
    } catch (e) {
      debugPrint('Error updating group name: $e');
      _showSnackbar('خطا در ذخیره‌سازی');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('حذف گروه'),
            content: const Text('آیا مطمئنی که می‌خوای این گروه رو حذف کنی؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('لغو'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await _firestoreService.deleteChat(chatId: widget.chatId);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatListScreen(currentUserId: currentUserId!),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting group: $e');
      _showSnackbar('خطا در حذف گروه');
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل گروه')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupNameField(),
            const SizedBox(height: 20),
            const Text(
              'اعضای گروه',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildMembersList(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupNameField() {
    return MyTextfield(
      label: 'نام گروه',
      controller: _groupNameController,
      icon: const Icon(Icons.group),
      validator:
          (value) =>
              value!.trim().isEmpty ? 'نام گروه نمی‌تواند خالی باشد' : null,
    );
  }

  Widget _buildMembersList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _groupMembers.length,
        itemBuilder: (context, index) {
          final user = _groupMembers[index];
          return _buildUserTile(user);
        },
      ),
    );
  }

  Widget _buildUserTile(User user) {
    final isCurrentUser = user.userId == currentUserId;
    final userName = user.firstName ?? '';

    return ListTile(
      leading: UserAvatar(name: userName),
      title: Text(
        userName,
        style: TextStyle(color: isCurrentUser ? Colors.grey : Colors.black),
      ),
      subtitle: Text(
        isCurrentUser ? 'This is you' : 'Online',
        style: TextStyle(color: Colors.grey[600]),
      ),
      onTap: isCurrentUser ? null : () => _navigateToChat(user),
      enabled: !isCurrentUser,
    );
  }

  void _navigateToChat(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              chatName: user.firstName ?? '',
              participantIds: [currentUserId!, user.userId],
              chatType: ChatType.direct,
            ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildSaveButton(),
        const SizedBox(width: 12),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _saveGroupName,
      icon: const Icon(Icons.save),
      label:
          _isSaving
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Text('ذخیره'),
    );
  }

  Widget _buildDeleteButton() {
    return OutlinedButton.icon(
      onPressed: _isSaving ? null : _deleteGroup,
      icon: const Icon(Icons.delete_outline),
      label: const Text('حذف گروه'),
      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
    );
  }
}
