
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/meets/domain/repositories/meet_repository.dart';

class FirestoreMeetRepository implements MeetRepository {
  FirestoreMeetRepository({
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _meets =>
      _db.collection('meets');

  CollectionReference<Map<String, dynamic>> _rsvps(String meetId) =>
      _meets.doc(meetId).collection('rsvps');

  // WATCH MEETS

  @override
  Stream<List<Meet>> watchMeets({String? clubId, String? sport}) {
    Query<Map<String, dynamic>> query = _meets;

    if (clubId != null) {
      query = query.where('clubId', isEqualTo: clubId);
    }

    if (sport != null) {
      query = query.where('sport', isEqualTo: sport);
    }

    return query.snapshots().map((snapshot) {
      final meets = snapshot.docs
          .map((doc) => Meet.fromMap(doc.data(), doc.id))
          .toList();

      meets.sort((a, b) => a.startsAt.compareTo(b.startsAt));
      return meets;
    });
  }

  @override
  Stream<Meet?> watchMeet(String meetId) {
    return _meets.doc(meetId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Meet.fromMap(doc.data()!, doc.id);
    });
  }

  // WATCH RSVPS

  @override
  Stream<List<Rsvp>> watchRsvps(String meetId) {
    return _rsvps(meetId).snapshots().map((snapshot) {
      final rsvps = snapshot.docs
          .map((doc) => Rsvp.fromMap(doc.data(), doc.id))
          .toList();

      rsvps.sort((a, b) {
        final dateA = a.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateA.compareTo(dateB);
      });

      return rsvps;
    });
  }

  @override
  Stream<Rsvp?> watchMyRsvp({
    required String meetId,
    required String userId,
  }) {
    return _rsvps(meetId).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Rsvp.fromMap(doc.data()!, doc.id);
    });
  }

  // CREATE MEET

  @override
  Future<String> createMeet(Meet meet) async {
    final data = meet.toMap();

    if (meet.createdAt == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    final doc = await _meets.add(data);
    return doc.id;
  }

  // JOIN MEET

  @override
  Future<RsvpStatus> joinMeet({
    required String meetId,
    required String userId,
    required String userName,
  }) async {
    final meetRef = _meets.doc(meetId);
    final rsvpRef = _rsvps(meetId).doc(userId);

    return _db.runTransaction<RsvpStatus>((transaction) async {
      final meetSnapshot = await transaction.get(meetRef);
      final rsvpSnapshot = await transaction.get(rsvpRef);

      if (!meetSnapshot.exists) {
        throw StateError('Meet tidak ditemukan.');
      }

      final meet = Meet.fromMap(meetSnapshot.data()!, meetSnapshot.id);

      if (meet.status == MeetStatus.cancelled ||
          meet.status == MeetStatus.finished) {
        throw StateError('Meet sudah tidak menerima peserta.');
      }

      if (rsvpSnapshot.exists) {
        final existing = Rsvp.fromMap(
          rsvpSnapshot.data()!,
          rsvpSnapshot.id,
        );

        if (existing.status != RsvpStatus.cancelled) {
          throw StateError('Kamu sudah terdaftar di Meet ini.');
        }
      }

      final status = meet.goingCount < meet.maxPlayers
          ? RsvpStatus.going
          : RsvpStatus.waitlist;

      final rsvp = Rsvp(
        userId: userId,
        meetId: meetId,
        userName: userName,
        status: status,
        joinedAt: DateTime.now(),
      );

      transaction.set(rsvpRef, rsvp.toMap());

      transaction.update(meetRef, {
        if (status == RsvpStatus.going)
          'goingCount': meet.goingCount + 1,
        if (status == RsvpStatus.waitlist)
          'waitlistCount': meet.waitlistCount + 1,
      });

      return status;
    });
  }

  // LEAVE MEET

  @override
  Future<void> leaveMeet({
    required String meetId,
    required String userId,
  }) async {
    final meetRef = _meets.doc(meetId);
    final rsvpRef = _rsvps(meetId).doc(userId);

    // Find the oldest waitlisted participant.
    final waitlistSnapshot = await _rsvps(meetId)
        .where('status', isEqualTo: RsvpStatus.waitlist.name)
        .get();

    final candidates = waitlistSnapshot.docs
        .where((doc) => doc.id != userId)
        .toList();

    candidates.sort((a, b) {
      final dateA = Rsvp.fromMap(a.data(), a.id).joinedAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = Rsvp.fromMap(b.data(), b.id).joinedAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return dateA.compareTo(dateB);
    });

    final candidateRef =
        candidates.isEmpty ? null : candidates.first.reference;

    await _db.runTransaction((transaction) async {
      final meetSnapshot = await transaction.get(meetRef);
      final rsvpSnapshot = await transaction.get(rsvpRef);

      if (!meetSnapshot.exists || !rsvpSnapshot.exists) return;

      final meet = Meet.fromMap(meetSnapshot.data()!, meetSnapshot.id);
      final rsvp = Rsvp.fromMap(rsvpSnapshot.data()!, rsvpSnapshot.id);

      if (rsvp.status == RsvpStatus.cancelled) return;

      Rsvp? promoted;

      if (rsvp.status == RsvpStatus.going && candidateRef != null) {
        final candidateSnapshot = await transaction.get(candidateRef);

        if (candidateSnapshot.exists) {
          final candidate = Rsvp.fromMap(
            candidateSnapshot.data()!,
            candidateSnapshot.id,
          );

          if (candidate.status == RsvpStatus.waitlist) {
            promoted = candidate;
          }
        }
      }

      transaction.update(rsvpRef, {
        'status': RsvpStatus.cancelled.name,
      });

      if (rsvp.status == RsvpStatus.waitlist) {
        transaction.update(meetRef, {
          'waitlistCount': (meet.waitlistCount - 1).clamp(0, 999999),
        });
      } else {
        transaction.update(meetRef, {
          'goingCount': promoted == null
              ? (meet.goingCount - 1).clamp(0, 999999)
              : meet.goingCount,
          if (promoted != null)
            'waitlistCount': (meet.waitlistCount - 1).clamp(0, 999999),
        });

        if (promoted != null && candidateRef != null) {
          transaction.update(candidateRef, {
            'status': RsvpStatus.going.name,
          });
        }
      }
    });
  }

  // PAYMENT

  @override
  Future<void> setPaid({
    required String meetId,
    required String userId,
    required bool paid,
  }) async {
    await _rsvps(meetId).doc(userId).update({
      'paid': paid,
      'paidAt': paid ? FieldValue.serverTimestamp() : null,
    });
  }

  // CHECK-IN

  @override
  Future<void> setCheckedIn({
    required String meetId,
    required String userId,
    required bool checkedIn,
  }) async {
    final rsvpRef = _rsvps(meetId).doc(userId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(rsvpRef);

      if (!snapshot.exists) {
        throw StateError('RSVP tidak ditemukan.');
      }

      final rsvp = Rsvp.fromMap(snapshot.data()!, snapshot.id);

      if (rsvp.status != RsvpStatus.going) {
        throw StateError('Hanya peserta yang berstatus going yang bisa check-in.');
      }

      transaction.update(rsvpRef, {
        'checkedIn': checkedIn,
      });
    });
  }
}
