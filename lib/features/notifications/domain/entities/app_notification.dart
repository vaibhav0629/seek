import 'package:seek/core/utils/firestore_parsing.dart';

/// One notification for one person. Firestore path: notifications/{id}
/// type: 'chat' | 'waitlist' | 'payment'
/// route: the screen to open when it is tapped, for example "/meets/abc".
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? route;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.route,
    this.isRead = false,
    this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) =>
      AppNotification(
        id: id,
        userId: map['userId'] as String? ?? '',
        title: map['title'] as String? ?? '',
        body: map['body'] as String? ?? '',
        type: map['type'] as String? ?? '',
        route: map['route'] as String?,
        isRead: map['isRead'] as bool? ?? false,
        createdAt: dateFromFirestore(map['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'route': route,
        'isRead': isRead,
        'createdAt': dateToFirestore(createdAt),
      };

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        userId: userId,
        title: title,
        body: body,
        type: type,
        route: route,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}