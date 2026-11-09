import 'package:flutter/material.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/domain/standings.dart';
import 'package:seek/features/scoring/presentation/widgets/match_score_card.dart';

class StandingsTable extends StatelessWidget {
  const StandingsTable({
    super.key,
    required this.matches,
    required this.playerNames,
  });

  final List<GameMatch> matches;
  final Map<String, String> playerNames;

  @override
  Widget build(BuildContext context) {
    final rows = computeStandings(matches);
    if (rows.isEmpty) {
      return const Center(child: Text('Belum ada klasemen.'));
    }

    final header = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(fontWeight: FontWeight.bold);

    Widget cell(String text, double width,
            {TextAlign align = TextAlign.center, TextStyle? style}) =>
        SizedBox(
          width: width,
          child: Text(text, textAlign: align, style: style),
        );

    Widget line(
      String rank,
      Widget team,
      List<String> nums, {
      TextStyle? style,
      Color? background,
    }) =>
        Container(
          color: background,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              cell(rank, 24, style: style),
              const SizedBox(width: 8),
              Expanded(child: team),
              cell(nums[0], 28, style: style),
              cell(nums[1], 28, style: style),
              cell(nums[2], 28, style: style),
              cell(nums[3], 28, style: style),
              cell(nums[4], 40, style: style),
              cell(nums[5], 36,
                  style: (style ?? const TextStyle())
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        );

    return ListView(
      children: [
        line(
          '#',
          Text('Tim', style: header),
          const ['M', 'W', 'D', 'L', '+/-', 'Pts'],
          style: header,
          background: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        for (var i = 0; i < rows.length; i++) ...[
          line(
            '${i + 1}',
            Text(
              teamLabel(rows[i].team, playerNames),
              overflow: TextOverflow.ellipsis,
            ),
            [
              '${rows[i].played}',
              '${rows[i].won}',
              '${rows[i].drawn}',
              '${rows[i].lost}',
              '${rows[i].diff}',
              '${rows[i].points}',
            ],
          ),
          const Divider(height: 1),
        ],
      ],
    );
  }
}