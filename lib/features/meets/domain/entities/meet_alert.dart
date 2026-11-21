import 'package:seek/core/utils/firestore_parsing.dart';

enum MeetAlertType {
  rsvpConfirmed,
  waitlistJoined,
  waitlistPromoted,
  checkInConfirmed,
}

class MeetAlert {
  final String id;
  final String userId;
  final String meetId;
  final MeetAlertType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const MeetAlert({
    required this.id,
    required this.userId,
    required this.meetId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory MeetAlert.fromMap(Map<String, dynamic> map, String id) {
    return MeetAlert(
      id: id,
      userId: map['userId'] as String? ?? '',
      meetId: map['meetId'] as String? ?? '',
      type: enumFromName(
        MeetAlertType.values,
        map['type'],
        MeetAlertType.rsvpConfirmed,
      ),
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      createdAt: dateFromFirestore(map['createdAt']) ?? DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'meetId': meetId,
      'type': type.name,
      'title': title,
      'message': message,
      'createdAt': dateToFirestore(createdAt),
      'isRead': isRead,
    };
  }

  MeetAlert copyWith({String? id, bool? isRead}) {
    return MeetAlert(
      id: id ?? this.id,
      userId: userId,
      meetId: meetId,
      type: type,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
