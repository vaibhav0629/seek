import 'package:seek/features/scoring/domain/entities/game_match.dart';

List<GameMatch> generateRoundRobin({
  required List<List<String>> teams,
  required String idPrefix,
  String? meetId,
  String? competitionId,
}) {
  final list = List<List<String>?>.from(teams);
  if (list.length.isOdd) list.add(null); // null = bye
  final n = list.length;
  final matches = <GameMatch>[];

  for (var r = 0; r < n - 1; r++) {
    var pos = 0;
    for (var i = 0; i < n ~/ 2; i++) {
      final a = list[i];
      final b = list[n - 1 - i];
      if (a == null || b == null) continue;
      pos++;
      matches.add(
        GameMatch(
          id: '$idPrefix-r${r + 1}-$pos',
          meetId: meetId,
          competitionId: competitionId,
          round: r + 1,
          position: pos,
          teamA: a,
          teamB: b,
        ),
      );
    }
    list.insert(1, list.removeLast());
  }
  return matches;
}
