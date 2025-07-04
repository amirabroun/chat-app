import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final List<String> seenBy;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.seenBy = const [],
  });

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return ChatMessage(
      messageId: snapshot.id,
      senderId: data['sender_id'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      seenBy: List<String>.from(data['seen_by'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sender_id': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'seen_by': seenBy,
    };
  }
}
