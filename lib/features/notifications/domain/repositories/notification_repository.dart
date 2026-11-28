import 'package:seek/features/notifications/domain/entities/app_notification.dart';

/// Notifications for people. Firestore path: notifications/{id}
/// "Sending" a notification means writing a document for the receiver.
/// The receiver's phone sees it and shows it (see notification_listener.dart).
abstract class NotificationRepository {
  /// Notifications of one user that are not read yet.
  Stream<List<AppNotification>> watchUnread(String userId);

  Future<void> send({
    required String toUserId,
    required String title,
    required String body,
    required String type,
    String? route,
  });

  /// The same notification for many people (for example a chat message).
  Future<void> sendToMany({
    required List<String> toUserIds,
    required String title,
    required String body,
    required String type,
    String? route,
  });

  Future<void> markRead(String notificationId);
}