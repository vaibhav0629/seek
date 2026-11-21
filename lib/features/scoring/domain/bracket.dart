import 'package:seek/features/scoring/domain/entities/game_match.dart';

/// Mengembalikan daftar match yang perlu disimpan setelah [finished] selesai:
/// match itu sendiri, dan match berikutnya dengan pemenang sudah dimasukkan.
/// Kalau seri atau tidak ada nextMatchId, hanya match itu yang dikembalikan.
List<GameMatch> advanceWinner({
  required GameMatch finished,
  required List<GameMatch> allMatches,
}) {
  final winnerSide = finished.winner;
  final nextId = finished.nextMatchId;
  final nextSide = finished.nextMatchSide;
  if (winnerSide == null || nextId == null || nextSide == null) {
    return [finished];
  }

  final winnerTeam = winnerSide == TeamSide.a ? finished.teamA : finished.teamB;
  final idx = allMatches.indexWhere((m) => m.id == nextId);
  if (idx == -1) return [finished];

  final next = allMatches[idx];
  final updatedNext = next.copyWith(
    teamA: nextSide == TeamSide.a ? winnerTeam : next.teamA,
    teamB: nextSide == TeamSide.b ? winnerTeam : next.teamB,
  );
  return [finished, updatedNext];
}
