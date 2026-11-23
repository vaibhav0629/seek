import 'package:flutter/material.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/presentation/widgets/match_score_card.dart';


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
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in rounds)
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _roundTitle(r, total),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  for (final m in (byRound[r]!
                    ..sort((a, b) => a.position.compareTo(b.position))))
                    _BracketCard(
                      match: m,
                      playerNames: playerNames,
                      onTap: (onMatchTap != null &&
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

class _BracketCard extends StatelessWidget {
  const _BracketCard({
    required this.match,
    required this.playerNames,
    this.onTap,
  });

  final GameMatch match;
  final Map<String, String> playerNames;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final winner = match.winner;

    Widget row(List<String> ids, int? score, bool isWinner) => Row(
          children: [
            Expanded(
              child: Text(
                ids.isEmpty ? '-' : teamLabel(ids, playerNames),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              score?.toString() ?? '-',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _statusText(match.status),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              row(match.teamA, match.scoreA, winner == TeamSide.a),
              const SizedBox(height: 2),
              row(match.teamB, match.scoreB, winner == TeamSide.b),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Ketuk: input skor',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(MatchStatus s) => switch (s) {
        MatchStatus.scheduled => 'Terjadwal',
        MatchStatus.inProgress => 'Berlangsung',
        MatchStatus.finished => 'Selesai',
      };
}