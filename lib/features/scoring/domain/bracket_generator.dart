import 'dart:math' as math;

import 'package:seek/features/competitions/domain/entities/competition.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';

/// Urutan pemain berdasarkan seed (1 = teratas). Pemain tanpa seed di belakang.
List<String> playersOrderedBySeed({
  required List<String> playerIds,
  Map<String, int> seeds = const {},
}) {
  final ranked = <int, String>{};
  final unseeded = <String>[];
  for (final id in playerIds) {
    final s = seeds[id];
    if (s != null) {
      ranked[s] = id;
    } else {
      unseeded.add(id);
    }
  }
  var next = ranked.keys.fold(0, math.max) + 1;
  for (final id in unseeded) {
    while (ranked.containsKey(next)) {
      next++;
    }
    ranked[next] = id;
    next++;
  }
  final order = ranked.keys.toList()..sort();
  return [for (final k in order) ranked[k]!];
}

/// Penempatan seed standar babak gugur (ukuran harus pangkat 2).
List<int> bracketSeedOrder(int bracketSize) {
  assert(bracketSize >= 2 && (bracketSize & (bracketSize - 1)) == 0);
  if (bracketSize == 2) return [1, 2];
  final half = bracketSeedOrder(bracketSize ~/ 2);
  return [
    for (final s in half) ...[s, bracketSize + 1 - s],
  ];
}

Map<String, int> seedsFromPlayerOrder(List<String> ordered) => {
      for (var i = 0; i < ordered.length; i++) ordered[i]: i + 1,
    };

String _matchId(String competitionId, int round, int position, int totalRounds) {
  if (round == totalRounds) return '$competitionId-final';
  if (totalRounds == 2) return '$competitionId-sf${position + 1}';
  return '$competitionId-r$round-${position + 1}';
}

/// Membuat match babak gugur + [nextMatchId] / [nextMatchSide].
List<GameMatch> generateSingleEliminationBracket({
  required Competition competition,
}) {
  final players = playersOrderedBySeed(
    playerIds: competition.playerIds,
    seeds: competition.seeds,
  );
  if (players.length < 2) return [];

  var bracketSize = 2;
  while (bracketSize < players.length) {
    bracketSize *= 2;
  }
  final totalRounds = (math.log(bracketSize) / math.ln2).round();

  final matchesByRound = <int, List<GameMatch>>{};
  for (var r = 1; r <= totalRounds; r++) {
    final count = bracketSize >> r;
    matchesByRound[r] = [
      for (var p = 0; p < count; p++)
        GameMatch(
          id: _matchId(competition.id, r, p, totalRounds),
          competitionId: competition.id,
          round: r,
          position: p,
          teamA: const [],
          teamB: const [],
        ),
    ];
  }

  for (var r = 1; r < totalRounds; r++) {
    final current = matchesByRound[r]!;
    final next = matchesByRound[r + 1]!;
    for (var p = 0; p < current.length; p++) {
      final m = current[p];
      final parent = next[p >> 1];
      current[p] = GameMatch(
        id: m.id,
        competitionId: m.competitionId,
        round: m.round,
        position: m.position,
        teamA: m.teamA,
        teamB: m.teamB,
        nextMatchId: parent.id,
        nextMatchSide: p.isEven ? TeamSide.a : TeamSide.b,
      );
    }
  }

  final seedOrder = bracketSeedOrder(bracketSize);
  final slots = List<String?>.filled(bracketSize, null);
  for (var i = 0; i < bracketSize; i++) {
    final rank = seedOrder[i];
    if (rank <= players.length) {
      slots[i] = players[rank - 1];
    }
  }

  final round1 = matchesByRound[1]!;
  for (var p = 0; p < round1.length; p++) {
    final a = slots[p * 2];
    final b = slots[p * 2 + 1];
    round1[p] = round1[p].copyWith(
      teamA: a != null ? [a] : const [],
      teamB: b != null ? [b] : const [],
    );
  }

  var all = <GameMatch>[];
  for (var r = 1; r <= totalRounds; r++) {
    all = [...all, ...matchesByRound[r]!];
  }
  return applyBracketByeAdvances(all);
}

/// Auto-advance jika lawan bye (tim kosong).
List<GameMatch> applyBracketByeAdvances(List<GameMatch> matches) {
  final byId = {for (final m in matches) m.id: m};
  var changed = true;
  while (changed) {
    changed = false;
    for (var i = 0; i < matches.length; i++) {
      final m = matches[i];
      if (m.status == MatchStatus.finished) continue;
      if (m.round != 1) continue;

      final hasA = m.teamA.isNotEmpty;
      final hasB = m.teamB.isNotEmpty;
      if (!hasA && !hasB) continue;
      if (hasA && hasB) continue;

      final winner = hasA ? m.teamA : m.teamB;
      final finished = m.copyWith(
        scoreA: hasA ? 1 : 0,
        scoreB: hasB ? 1 : 0,
        status: MatchStatus.finished,
      );
      matches[i] = finished;
      byId[m.id] = finished;
      changed = true;

      final nextId = m.nextMatchId;
      final side = m.nextMatchSide;
      if (nextId == null || side == null) continue;
      final nextIdx = matches.indexWhere((x) => x.id == nextId);
      if (nextIdx == -1) continue;
      final next = matches[nextIdx];
      final updated = next.copyWith(
        teamA: side == TeamSide.a ? winner : next.teamA,
        teamB: side == TeamSide.b ? winner : next.teamB,
      );
      matches[nextIdx] = updated;
      byId[nextId] = updated;
    }
  }
  return matches;
}
