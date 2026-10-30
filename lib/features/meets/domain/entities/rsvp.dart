import 'package:seek/core/utils/firestore_parsing.dart';

enum RsvpStatus { going, waitlist, cancelled }

class Rsvp {
  final String userId;
  final String meetId;
  final String userName;
  final RsvpStatus status;
  final bool paid;
  final bool checkedIn;
  final DateTime? joinedAt;
  final DateTime? paidAt;

  const Rsvp({
    required this.userId,
    required this.meetId,
    required this.userName,
    this.status = RsvpStatus.going,
    this.paid = false,
    this.checkedIn = false,
    this.joinedAt,
    this.paidAt,
  });

  factory Rsvp.fromMap(Map<String, dynamic> map, String userId) => Rsvp(
        userId: userId,
        meetId: map['meetId'] as String? ?? '',
        userName: map['userName'] as String? ?? '',
        status: enumFromName(RsvpStatus.values, map['status'], RsvpStatus.going),
        paid: map['paid'] as bool? ?? false,
        checkedIn: map['checkedIn'] as bool? ?? false,
        joinedAt: dateFromFirestore(map['joinedAt']),
        paidAt: dateFromFirestore(map['paidAt']),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'meetId': meetId,
        'userName': userName,
        'status': status.name,
        'paid': paid,
        'checkedIn': checkedIn,
        'joinedAt': dateToFirestore(joinedAt),
        'paidAt': dateToFirestore(paidAt),
      };

  Rsvp copyWith({
    RsvpStatus? status,
    bool? paid,
    bool? checkedIn,
    DateTime? joinedAt,
    DateTime? paidAt,
  }) =>
      Rsvp(
        userId: userId,
        meetId: meetId,
        userName: userName,
        status: status ?? this.status,
        paid: paid ?? this.paid,
        checkedIn: checkedIn ?? this.checkedIn,
        joinedAt: joinedAt ?? this.joinedAt,
        paidAt: paidAt ?? this.paidAt,
      );
}
