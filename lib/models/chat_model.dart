import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatType { direct, group }

class Chat {
  final String chatId;
  final List<String> participants;
  final DateTime createdAt;
  final ChatType type;
  final String? name;
  final String? imageUrl;
  final DateTime updatedAt;
  final Map<String, dynamic>? lastMessage;

  Chat({
    required this.chatId,
    required this.participants,
    required this.createdAt,
    required this.type,
    this.name,
    this.imageUrl,
    required this.updatedAt,
    this.lastMessage,
  });

  factory Chat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Chat(
      chatId: snapshot.id,
      participants: List<String>.from(data['participants']),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      type: ChatType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => ChatType.direct,
      ),
      name: data['name'],
      imageUrl: data['image_url'],
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      lastMessage: data['last_message'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'type': type.name,
      'name': name,
      'image_url': imageUrl,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'last_message': lastMessage,
    };
  }
}