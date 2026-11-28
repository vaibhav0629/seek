import 'package:seek/core/mock/mock_support.dart';
import 'package:seek/features/notifications/domain/entities/app_notification.dart';
import 'package:seek/features/notifications/domain/repositories/notification_repository.dart';

/// In-memory notifications, for the mock login. The phone still shows them.
class MockNotificationRepository implements NotificationRepository {
  final MockCollection<AppNotification> _items =
      MockCollection<AppNotification>(const []);

  @override
  Stream<List<AppNotification>> watchUnread(String userId) {
    return _items.watch(
      (items) => items.where((n) => n.userId == userId && !n.isRead).toList(),
    );
  }

  @override
  Future<void> send({
    required String toUserId,
    required String title,
    required String body,
    required String type,
    String? route,
  }) {
    return sendToMany(
      toUserIds: [toUserId],
      title: title,
      body: body,
      type: type,
      route: route,
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
    await mockDelay();
    _items.mutate((items) {
      for (final userId in toUserIds) {
        items.add(
          AppNotification(
            id: mockId('notification'),
            userId: userId,
            title: title,
            body: body,
            type: type,
            route: route,
            createdAt: DateTime.now(),
          ),
        );
      }
    });
  }

  @override
  Future<void> markRead(String notificationId) async {
    _items.mutate((items) {
      final index = items.indexWhere((n) => n.id == notificationId);
      if (index >= 0) items[index] = items[index].copyWith(isRead: true);
    });
  }
}