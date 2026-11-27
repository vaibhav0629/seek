import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seek/features/competitions/domain/entities/competition.dart';
import 'package:seek/features/competitions/domain/repositories/competition_repository.dart';

class FirestoreCompetitionRepository implements CompetitionRepository {
  FirestoreCompetitionRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  late final _competitions = _db.collection('competitions');

  @override
  Stream<List<Competition>> watchCompetitions({String? clubId}) {
    final query = clubId != null
        ? _competitions.where('clubId', isEqualTo: clubId)
        : _competitions;
    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Competition.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Stream<Competition?> watchCompetition(String competitionId) {
    return _competitions.doc(competitionId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Competition.fromMap(doc.data()!, doc.id);
    });
  }

  @override
  Future<String> createCompetition(Competition competition) async {
    final docRef = competition.id.isEmpty
        ? _competitions.doc()
        : _competitions.doc(competition.id);
    final data = competition.toMap();
    if (competition.createdAt == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await docRef.set(data);
    return docRef.id;
  }

  @override
  Future<void> registerPlayer({
    required String competitionId,
    required String userId,
  }) async {
    final docRef = _competitions.doc(competitionId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists || snap.data() == null) return;

      final comp = Competition.fromMap(snap.data()!, snap.id);
      final canRegister = comp.status == CompetitionStatus.registration &&
          !comp.playerIds.contains(userId) &&
          comp.playerIds.length < comp.maxPlayers;
      if (!canRegister) return;

      tx.update(docRef, {
        'playerIds': [...comp.playerIds, userId],
      });
    });
  }

  @override
  Future<void> updateCompetition(Competition competition) async {
    await _competitions
        .doc(competition.id)
        .set(competition.toMap(), SetOptions(merge: true));
  }
}