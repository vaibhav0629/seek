import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/auth/data/mock_auth_repository.dart';
import 'package:seek/features/notifications/data/firestore_notification_repository.dart';
import 'package:seek/features/notifications/data/mock_notification_repository.dart';
import 'package:seek/features/notifications/domain/entities/app_notification.dart';
import 'package:seek/features/notifications/domain/repositories/notification_repository.dart';

/// The club whose chat is open right now (null when no chat is open).
/// ChatScreen sets it, so a message for the chat you are reading makes no banner.
final ValueNotifier<String?> activeChatId = ValueNotifier<String?>(null);

/// Mock with the mock login, real Firestore with a real login
/// (same idea as userRepositoryProvider and chatRepositoryProvider).
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  return auth is MockAuthRepository
      ? MockNotificationRepository()
      : FirestoreNotificationRepository();
});

/// The signed-in user's notifications that are not read yet.
final unreadNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(const <AppNotification>[]);
  return ref.watch(notificationRepositoryProvider).watchUnread(userId);
});