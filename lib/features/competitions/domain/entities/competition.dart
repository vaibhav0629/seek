import 'package:seek/core/utils/firestore_parsing.dart';

enum CompetitionFormat { roundRobin, singleElimination }

enum CompetitionStatus { registration, inProgress, finished }

class Competition {
  final String id;
  final String clubId;
  final String title;
  final String sport;
  final CompetitionFormat format;
  final CompetitionStatus status;
  final List<String> playerIds;
  final Map<String, int> seeds;
  final int maxPlayers;
  final String createdBy;
  final DateTime? startsAt;
  final String? championId;
  final DateTime? createdAt;

  const Competition({
    required this.id,
    required this.clubId,
    required this.title,
    required this.sport,
    required this.createdBy,
    this.format = CompetitionFormat.singleElimination,
    this.status = CompetitionStatus.registration,
    this.playerIds = const [],
    this.seeds = const {},
    this.maxPlayers = 16,
    this.startsAt,
    this.championId,
    this.createdAt,
  });

  factory Competition.fromMap(Map<String, dynamic> map, String id) =>
      Competition(
        id: id,
        clubId: map['clubId'] as String? ?? '',
        title: map['title'] as String? ?? '',
        sport: map['sport'] as String? ?? '',
        createdBy: map['createdBy'] as String? ?? '',
        format: enumFromName(CompetitionFormat.values, map['format'],
            CompetitionFormat.singleElimination),
        status: enumFromName(CompetitionStatus.values, map['status'],
            CompetitionStatus.registration),
        playerIds: stringList(map['playerIds']),
        seeds: (map['seeds'] as Map?)
                ?.map((k, v) => MapEntry(k as String, (v as num).toInt())) ??
            const <String, int>{},
        maxPlayers: (map['maxPlayers'] as num?)?.toInt() ?? 16,
        startsAt: dateFromFirestore(map['startsAt']),
        championId: map['championId'] as String?,
        createdAt: dateFromFirestore(map['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'clubId': clubId,
        'title': title,
        'sport': sport,
        'createdBy': createdBy,
        'format': format.name,
        'status': status.name,
        'playerIds': playerIds,
        'seeds': seeds,
        'maxPlayers': maxPlayers,
        'startsAt': dateToFirestore(startsAt),
        'championId': championId,
        'createdAt': dateToFirestore(createdAt),
      };

  Competition copyWith({
    CompetitionStatus? status,
    List<String>? playerIds,
    Map<String, int>? seeds,
    String? championId,
  }) =>
      Competition(
        id: id,
        clubId: clubId,
        title: title,
        sport: sport,
        createdBy: createdBy,
        format: format,
        status: status ?? this.status,
        playerIds: playerIds ?? this.playerIds,
        seeds: seeds ?? this.seeds,
        maxPlayers: maxPlayers,
        startsAt: startsAt,
        championId: championId ?? this.championId,
        createdAt: createdAt,
      );
}
