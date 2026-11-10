import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';

class JoinClubButton extends ConsumerStatefulWidget {
  final Club club;

  /// Nama user yang disimpan ke data member saat join.
  final String userName;

  const JoinClubButton({
    super.key,
    required this.club,
    this.userName = 'Pengguna',
  });

  @override
  ConsumerState<JoinClubButton> createState() => _JoinClubButtonState();
}

class _JoinClubButtonState extends ConsumerState<JoinClubButton> {
  bool _loading = false;

  Future<void> _run(Future<void> Function() action, String successMsg) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(successMsg)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan, coba lagi')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final userId = ref.watch(currentUserIdProvider);
    final members =
        ref.watch(clubMembersProvider(club.id)).asData?.value ?? const [];
    final repo = ref.read(clubRepositoryProvider);

    if (userId == null) {
      return const FilledButton(onPressed: null, child: Text('Login dulu'));
    }

    // Owner nggak boleh keluar dari clubnya sendiri
    if (club.ownerId == userId) {
      return const OutlinedButton(onPressed: null, child: Text('Owner'));
    }

    final isMember = members.any((m) => m.userId == userId);

    if (_loading) {
      return const FilledButton(
        onPressed: null,
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (isMember) {
      return OutlinedButton(
        onPressed: () => _run(
              () => repo.leaveClub(clubId: club.id, userId: userId),
          'Kamu keluar dari ${club.name}',
        ),
        child: const Text('Keluar'),
      );
    }

    return FilledButton(
      onPressed: () => _run(
            () => repo.joinClub(
          clubId: club.id,
          userId: userId,
          userName: widget.userName,
        ),
        'Berhasil gabung ke ${club.name}',
      ),
      child: Text(club.isPrivate ? 'Gabung (Private)' : 'Gabung'),
    );
  }
}