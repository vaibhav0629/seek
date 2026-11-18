import 'package:flutter_test/flutter_test.dart';
import 'package:seek/features/chat/data/mock_chat_repository.dart';
import 'package:seek/features/chat/domain/entities/message.dart';

void main() {
  test('messages of a chat come back oldest first', () async {
    final repository = MockChatRepository();

    final messages = await repository.watchMessages('c1').first;

    expect(messages.map((m) => m.id).toList(), ['msg1', 'msg2', 'msg3']);
  });

  test('sendMessage adds the message to that chat only', () async {
    final repository = MockChatRepository();

    await repository.sendMessage(
      const Message(
        id: '',
        chatId: 'c2',
        senderId: 'u1',
        senderName: 'Budi Santoso',
        text: 'Hello c2',
      ),
    );

    final c2 = await repository.watchMessages('c2').first;
    final c1 = await repository.watchMessages('c1').first;
    expect(c2.map((m) => m.text), contains('Hello c2'));
    expect(c1.map((m) => m.text), isNot(contains('Hello c2')));
  });
}