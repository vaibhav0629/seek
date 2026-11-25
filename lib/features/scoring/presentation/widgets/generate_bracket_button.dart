import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/competitions/data/competition_providers.dart';
import 'package:seek/features/competitions/domain/entities/competition.dart';
import 'package:seek/features/scoring/data/match_providers.dart';
import 'package:seek/features/scoring/domain/bracket_generator.dart';

/// Membuat bagan babak gugur dari pemain terdaftar + seeding.
class GenerateBracketButton extends ConsumerStatefulWidget {
  const GenerateBracketButton({super.key, required this.competition});

  final Competition competition;

  @override
  ConsumerState<GenerateBracketButton> createState() =>
      _GenerateBracketButtonState();
}

class _GenerateBracketButtonState extends ConsumerState<GenerateBracketButton> {
  var _busy = false;

  Future<void> _generate() async {
    final comp = widget.competition;
    if (comp.playerIds.length < 2) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal 2 pemain terdaftar untuk bagan.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final ordered = playersOrderedBySeed(
        playerIds: comp.playerIds,
        seeds: comp.seeds,
      );
      final seeds = comp.seeds.isEmpty
          ? seedsFromPlayerOrder(ordered)
          : comp.seeds;
      final seeded = comp.copyWith(seeds: seeds);
      final matches = generateSingleEliminationBracket(competition: seeded);
      if (matches.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada match yang bisa dibuat.')),
        );
        return;
      }
      await ref.read(matchRepositoryProvider).saveMatches(matches);
      await ref.read(competitionRepositoryProvider).updateCompetition(
            seeded.copyWith(status: CompetitionStatus.inProgress),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bagan dibuat (${matches.length} match).')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat bagan: $e')),
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
          : const Icon(Icons.account_tree_outlined),
      label: Text(_busy ? 'Membuat bagan...' : 'Generate bracket + seeding'),
    );
  }
}
