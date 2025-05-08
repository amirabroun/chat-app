import 'package:flutter/material.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/models/chat_model.dart';

class GroupProfileScreen extends StatefulWidget {
  final String chatId;

  const GroupProfileScreen({super.key, required this.chatId});

  @override
  State<GroupProfileScreen> createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdating = false;

  Chat? _chat;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchChatData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchChatData() async {
    try {
      final chat = await FirestoreService().getChat(chatId: widget.chatId);
      if (chat == false) {
        _setError('گروه یافت نشد');
        return;
      }

      setState(() {
        _chat = chat;
        _nameController.text = chat.name ?? '';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading chat: $e');
      _setError('خطا در دریافت اطلاعات گروه');
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<void> _updateGroup() async {
    if (!_formKey.currentState!.validate() || _chat == null) return;

    setState(() => _isUpdating = true);

    try {
      await FirestoreService().updateChat(
        chatId: widget.chatId,
        name: _nameController.text.trim(),
      );
      if (!mounted) return;
      _showSnackbar('نام گروه با موفقیت به‌روزرسانی شد');
    } catch (e) {
      debugPrint('Error updating group name: $e');
      _showSnackbar('خطا در به‌روزرسانی نام گروه');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteGroup() async {
    final confirm = await _showDeleteConfirmation();
    if (confirm != true) return;

    try {
      await FirestoreService().deleteChat(chatId: widget.chatId);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error deleting group: $e');
      _showSnackbar('خطا در حذف گروه');
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف گروه'),
            content: const Text('آیا مطمئنی می‌خوای گروه رو حذف کنی؟'),
            actions: [
              TextButton(
                child: const Text('لغو'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('حذف'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_chat == null) {
      return const Center(child: Text('گروه یافت نشد'));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextfield(
              label: 'نام گروه',
              controller: _nameController,
              icon: const Icon(Icons.group),
              validator:
                  (value) => value!.isEmpty ? 'نام گروه الزامی است' : null,
            ),
            const SizedBox(height: 20),
            const Text(
              'اعضای گروه:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._chat!.participants.map((id) => Text(id)),
            const Spacer(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _isUpdating ? null : _updateGroup,
          icon: const Icon(Icons.save),
          label:
              _isUpdating
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('ذخیره تغییرات'),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: _isUpdating ? null : _deleteGroup,
          icon: const Icon(Icons.delete),
          label: const Text('حذف گروه'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}
