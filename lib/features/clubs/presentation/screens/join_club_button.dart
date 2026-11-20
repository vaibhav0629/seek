import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/profile/data/profile_providers.dart';

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
  bool _confirming = false;

  Future<void> _confirmLeave(Future<void> Function() action) async {
    if (_loading || _confirming) return;
    _confirming = true;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Keluar dari club?'),
          content: Text('Kamu akan keluar dari ${widget.club.name}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya, keluar'),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
      await _run(action, 'Kamu keluar dari ${widget.club.name}');
    } finally {
      _confirming = false;
    }
  }

  Future<void> _run(Future<void> Function() action, String successMsg) async {
    if (_loading) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      await action();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(successMsg)));
    } catch (_) {
      if (!mounted) return;
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
    final profileName = ref.watch(currentUserProvider).value?.displayName;
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
        onPressed: () => _confirmLeave(
          () => repo.leaveClub(clubId: club.id, userId: userId),
        ),
        child: const Text('Keluar'),
      );
    }

    return FilledButton(
      onPressed: () => _run(
        () => repo.joinClub(
          clubId: club.id,
          userId: userId,
          userName: profileName ?? widget.userName,
        ),
        'Berhasil gabung ke ${club.name}',
      ),
      child: Text(club.isPrivate ? 'Gabung (Private)' : 'Gabung'),
    );
  }
}
