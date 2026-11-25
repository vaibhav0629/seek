import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
bool isPadelSport(String sport) =>
    sport.trim().toLowerCase() == 'padel';

/// Teams untuk round robin meet: padel genap (≥4) → ganda berpasangan;
/// selain itu tiap pemain satu tim (1v1).
List<List<String>> teamsForMeetRoundRobin({
  required String sport,
  required List<String> playerIds,
}) {
  if (isPadelSport(sport) &&
      playerIds.length >= 4 &&
      playerIds.length.isEven) {
    return [
      for (var i = 0; i < playerIds.length; i += 2)
        [playerIds[i], playerIds[i + 1]],
    ];
  }
  return playerIds.map((id) => [id]).toList();
}

List<String> goingPlayerIdsFromRsvps(List<Rsvp> rsvps) {
  final going = rsvps.where((r) => r.status == RsvpStatus.going).toList()
    ..sort((a, b) {
      final ja = a.joinedAt, jb = b.joinedAt;
      if (ja == null && jb == null) return a.userId.compareTo(b.userId);
      if (ja == null) return 1;
      if (jb == null) return -1;
      final byJoin = ja.compareTo(jb);
      return byJoin != 0 ? byJoin : a.userId.compareTo(b.userId);
    });
  return going.map((r) => r.userId).toList();
}

List<GameMatch> generateMeetRoundRobin({
  required String meetId,
  required String sport,
  required List<String> playerIds,
}) {
  final teams = teamsForMeetRoundRobin(sport: sport, playerIds: playerIds);
  return generateRoundRobin(
    teams: teams,
    idPrefix: meetId,
    meetId: meetId,
  );
}

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
