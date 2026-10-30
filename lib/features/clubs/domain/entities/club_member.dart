import 'package:seek/core/utils/firestore_parsing.dart';

enum ClubRole { admin, member }

class ClubMember {
  final String userId;
  final String userName;
  final ClubRole role;
  final DateTime? joinedAt;

  const ClubMember({
    required this.userId,
    required this.userName,
    this.role = ClubRole.member,
    this.joinedAt,
  });

  factory ClubMember.fromMap(Map<String, dynamic> map, String userId) =>
      ClubMember(
        userId: userId,
        userName: map['userName'] as String? ?? '',
        role: enumFromName(ClubRole.values, map['role'], ClubRole.member),
        joinedAt: dateFromFirestore(map['joinedAt']),
      );

  Map<String, dynamic> toMap() => {
        'userName': userName,
        'role': role.name,
        'joinedAt': dateToFirestore(joinedAt),
      };
}
