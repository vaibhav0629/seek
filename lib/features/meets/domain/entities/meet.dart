import 'package:seek/core/utils/firestore_parsing.dart';

enum MeetStatus { upcoming, ongoing, finished, cancelled }

class Meet {
  final String id;
  final String clubId;
  final String title;
  final String sport;
  final String description;
  final DateTime startsAt;
  final String venueName;
  final double? latitude;
  final double? longitude;
  final String? geohash;
  final int maxPlayers;
  final int fee;
  final String createdBy;
  final MeetStatus status;
  final int goingCount;
  final int waitlistCount;
  final DateTime? createdAt;

  const Meet({
    required this.id,
    required this.clubId,
    required this.title,
    required this.sport,
    required this.startsAt,
    required this.venueName,
    required this.maxPlayers,
    required this.createdBy,
    this.description = '',
    this.latitude,
    this.longitude,
    this.geohash,
    this.fee = 0,
    this.status = MeetStatus.upcoming,
    this.goingCount = 0,
    this.waitlistCount = 0,
    this.createdAt,
  });

  bool get isFull => goingCount >= maxPlayers;
  bool get isFree => fee == 0;

  factory Meet.fromMap(Map<String, dynamic> map, String id) => Meet(
        id: id,
        clubId: map['clubId'] as String? ?? '',
        title: map['title'] as String? ?? '',
        sport: map['sport'] as String? ?? '',
        description: map['description'] as String? ?? '',
        startsAt: dateFromFirestore(map['startsAt']) ?? DateTime.now(),
        venueName: map['venueName'] as String? ?? '',
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        geohash: map['geohash'] as String?,
        maxPlayers: (map['maxPlayers'] as num?)?.toInt() ?? 0,
        fee: (map['fee'] as num?)?.toInt() ?? 0,
        createdBy: map['createdBy'] as String? ?? '',
        status: enumFromName(MeetStatus.values, map['status'], MeetStatus.upcoming),
        goingCount: (map['goingCount'] as num?)?.toInt() ?? 0,
        waitlistCount: (map['waitlistCount'] as num?)?.toInt() ?? 0,
        createdAt: dateFromFirestore(map['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'clubId': clubId,
        'title': title,
        'sport': sport,
        'description': description,
        'startsAt': dateToFirestore(startsAt),
        'venueName': venueName,
        'latitude': latitude,
        'longitude': longitude,
        'geohash': geohash,
        'maxPlayers': maxPlayers,
        'fee': fee,
        'createdBy': createdBy,
        'status': status.name,
        'goingCount': goingCount,
        'waitlistCount': waitlistCount,
        'createdAt': dateToFirestore(createdAt),
      };
}
