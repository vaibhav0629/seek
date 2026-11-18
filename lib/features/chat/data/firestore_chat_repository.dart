import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seek/features/chat/domain/entities/message.dart';
import 'package:seek/features/chat/domain/repositories/chat_repository.dart';

/// The real chat. Messages live at chats/{chatId}/messages/{messageId}.
/// For a club chat, chatId is the clubId.
class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _db.collection('chats').doc(chatId).collection('messages');

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return _messages(chatId).orderBy('sentAt').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<void> sendMessage(Message message) async {
    final collection = _messages(message.chatId);
    final doc = message.id.isEmpty ? collection.doc() : collection.doc(message.id);

    final data = message.toMap();
    // No send time given: let the server stamp it, so every phone agrees.
    if (message.sentAt == null) {
      data['sentAt'] = FieldValue.serverTimestamp();
    }
    await doc.set(data);
  }
}