import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/clubs/domain/repositories/club_repository.dart';

class FirestoreClubRepository implements ClubRepository {
  FirestoreClubRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  late final _clubs = _db.collection('clubs');

  @override
  Stream<List<Club>> watchClubs({String? city, String? sport}) {
    return _clubs
        .where('isPrivate', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Club.fromMap(doc.data(), doc.id))
          .where((c) =>
              city == null || c.city.toLowerCase() == city.toLowerCase())
          .where((c) =>
              sport == null || c.sport.toLowerCase() == sport.toLowerCase())
          .toList();
    });
  }

  @override
  Stream<List<Club>> watchMyClubs(String userId) {
    return _db
        .collectionGroup('members')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final clubIds = snapshot.docs
          .map((doc) => doc.reference.parent.parent?.id)
          .whereType<String>()
          .toSet();
      if (clubIds.isEmpty) return <Club>[];

      final docs = await Future.wait(
        clubIds.map((id) => _clubs.doc(id).get()),
      );
      return docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => Club.fromMap(doc.data()!, doc.id))
          .toList();
    });
  }

  @override
  Stream<Club?> watchClub(String clubId) {
    return _clubs.doc(clubId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Club.fromMap(doc.data()!, doc.id);
    });
  }

  @override
  Stream<List<ClubMember>> watchMembers(String clubId) {
    return _clubs.doc(clubId).collection('members').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ClubMember.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<String> createClub(Club club, {required String ownerName}) async {
    final clubRef = club.id.isEmpty ? _clubs.doc() : _clubs.doc(club.id);
    final data = club.toMap();
    data['memberCount'] = 1;
    if (club.createdAt == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    // Write the club doc first so Firestore rules can verify ownerId
    // when creating the owner's admin member doc.
    await clubRef.set(data);
    await clubRef.collection('members').doc(club.ownerId).set({
      'userId': club.ownerId,
      'userName': ownerName,
      'role': ClubRole.admin.name,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    return clubRef.id;
  }

  @override
  Future<void> joinClub({
    required String clubId,
    required String userId,
    required String userName,
  }) async {
    final clubRef = _clubs.doc(clubId);
    final memberRef = clubRef.collection('members').doc(userId);

    await _db.runTransaction((tx) async {
      final clubSnap = await tx.get(clubRef);
      final memberSnap = await tx.get(memberRef);
      if (!clubSnap.exists || memberSnap.exists) return;

      final currentCount =
          (clubSnap.data()?['memberCount'] as num?)?.toInt() ?? 0;
      tx.set(memberRef, {
        'userId': userId,
        'userName': userName,
        'role': ClubRole.member.name,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      tx.update(clubRef, {'memberCount': currentCount + 1});
    });
  }

  @override
  Future<void> leaveClub({
    required String clubId,
    required String userId,
  }) async {
    final clubRef = _clubs.doc(clubId);
    final memberRef = clubRef.collection('members').doc(userId);

    await _db.runTransaction((tx) async {
      final clubSnap = await tx.get(clubRef);
      final memberSnap = await tx.get(memberRef);
      if (!clubSnap.exists || !memberSnap.exists) return;

      if (clubSnap.data()?['ownerId'] == userId) {
        throw StateError('Owner harus mentransfer kepemilikan sebelum keluar');
      }

      final currentCount =
          (clubSnap.data()?['memberCount'] as num?)?.toInt() ?? 1;
      tx.delete(memberRef);
      tx.update(clubRef, {
        'memberCount': (currentCount - 1).clamp(0, 999999),
      });
    });
  }

  @override
  Future<void> promoteMember({
    required String clubId,
    required String userId,
  }) async {
    await _clubs.doc(clubId).collection('members').doc(userId).update({
      'role': ClubRole.admin.name,
    });
  }

  @override
  Future<void> kickMember({
    required String clubId,
    required String userId,
  }) async {
    await leaveClub(clubId: clubId, userId: userId);
  }
}