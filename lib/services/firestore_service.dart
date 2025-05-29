import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Chat> get _chatsRef => _firestore
      .collection('chats')
      .withConverter<Chat>(
        fromFirestore: (snapshot, _) => Chat.fromFirestore(snapshot),
        toFirestore: (chat, _) => chat.toFirestore(),
      );

  CollectionReference<User> get _usersRef => _firestore
      .collection('users')
      .withConverter<User>(
        fromFirestore: (snapshot, _) => User.fromFirestore(snapshot),
        toFirestore: (user, _) => user.toFirestore(),
      );

  Future<void> createUser({
    required String userId,
    required String email,
    String firstName = '',
    String lastName = '',
    String imageUrl = '',
  }) async {
    final userRef = _usersRef.doc(userId);

    final newUser = User(
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      imageUrl: imageUrl,
      updatedAt: DateTime.now(),
    );

    await userRef.set(newUser);
  }

  Future<void> updateUser({
    required String userId,
    String? email,
    String? firstName,
    String? lastName,
    String? imageUrl,
  }) async {
    final userRef = _usersRef.doc(userId);
    final updates = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (email != null) updates['email'] = email;
    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (imageUrl != null) updates['image_url'] = imageUrl;

    await userRef.update(updates);
  }

  Future<User> getUser({required String userId}) async {
    try {
      final snapshot = await _usersRef.doc(userId).get();

      if (snapshot.exists) {
        return snapshot.data()!;
      } else {
        throw Exception('User with ID $userId does not exist');
      }
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch user: ${e.message}');
    }
  }

  Stream<User> getUserStream({required String userId}) {
    final userRef = _usersRef.doc(userId);

    return userRef.snapshots().asyncMap((DocumentSnapshot<User> snapshot) {
      if (snapshot.exists) {
        return snapshot.data()!;
      } else {
        throw Exception('User with ID $userId does not exist');
      }
    });
  }

  Future<List<User>> getChatUsers(String chatId) async {
    try {
      final chat = await getChat(chatId: chatId);
      final participantIds = chat.participants;

      if (participantIds.isEmpty) return [];

      List<User> users = [];

      for (var i = 0; i < participantIds.length; i += 10) {
        final batch = participantIds.skip(i).take(10).toList();

        final snapshot =
            await _usersRef.where(FieldPath.documentId, whereIn: batch).get();

        users.addAll(snapshot.docs.map((doc) => doc.data()));
      }

      return users;
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch chat users: ${e.message}');
    }
  }

  Future<List<User>> getUsers({String? excludeUserId}) async {
    try {
      final snapshot = await _usersRef.get();

      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs
          .map((doc) => doc.data())
          .where((doc) => excludeUserId == null || doc.userId != excludeUserId)
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch users: ${e.message}');
    }
  }

  Future<String> createNewChat({
    required List<String> participantIds,
    required ChatType type,
    String? name,
    String? imageUrl,
  }) async {
    final chatRef = _chatsRef.doc();

    await chatRef.set(
      Chat(
        chatId: chatRef.id,
        participants: participantIds,
        type: type,
        name: type == ChatType.group ? name : null,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastMessage: null,
      ),
    );

    return chatRef.id;
  }

  Future<Chat> getChat({required String chatId}) async {
    try {
      final doc = await _chatsRef.doc(chatId).get();

      if (doc.exists) {
        return doc.data()!;
      } else {
        throw Exception('Chat with ID $chatId does not exist');
      }
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch chat: ${e.message}');
    }
  }

  Future<void> updateChat({
    required String chatId,
    String? name,
    String? imageUrl,
    Map<String, dynamic>? lastMessage,
  }) async {
    final chatRef = _chatsRef.doc(chatId);
    final updates = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (lastMessage != null) updates['last_message'] = lastMessage;

    await chatRef.update(updates);
  }

  Future<void> deleteChat({required String chatId}) async {
    try {
      final chatRef = _chatsRef.doc(chatId);
      await chatRef.delete();
    } catch (e) {
      throw Exception('Error deleting chat: $e');
    }
  }

  Future<Chat?> findExistingChat({required List<String> participantIds}) async {
    try {
      if (participantIds.isEmpty) return null;

      final firstParticipantId = participantIds.first;

      final snapshot =
          await _chatsRef
              .where('participants', arrayContains: firstParticipantId)
              .get();

      final participantSet = participantIds.toSet();

      for (final doc in snapshot.docs) {
        final chat = doc.data();
        final docParticipants = chat.participants.toSet();

        final bool sameLength = docParticipants.length == participantSet.length;
        final bool sameMembers = docParticipants.containsAll(participantSet);
        final bool isDirect = chat.type == ChatType.direct;

        if (sameLength && sameMembers && isDirect) {
          return chat;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<List<Chat>> getUserChatsStream({required String userId}) {
    return _chatsRef
        .where('participants', arrayContains: userId)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<ChatMessage>> getChatMessagesStream({required String chatId}) {
    final messagesRef = _firestore.collection('chats/$chatId/messages');

    return messagesRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatMessage.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final message = {
      'sender_id': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'seen_by': [],
    };

    final batch = _firestore.batch();

    final messageRef = _firestore.collection('chats/$chatId/messages').doc();
    batch.set(messageRef, message);

    final chatRef = _chatsRef.doc(chatId);
    batch.update(chatRef, {
      'last_message': message,
      'updated_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> markMessageAsSeen({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    final messageRef = _firestore
        .collection('chats/$chatId/messages')
        .doc(messageId);
    await messageRef.update({
      'seen_by': FieldValue.arrayUnion([userId]),
    });
  }

  Stream<int> getUnseenMessageCount({
    required String chatId,
    required String userId,
  }) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('sender_id', isNotEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.where((doc) {
                final seenBy = List<String>.from(doc['seen_by'] ?? []);
                return !seenBy.contains(userId);
              }).length,
        );
  }
}
