import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seek/features/notifications/domain/entities/app_notification.dart';
import 'package:seek/features/notifications/domain/repositories/notification_repository.dart';

/// The real notifications, one document each at notifications/{id}.
class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('notifications');

  Map<String, dynamic> _data({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? route,
  }) =>
      {
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'route': route,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

  @override
  Stream<List<AppNotification>> watchUnread(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<void> send({
    required String toUserId,
    required String title,
    required String body,
    required String type,
    String? route,
  }) async {
    await _collection.add(
      _data(userId: toUserId, title: title, body: body, type: type, route: route),
    );
  }

  @override
  Future<void> sendToMany({
    required List<String> toUserIds,
    required String title,
    required String body,
    required String type,
    String? route,
  }) async {
    // One batch = one round trip. A batch holds at most 500 writes.
    final batch = _db.batch();
    for (final userId in toUserIds) {
      batch.set(
        _collection.doc(),
        _data(userId: userId, title: title, body: body, type: type, route: route),
      );
    }
    await batch.commit();
  }

  @override
  Future<void> markRead(String notificationId) {
    return _collection.doc(notificationId).update({'isRead': true});
  }
}