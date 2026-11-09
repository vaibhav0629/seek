import 'package:seek/features/scoring/domain/entities/game_match.dart';

class StandingRow {
  StandingRow(this.team);
  final List<String> team;
  int played = 0, won = 0, drawn = 0, lost = 0;
  int pointsFor = 0, pointsAgainst = 0;

  int get points => won * 3 + drawn;
  int get diff => pointsFor - pointsAgainst;
}

List<StandingRow> computeStandings(List<GameMatch> matches) {
  final rows = <String, StandingRow>{};
  StandingRow rowOf(List<String> t) =>
      rows.putIfAbsent(t.join('+'), () => StandingRow(t));

  for (final m in matches) {
    final a = rowOf(m.teamA);
    final b = rowOf(m.teamB);
    if (m.status != MatchStatus.finished ||
        m.scoreA == null ||
        m.scoreB == null) {
      continue;
    }
    final sa = m.scoreA!, sb = m.scoreB!;
    a.played++;
    b.played++;
    a.pointsFor += sa;
    a.pointsAgainst += sb;
    b.pointsFor += sb;
    b.pointsAgainst += sa;
    if (sa > sb) {
      a.won++;
      b.lost++;
    } else if (sb > sa) {
      b.won++;
      a.lost++;
    } else {
      a.drawn++;
      b.drawn++;
    }
  }

  return rows.values.toList()..sort((x, y) {
    final byPoints = y.points.compareTo(x.points);
    if (byPoints != 0) return byPoints;
    final byDiff = y.diff.compareTo(x.diff);
    if (byDiff != 0) return byDiff;
    return y.pointsFor.compareTo(x.pointsFor);
  });
}
