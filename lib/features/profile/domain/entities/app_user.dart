import 'package:seek/core/utils/firestore_parsing.dart';

class AppUser {
  final String id;
  final String displayName;
  final String email;
  final String city;
  final List<String> sports;
  final double? rating;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.city = '',
    this.sports = const [],
    this.rating,
    this.photoUrl,
    this.fcmToken,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) => AppUser(
        id: id,
        displayName: map['displayName'] as String? ?? '',
        email: map['email'] as String? ?? '',
        city: map['city'] as String? ?? '',
        sports: stringList(map['sports']),
        rating: (map['rating'] as num?)?.toDouble(),
        photoUrl: map['photoUrl'] as String?,
        fcmToken: map['fcmToken'] as String?,
        createdAt: dateFromFirestore(map['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'email': email,
        'city': city,
        'sports': sports,
        'rating': rating,
        'photoUrl': photoUrl,
        'fcmToken': fcmToken,
        'createdAt': dateToFirestore(createdAt),
      };
}
