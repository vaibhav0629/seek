import 'package:seek/core/utils/firestore_parsing.dart';

enum MatchStatus { scheduled, inProgress, finished }

enum TeamSide { a, b }

class GameMatch {
  final String id;
  final String? meetId;
  final String? competitionId;
  final int round;
  final int position;
  final int? court;
  final List<String> teamA;
  final List<String> teamB;
  final int? scoreA;
  final int? scoreB;
  final MatchStatus status;
  final String? nextMatchId;
  final TeamSide? nextMatchSide;
  final DateTime? playedAt;

  const GameMatch({
    required this.id,
    required this.teamA,
    required this.teamB,
    this.meetId,
    this.competitionId,
    this.round = 1,
    this.position = 0,
    this.court,
    this.scoreA,
    this.scoreB,
    this.status = MatchStatus.scheduled,
    this.nextMatchId,
    this.nextMatchSide,
    this.playedAt,
  });

  TeamSide? get winner {
    if (status != MatchStatus.finished || scoreA == null || scoreB == null) {
      return null;
    }
    if (scoreA! > scoreB!) return TeamSide.a;
    if (scoreB! > scoreA!) return TeamSide.b;
    return null;
  }

  factory GameMatch.fromMap(Map<String, dynamic> map, String id) => GameMatch(
        id: id,
        meetId: map['meetId'] as String?,
        competitionId: map['competitionId'] as String?,
        round: (map['round'] as num?)?.toInt() ?? 1,
        position: (map['position'] as num?)?.toInt() ?? 0,
        court: (map['court'] as num?)?.toInt(),
        teamA: stringList(map['teamA']),
        teamB: stringList(map['teamB']),
        scoreA: (map['scoreA'] as num?)?.toInt(),
        scoreB: (map['scoreB'] as num?)?.toInt(),
        status: enumFromName(
            MatchStatus.values, map['status'], MatchStatus.scheduled),
        nextMatchId: map['nextMatchId'] as String?,
        nextMatchSide: map['nextMatchSide'] == null
            ? null
            : enumFromName(TeamSide.values, map['nextMatchSide'], TeamSide.a),
        playedAt: dateFromFirestore(map['playedAt']),
      );

  Map<String, dynamic> toMap() => {
        'meetId': meetId,
        'competitionId': competitionId,
        'round': round,
        'position': position,
        'court': court,
        'teamA': teamA,
        'teamB': teamB,
        'scoreA': scoreA,
        'scoreB': scoreB,
        'status': status.name,
        'nextMatchId': nextMatchId,
        'nextMatchSide': nextMatchSide?.name,
        'playedAt': dateToFirestore(playedAt),
      };

  GameMatch copyWith({
    int? court,
    List<String>? teamA,
    List<String>? teamB,
    int? scoreA,
    int? scoreB,
    MatchStatus? status,
    DateTime? playedAt,
  }) =>
      GameMatch(
        id: id,
        meetId: meetId,
        competitionId: competitionId,
        round: round,
        position: position,
        court: court ?? this.court,
        teamA: teamA ?? this.teamA,
        teamB: teamB ?? this.teamB,
        scoreA: scoreA ?? this.scoreA,
        scoreB: scoreB ?? this.scoreB,
        status: status ?? this.status,
        nextMatchId: nextMatchId,
        nextMatchSide: nextMatchSide,
        playedAt: playedAt ?? this.playedAt,
      );
}
