import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/competitions/data/competition_providers.dart';
import 'package:seek/features/competitions/domain/entities/competition.dart';

/// Daftar / keluar dari pendaftaran turnamen (fase [CompetitionStatus.registration]).
class RegisterCompetitionButton extends ConsumerStatefulWidget {
  const RegisterCompetitionButton({super.key, required this.competition});

  final Competition competition;

  @override
  ConsumerState<RegisterCompetitionButton> createState() =>
      _RegisterCompetitionButtonState();
}

class _RegisterCompetitionButtonState
    extends ConsumerState<RegisterCompetitionButton> {
  var _busy = false;

  Future<void> _register() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(competitionRepositoryProvider).registerPlayer(
            competitionId: widget.competition.id,
            userId: userId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamu terdaftar di turnamen ini.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendaftar: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comp = widget.competition;
    final userId = ref.watch(currentUserIdProvider);

    if (comp.status != CompetitionStatus.registration) {
      return const SizedBox.shrink();
    }

    if (userId == null) {
      return const FilledButton(
        onPressed: null,
        child: Text('Login untuk mendaftar'),
      );
    }

    final registered = comp.playerIds.contains(userId);
    final full = comp.playerIds.length >= comp.maxPlayers;

    if (registered) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Sudah terdaftar'),
      );
    }

    if (full) {
      return const OutlinedButton(
        onPressed: null,
        child: Text('Kuota penuh'),
      );
    }

    return FilledButton.icon(
      onPressed: _busy ? null : _register,
      icon: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.how_to_reg),
      label: Text(_busy ? 'Mendaftar...' : 'Daftar turnamen'),
    );
  }
}
