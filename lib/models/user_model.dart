import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? imageUrl;
  final DateTime? updatedAt;

  User({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.imageUrl,
    this.updatedAt,
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return User(
      userId: snapshot.id,
      email: data['email'] ?? '',
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      imageUrl: data['image_url'],
      updatedAt: data['updated_at']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      if (imageUrl != null) 'image_url': imageUrl,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
