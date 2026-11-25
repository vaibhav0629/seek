import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/competitions/data/competition_providers.dart';
import 'package:seek/features/competitions/domain/entities/competition.dart';
import 'package:seek/features/scoring/data/match_providers.dart';
import 'package:seek/features/scoring/domain/round_robin.dart';

/// Jadwal round robin turnamen dari daftar [playerIds].
class GenerateCompetitionRoundRobinButton extends ConsumerStatefulWidget {
  const GenerateCompetitionRoundRobinButton({
    super.key,
    required this.competition,
  });

  final Competition competition;

  @override
  ConsumerState<GenerateCompetitionRoundRobinButton> createState() =>
      _GenerateCompetitionRoundRobinButtonState();
}

class _GenerateCompetitionRoundRobinButtonState
    extends ConsumerState<GenerateCompetitionRoundRobinButton> {
  var _busy = false;

  Future<void> _generate() async {
    final comp = widget.competition;
    if (comp.playerIds.length < 2) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal 2 pemain terdaftar.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final teams = teamsForMeetRoundRobin(
        sport: comp.sport,
        playerIds: comp.playerIds,
      );
      final matches = generateRoundRobin(
        teams: teams,
        idPrefix: comp.id,
        competitionId: comp.id,
      );
      await ref.read(matchRepositoryProvider).saveMatches(matches);
      await ref.read(competitionRepositoryProvider).updateCompetition(
            comp.copyWith(status: CompetitionStatus.inProgress),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jadwal dibuat (${matches.length} match).')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.competition.playerIds.length;
    return FilledButton.icon(
      onPressed: _busy || n < 2 ? null : _generate,
      icon: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.event_note),
      label: Text(
        _busy ? 'Membuat jadwal...' : 'Generate jadwal round robin',
      ),
    );
  }
}
