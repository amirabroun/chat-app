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

  Future<User> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return User.fromFirestore(doc);
  }

  Stream<User> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => User.fromFirestore(snapshot));
  }

  Stream<List<ChatMessage>> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('chats/$chatId/messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatMessage.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final message = {
      'sender_id': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
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

  Future<List<ChatMessage>> getPaginatedMessages(
    String chatId, {
    int limit = 20,
    ChatMessage? lastMessage,
  }) async {
    final messagesRef = _firestore
        .collection('chats/$chatId/messages')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (data, _) => data,
        );

    Query<Map<String, dynamic>> query = messagesRef
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastMessage != null) {
      query = query.startAfter([lastMessage.timestamp]);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return ChatMessage.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>,
      );
    }).toList();
  }

  Future<void> createNewChat({
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

    final batch = _firestore.batch();
    for (final userId in participantIds) {
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'chats_ids': FieldValue.arrayUnion([chatRef.id]),
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Stream<List<Chat>> getUserChatsStream(String userId) {
    return _usersRef
        .doc(userId)
        .snapshots()
        .asyncMap((userSnapshot) async {
          if (!userSnapshot.exists) return [];

          final user = userSnapshot.data()!;
          final chatIds = user.chatsIds;

          if (chatIds.isEmpty) return [];

          final chatsQuery = _chatsRef
              .where(FieldPath.documentId, whereIn: chatIds)
              .orderBy('updated_at', descending: true);

          final chatsSnapshot = await chatsQuery.get();

          return chatsSnapshot.docs.map((doc) => doc.data()).toList();
        })
        .asyncExpand((chats) {
          if (chats.isEmpty) return Stream.value([]);

          final chatIds = chats.map((c) => c.chatId).toList();
          return _chatsRef
              .where(FieldPath.documentId, whereIn: chatIds)
              .orderBy('updated_at', descending: true)
              .snapshots()
              .map(
                (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
              );
        });
  }
}
