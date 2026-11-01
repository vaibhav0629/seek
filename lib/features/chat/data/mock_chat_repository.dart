import 'package:seek/core/mock/mock_data.dart';
import 'package:seek/core/mock/mock_support.dart';
import 'package:seek/features/chat/domain/entities/message.dart';
import 'package:seek/features/chat/domain/repositories/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final MockCollection<Message> _messages =
      MockCollection<Message>(mockMessages);

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return _messages.watch((messages) {
      final result = messages.where((m) => m.chatId == chatId).toList()
        ..sort((a, b) => _time(a.sentAt).compareTo(_time(b.sentAt)));
      return result;
    });
  }

  @override
  Future<void> sendMessage(Message message) async {
    await mockDelay();
    _messages.mutate(
      (items) => items.add(
        Message(
          id: message.id.isEmpty ? mockId('message') : message.id,
          chatId: message.chatId,
          senderId: message.senderId,
          senderName: message.senderName,
          text: message.text,
          sentAt: message.sentAt ?? DateTime.now(),
          isSystem: message.isSystem,
        ),
      ),
    );
  }

  DateTime _time(DateTime? value) => value ?? DateTime.fromMillisecondsSinceEpoch(0);
}
