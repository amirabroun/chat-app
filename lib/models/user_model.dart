import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? imageUrl;
  final bool? isAdmin;
  final DateTime? updatedAt;
  final List<String>? chatsIds;

  User({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    this.imageUrl,
    this.isAdmin,
    this.updatedAt,
    this.chatsIds,
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return User(
      userId: snapshot.id,
      email: data['email'] ?? '',
      firstName: data['first_name'],
      lastName: data['last_name'],
      imageUrl: data['image_url'],
      isAdmin: data['is_admin'] ?? false,
      updatedAt: data['updated_at']?.toDate(),
      chatsIds:
          data['chats_ids'] != null
              ? List<String>.from(data['chats_ids'])
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isAdmin != null) 'is_admin': isAdmin,
      if (chatsIds != null) 'chats_ids': chatsIds,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
