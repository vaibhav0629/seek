import 'package:seek/features/chat/domain/entities/message.dart';

/// Chat messages. Firestore path: chats/{chatId}/messages/{messageId}
/// For a club chat, chatId is the clubId.
abstract class ChatRepository {
  /// Messages in a chat, oldest first.
  Stream<List<Message>> watchMessages(String chatId);

  /// Pass a message with an empty id. The repository assigns the id and,
  /// if sentAt is null, the send time.
  Future<void> sendMessage(Message message);
}
