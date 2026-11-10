import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart'; // sesuaikan path file providers lo
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/clubs/presentation/screens/club_member_tile.dart';

class ClubMembersList extends ConsumerWidget {
  final Club club;

  const ClubMembersList({super.key, required this.club});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(clubMembersProvider(club.id));
    final currentUserId = ref.watch(currentUserIdProvider);

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('Gagal memuat member')),
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text('Belum ada member'));
        }

        // Salin dulu sebelum sort, urutan: owner, admin, member
        final members = [...data]..sort((a, b) => _rank(a).compareTo(_rank(b)));

        final iAmAdmin = currentUserId != null &&
            (club.ownerId == currentUserId ||
                members.any((m) =>
                m.userId == currentUserId && m.role == ClubRole.admin));

        return ListView.separated(
          itemCount: members.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final member = members[index];
            final isOwner = member.userId == club.ownerId;
            final isMe = member.userId == currentUserId;

            return ClubMemberTile(
              member: member,
              isOwner: isOwner,
              showActions: iAmAdmin && !isOwner && !isMe,
              onAction: (action) =>
                  _handleAction(context, ref, member, action),
            );
          },
        );
      },
    );
  }

  Future<void> _handleAction(
      BuildContext context,
      WidgetRef ref,
      ClubMember member,
      MemberAction action,
      ) async {
    final repo = ref.read(clubRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);

    try {
      switch (action) {
        case MemberAction.promote:
          await repo.promoteMember(clubId: club.id, userId: member.userId);
          messenger.showSnackBar(
            SnackBar(content: Text('${member.userName} jadi admin')),
          );
        case MemberAction.kick:
          final confirmed = await _confirmKick(context, member);
          if (confirmed != true) return;
          await repo.kickMember(clubId: club.id, userId: member.userId);
          messenger.showSnackBar(
            SnackBar(content: Text('${member.userName} dikeluarkan')),
          );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan, coba lagi')),
      );
    }
  }

  Future<bool?> _confirmKick(BuildContext context, ClubMember member) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluarkan member?'),
        content: Text('${member.userName} akan dikeluarkan dari club.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluarkan'),
          ),
        ],
      ),
    );
  }

  int _rank(ClubMember m) {
    if (m.userId == club.ownerId) return 0;
    return m.role == ClubRole.admin ? 1 : 2;
  }
}