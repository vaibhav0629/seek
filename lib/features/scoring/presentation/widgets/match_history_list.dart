import 'package:flutter/material.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/presentation/widgets/match_score_card.dart';

/// Riwayat match yang sudah selesai, terbaru di atas.
class MatchHistoryList extends StatelessWidget {
  const MatchHistoryList({
    super.key,
    required this.matches,
    required this.playerNames,
  });

  final List<GameMatch> matches;
  final Map<String, String> playerNames;

  @override
  Widget build(BuildContext context) {
    final finished = matches
        .where((m) => m.status == MatchStatus.finished)
        .toList()
      ..sort((a, b) {
        final pa = a.playedAt;
        final pb = b.playedAt;
        if (pa == null && pb == null) return 0;
        if (pa == null) return 1;
        if (pb == null) return -1;
        return pb.compareTo(pa);
      });

    if (finished.isEmpty) {
      return const Center(child: Text('Belum ada match yang selesai.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: finished.length,
      itemBuilder: (context, i) {
        final m = finished[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.playedAt != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
                child: Text(
                  _formatDate(m.playedAt!),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            MatchScoreCard(match: m, playerNames: playerNames),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}