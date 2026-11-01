import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/chat/data/mock_chat_repository.dart';
import 'package:seek/features/chat/domain/entities/message.dart';
import 'package:seek/features/chat/domain/repositories/chat_repository.dart';

/// To switch to Firebase, return FirestoreChatRepository() here instead.
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => MockChatRepository(),
);

/// Messages of a chat, oldest first. For a club chat, chatId is the clubId.
final messagesProvider = StreamProvider.family<List<Message>, String>(
  (ref, chatId) => ref.watch(chatRepositoryProvider).watchMessages(chatId),
);
