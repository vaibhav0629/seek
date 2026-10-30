import 'package:seek/core/utils/firestore_parsing.dart';

class Club {
  final String id;
  final String name;
  final String sport;
  final String city;
  final String description;
  final String ownerId;
  final bool isPrivate;
  final int memberCount;
  final DateTime? createdAt;

  const Club({
    required this.id,
    required this.name,
    required this.sport,
    required this.city,
    required this.ownerId,
    this.description = '',
    this.isPrivate = false,
    this.memberCount = 1,
    this.createdAt,
  });

  factory Club.fromMap(Map<String, dynamic> map, String id) => Club(
        id: id,
        name: map['name'] as String? ?? '',
        sport: map['sport'] as String? ?? '',
        city: map['city'] as String? ?? '',
        description: map['description'] as String? ?? '',
        ownerId: map['ownerId'] as String? ?? '',
        isPrivate: map['isPrivate'] as bool? ?? false,
        memberCount: (map['memberCount'] as num?)?.toInt() ?? 0,
        createdAt: dateFromFirestore(map['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'sport': sport,
        'city': city,
        'description': description,
        'ownerId': ownerId,
        'isPrivate': isPrivate,
        'memberCount': memberCount,
        'createdAt': dateToFirestore(createdAt),
      };
}
