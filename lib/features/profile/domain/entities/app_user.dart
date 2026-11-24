import 'package:seek/core/utils/firestore_parsing.dart';

class AppUser {
  final String id;
  final String displayName;
  final String email;
  final String phone;
  final String city;
  final List<String> sports;
  final String skillLevel;
  final double? rating;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.phone = '',
    this.city = '',
    this.sports = const [],
    this.skillLevel = '',
    this.rating,
    this.photoUrl,
    this.fcmToken,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    // Accounts made by the first version of register used the keys
    // "name" and "sport". They are still read, so old test accounts keep working.
    final sports = stringList(map['sports']);
    final oldSport = map['sport'];

    return AppUser(
      id: id,
      displayName:
          map['displayName'] as String? ?? map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      city: map['city'] as String? ?? '',
      sports: sports.isNotEmpty
          ? sports
          : [if (oldSport is String && oldSport.isNotEmpty) oldSport],
      skillLevel: map['skillLevel'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble(),
      photoUrl: map['photoUrl'] as String?,
      fcmToken: map['fcmToken'] as String?,
      createdAt: dateFromFirestore(map['createdAt']),
    );
  }

  /// A copy with some fields changed. Everything else stays the same.
  AppUser copyWith({
    String? displayName,
    String? phone,
    String? city,
    List<String>? sports,
    String? skillLevel,
  }) =>
      AppUser(
        id: id,
        displayName: displayName ?? this.displayName,
        email: email,
        phone: phone ?? this.phone,
        city: city ?? this.city,
        sports: sports ?? this.sports,
        skillLevel: skillLevel ?? this.skillLevel,
        rating: rating,
        photoUrl: photoUrl,
        fcmToken: fcmToken,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'email': email,
        'phone': phone,
        'city': city,
        'sports': sports,
        'skillLevel': skillLevel,
        'rating': rating,
        'photoUrl': photoUrl,
        'fcmToken': fcmToken,
        'createdAt': dateToFirestore(createdAt),
      };
}