
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/meets/domain/repositories/meet_repository.dart';

class FirestoreMeetRepository implements MeetRepository {
  FirestoreMeetRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _meets =>
      _db.collection('meets');

  CollectionReference<Map<String, dynamic>> _rsvps(String meetId) =>
      _meets.doc(meetId).collection('rsvps');

  HttpsCallable _callable(String name) =>
      _functions.httpsCallable(name);

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
    final result = await _callable('createMeet').call({
      'meet': {
        'title': meet.title,
        'clubId': meet.clubId,
        'sport': meet.sport,
        'description': meet.description,
        'startsAt': meet.startsAt.toIso8601String(),
        'venueName': meet.venueName,
        'latitude': meet.latitude,
        'longitude': meet.longitude,
        'geohash': meet.geohash,
        'maxPlayers': meet.maxPlayers,
        'fee': meet.fee,
      },
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    return data['meetId'] as String;
  }

  // JOIN MEET

  @override
  Future<RsvpStatus> joinMeet({
    required String meetId,
    required String userId,
    required String userName,
  }) async {
    // The server uses the authenticated user's UID.
    // userId is retained only for interface compatibility.
    final result = await _callable('joinMeet').call({
      'meetId': meetId,
      'userName': userName,
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    final status = data['status'] as String?;

    switch (status) {
      case 'going':
        return RsvpStatus.going;
      case 'waitlist':
        return RsvpStatus.waitlist;
      default:
        throw StateError('Invalid RSVP status returned by server.');
    }
  }

  // LEAVE MEET

  @override
  Future<void> leaveMeet({
    required String meetId,
    required String userId,
  }) async {
    await _callable('leaveMeet').call({
      'meetId': meetId,
    });
  }

  // PAYMENT

  @override
  Future<void> setPaid({
    required String meetId,
    required String userId,
    required bool paid,
  }) async {
    await _callable('setPaid').call({
      'meetId': meetId,
      'userId': userId,
      'paid': paid,
    });
  }

  // CHECK-IN

  @override
  Future<void> setCheckedIn({
    required String meetId,
    required String userId,
    required bool checkedIn,
  }) async {
    await _callable('setCheckedIn').call({
      'meetId': meetId,
      'userId': userId,
      'checkedIn': checkedIn,
    });
  }
}
