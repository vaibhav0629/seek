import 'package:seek/features/meets/domain/entities/meet_alert.dart';

abstract class MeetAlertRepository {
  Stream<List<MeetAlert>> watchAlerts(String userId);

  Future<void> addAlert(MeetAlert alert);

  Future<void> markAsRead(String alertId);

  Future<void> markAllAsRead(String userId);
}
