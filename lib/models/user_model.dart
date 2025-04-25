import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String imageUrl;
  final DateTime updatedAt;
  final List<String> chatsIds;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.imageUrl,
    required this.updatedAt,
    required this.chatsIds,
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return User(
      userId: snapshot.id,
      firstName: data['first_name'],
      lastName: data['last_name'],
      email: data['email'],
      imageUrl: data['image_url'],
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      chatsIds: List<String>.from(data['chats_ids']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'image_url': imageUrl,
      'updated_at': FieldValue.serverTimestamp(),
      'chats_ids': chatsIds,
    };
  }
}
