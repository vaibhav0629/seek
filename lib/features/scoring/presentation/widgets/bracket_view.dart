import 'package:flutter/material.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/presentation/widgets/match_score_card.dart';

/// Bagan babak gugur: satu kolom per round, bisa digeser ke samping.
class BracketView extends StatelessWidget {
  const BracketView({
    super.key,
    required this.matches,
    required this.playerNames,
    this.onMatchTap,
  });

  final List<GameMatch> matches;
  final Map<String, String> playerNames;
  final void Function(GameMatch match)? onMatchTap;

  String _roundTitle(int round, int totalRounds) {
    if (round == totalRounds) return 'Final';
    if (round == totalRounds - 1) return 'Semi Final';
    return 'Round $round';
  }

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(child: Text('Bagan belum tersedia.'));
    }
    final byRound = <int, List<GameMatch>>{};
    for (final m in matches) {
      byRound.putIfAbsent(m.round, () => []).add(m);
    }
    final rounds = byRound.keys.toList()..sort();
    final total = rounds.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in rounds)
            SizedBox(
              width: 260,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _roundTitle(r, total),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final m
                      in (byRound[r]!
                        ..sort((a, b) => a.position.compareTo(b.position))))
                    MatchScoreCard(
                      match: m,
                      playerNames: playerNames,
                      onTap:
                          (onMatchTap != null &&
                              m.teamA.isNotEmpty &&
                              m.teamB.isNotEmpty &&
                              m.status != MatchStatus.finished)
                          ? () => onMatchTap!(m)
                          : null,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
