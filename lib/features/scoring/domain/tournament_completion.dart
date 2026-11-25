import 'package:seek/features/competitions/domain/entities/competition.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';

/// ID juara dari match final babak gugur (satu user per tim).
String? championFromBracket(List<GameMatch> matches) {
  if (matches.isEmpty) return null;
  final maxRound = matches.map((m) => m.round).reduce((a, b) => a > b ? a : b);
  final finals = matches
      .where((m) => m.round == maxRound)
      .toList()
    ..sort((a, b) => a.position.compareTo(b.position));
  if (finals.isEmpty) return null;
  final fin = finals.first;
  final side = fin.winner;
  if (side == null) return null;
  final team = side == TeamSide.a ? fin.teamA : fin.teamB;
  return team.isNotEmpty ? team.first : null;
}

bool isBracketComplete(List<GameMatch> matches) {
  if (matches.isEmpty) return false;
  final maxRound = matches.map((m) => m.round).reduce((a, b) => a > b ? a : b);
  final fin = matches.where((m) => m.round == maxRound).toList();
  return fin.isNotEmpty &&
      fin.every((m) => m.status == MatchStatus.finished && m.winner != null);
}

/// Setelah skor disimpan, kembalikan competition yang perlu di-update (atau null).
Competition? competitionAfterBracketScore({
  required Competition competition,
  required List<GameMatch> matches,
}) {
  if (competition.format != CompetitionFormat.singleElimination) return null;
  if (competition.status == CompetitionStatus.finished) return null;
  if (!isBracketComplete(matches)) return null;
  final champ = championFromBracket(matches);
  if (champ == null) return null;
  return competition.copyWith(
    status: CompetitionStatus.finished,
    championId: champ,
  );
}

/// Round robin: semua match selesai tanpa seri → status finished (tanpa champion wajib).
Competition? competitionAfterRoundRobinComplete({
  required Competition competition,
  required List<GameMatch> matches,
}) {
  if (competition.format != CompetitionFormat.roundRobin) return null;
  if (competition.status == CompetitionStatus.finished) return null;
  if (matches.isEmpty) return null;
  final allDone = matches.every(
    (m) => m.status == MatchStatus.finished && m.winner != null,
  );
  if (!allDone) return null;
  return competition.copyWith(status: CompetitionStatus.finished);
}
