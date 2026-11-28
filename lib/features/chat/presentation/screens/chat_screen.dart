import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/core/widgets/empty_state.dart';
import 'package:seek/core/widgets/loading_view.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/chat/data/chat_providers.dart';
import 'package:seek/features/chat/domain/entities/message.dart';
import 'package:seek/features/chat/presentation/widgets/message_bubble.dart';
import 'package:seek/features/chat/presentation/widgets/message_input.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/notifications/data/notification_actions.dart';
import 'package:seek/features/notifications/data/notification_providers.dart';
import 'package:seek/features/profile/data/profile_providers.dart';

/// Group chat of one club (chatId is the clubId). Only members can open it.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final clubName = ref.watch(clubProvider(clubId)).value?.name ?? 'Club chat';
    final membersAsync = ref.watch(clubMembersProvider(clubId));

    return Scaffold(
      appBar: AppBar(title: Text(clubName)),
      body: membersAsync.when(
        loading: () => const LoadingView(),
        error: (error, stack) => const EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load the chat',
        ),
        data: (members) {
          final isMember =
              userId != null && members.any((m) => m.userId == userId);
          if (!isMember) {
            return const EmptyState(
              icon: Icons.lock_outline,
              title: 'Members only',
              message: 'Join this club to read and send messages.',
            );
          }
          return _ChatView(clubId: clubId);
        },
      ),
    );
  }
}

/// The message list and the input bar.
class _ChatView extends ConsumerStatefulWidget {
  const _ChatView({required this.clubId});

  final String clubId;

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // No notification banner for the chat I am reading.
    activeChatId.value = widget.clubId;
  }

  @override
  void dispose() {
    if (activeChatId.value == widget.clubId) activeChatId.value = null;
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    // The sender's name comes from the profile.
    final name = ref.read(currentUserProvider).value?.displayName ?? 'Player';

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            Message(
              id: '',
              chatId: widget.clubId,
              senderId: userId,
              senderName: name,
              text: text,
            ),
          );
      // Tell the other members of the club.
      await notifyClubMembers(
        ref,
        clubId: widget.clubId,
        senderId: userId,
        senderName: name,
        text: text,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send the message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.clubId));
    final userId = ref.watch(currentUserIdProvider);

    // Scroll down whenever a new message arrives.
    ref.listen<AsyncValue<List<Message>>>(
      messagesProvider(widget.clubId),
      (previous, next) {
        final before = previous?.value?.length ?? 0;
        final after = next.value?.length ?? 0;
        if (after != before) _scrollToBottom();
      },
    );

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            loading: () => const LoadingView(),
            error: (error, stack) => const EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load messages',
            ),
            data: (messages) {
              if (messages.isEmpty) {
                return const EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'No messages yet',
                  message: 'Say hi to your club!',
                );
              }
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final previous = index > 0 ? messages[index - 1] : null;
                  final showName = previous == null ||
                      previous.isSystem ||
                      previous.senderId != message.senderId;
                  return MessageBubble(
                    message: message,
                    isMine: message.senderId == userId,
                    showSenderName: showName,
                  );
                },
              );
            },
          ),
        ),
        MessageInput(onSend: _send),
      ],
    );
  }
}