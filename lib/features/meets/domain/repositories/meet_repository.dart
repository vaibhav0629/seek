import 'package:seek/features/meets/domain/entities/meet.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';

/// Meets (sessions) and RSVPs.
/// Firestore paths: meets/{meetId} and meets/{meetId}/rsvps/{userId}
abstract class MeetRepository {
  /// Meets sorted by start time, optionally filtered by club and/or sport.
  Stream<List<Meet>> watchMeets({String? clubId, String? sport});

  Stream<Meet?> watchMeet(String meetId);

  /// Everyone signed up (going or on the waitlist), oldest sign-up first.
  Stream<List<Rsvp>> watchRsvps(String meetId);

  /// The user's own RSVP, or null if they have none (or cancelled).
  Stream<Rsvp?> watchMyRsvp({required String meetId, required String userId});

  /// Pass a meet with an empty id and the repository assigns one.
  Future<String> createMeet(Meet meet);

  /// Signs the user up. Returns going if there was room, otherwise waitlist.
  /// The Firestore version must do this inside a transaction so two people
  /// cannot take the last spot at the same time.
  Future<RsvpStatus> joinMeet({
    required String meetId,
    required String userId,
    required String userName,
  });

  /// Cancels the user's RSVP. If they were going, the first person on the
  /// waitlist moves up.
  Future<void> leaveMeet({required String meetId, required String userId});

  Future<void> setPaid({
    required String meetId,
    required String userId,
    required bool paid,
  });

  Future<void> setCheckedIn({
    required String meetId,
    required String userId,
    required bool checkedIn,
  });
}
