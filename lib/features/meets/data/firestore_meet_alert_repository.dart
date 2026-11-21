
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seek/features/meets/domain/entities/meet_alert.dart';
import 'package:seek/features/meets/domain/repositories/meet_alert_repository.dart';

class FirestoreMeetAlertRepository implements MeetAlertRepository {
  FirestoreMeetAlertRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _alerts =>
      _db.collection('meet_alerts');

  // WATCH CURRENT USER ALERTS

  @override
  Stream<List<MeetAlert>> watchAlerts(String userId) {
    return _alerts.where('userId', isEqualTo: userId).snapshots().map(
      (snapshot) {
        final alerts = snapshot.docs
            .map((doc) => MeetAlert.fromMap(doc.data(), doc.id))
            .toList();

        alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return alerts;
      },
    );
  }

  // CREATE ALERT
  // Alerts are created exclusively by Cloud Functions.
  // This method remains for interface compatibility.

  @override
  Future<void> addAlert(MeetAlert alert) async {
    throw UnsupportedError(
      'Alerts can only be created by Cloud Functions.',
    );
  }

  // MARK ONE ALERT AS READ

  @override
  Future<void> markAsRead(String alertId) async {
    await _alerts.doc(alertId).update({
      'isRead': true,
    });
  }

  // MARK ALL USER ALERTS AS READ

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _alerts
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var start = 0; start < snapshot.docs.length; start += 450) {
      final batch = _db.batch();

      final end = (start + 450 < snapshot.docs.length)
          ? start + 450
          : snapshot.docs.length;

      for (final doc in snapshot.docs.sublist(start, end)) {
        batch.update(doc.reference, {
          'isRead': true,
        });
      }

      await batch.commit();
    }
  }
}
