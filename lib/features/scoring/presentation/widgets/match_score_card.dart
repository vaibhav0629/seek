import 'package:flutter/material.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';

String teamLabel(List<String> ids, Map<String, String> names) =>
    ids.map((id) => names[id] ?? id).join(' & ');

class MatchScoreCard extends StatelessWidget {
  const MatchScoreCard({
    super.key,
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
    final finished = match.status == MatchStatus.finished;

    Widget teamRow(List<String> ids, int? score, bool isWinner) => Row(
      children: [
        Expanded(
          child: Text(
            teamLabel(ids, playerNames),
            style: TextStyle(
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          score?.toString() ?? '-',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Round ${match.round} - Match ${match.position}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  if (match.court != null) Text('  |  Court ${match.court}'),
                  const Spacer(),
                  Chip(
                    label: Text(_statusText(match.status)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              teamRow(match.teamA, match.scoreA, winner == TeamSide.a),
              const SizedBox(height: 4),
              teamRow(match.teamB, match.scoreB, winner == TeamSide.b),
              if (finished && winner == null)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Seri (1 poin masing-masing)'),
                ),
              if (onTap != null && !finished)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Ketuk untuk input skor'),
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
