import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/domain/repositories/match_repository.dart';

class FirestoreMatchRepository implements MatchRepository {
  FirestoreMatchRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  late final _matches = _db.collection('matches');

  @override
  Stream<List<GameMatch>> watchMatches({String? meetId, String? competitionId}) {
    final query = switch ((meetId, competitionId)) {
      (final m?, final c?) => _matches
          .where('meetId', isEqualTo: m)
          .where('competitionId', isEqualTo: c),
      (final m?, null) => _matches.where('meetId', isEqualTo: m),
      (null, final c?) => _matches.where('competitionId', isEqualTo: c),
      (null, null) => _matches,
    };

    return query.snapshots().map((snapshot) {
      final matches = snapshot.docs
          .map((doc) => GameMatch.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) {
          final byRound = a.round.compareTo(b.round);
          return byRound != 0 ? byRound : a.position.compareTo(b.position);
        });
      return matches;
    });
  }

  @override
  Future<void> saveMatches(List<GameMatch> matches) async {
    if (matches.isEmpty) return;
    final batch = _db.batch();
    for (final match in matches) {
      final docRef = match.id.isEmpty ? _matches.doc() : _matches.doc(match.id);
      batch.set(docRef, match.toMap(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  @override
  Future<void> updateScore({
    required String matchId,
    required int scoreA,
    required int scoreB,
  }) async {
    await _matches.doc(matchId).update({
      'scoreA': scoreA,
      'scoreB': scoreB,
      'status': MatchStatus.finished.name,
      'playedAt': FieldValue.serverTimestamp(),
    });
  }
}