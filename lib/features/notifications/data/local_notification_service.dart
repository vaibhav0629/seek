import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows the banner in the phone's notification bar.
class LocalNotificationService {
  LocalNotificationService._();
  static final instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initFuture;

  /// Set by the app: opens a screen when a notification is tapped.
  void Function(String route)? onTap;

  /// Safe to call many times: it only runs once.
  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.startsWith('/')) onTap?.call(route);
      },
    );

    // Android 13+ asks the user here.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init(); // so the first notification never races the setup

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'seek_alerts',
        'Seek alerts',
        channelDescription: 'Chat messages, waiting list and payments',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}