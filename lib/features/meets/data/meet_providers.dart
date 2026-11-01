import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/meets/data/mock_meet_repository.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/meets/domain/repositories/meet_repository.dart';

/// To switch to Firebase, return FirestoreMeetRepository() here instead.
final meetRepositoryProvider = Provider<MeetRepository>(
  (ref) => MockMeetRepository(),
);

/// All meets, soonest first.
final meetsProvider = StreamProvider<List<Meet>>(
  (ref) => ref.watch(meetRepositoryProvider).watchMeets(),
);

/// Meets of one club.
final clubMeetsProvider = StreamProvider.family<List<Meet>, String>(
  (ref, clubId) =>
      ref.watch(meetRepositoryProvider).watchMeets(clubId: clubId),
);

final meetProvider = StreamProvider.family<Meet?, String>(
  (ref, meetId) => ref.watch(meetRepositoryProvider).watchMeet(meetId),
);

/// Everyone signed up for a meet (going and waitlist).
final rsvpsProvider = StreamProvider.family<List<Rsvp>, String>(
  (ref, meetId) => ref.watch(meetRepositoryProvider).watchRsvps(meetId),
);

/// The signed-in user's own RSVP for a meet, or null.
final myRsvpProvider = StreamProvider.family<Rsvp?, String>((ref, meetId) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream<Rsvp?>.value(null);
  return ref
      .watch(meetRepositoryProvider)
      .watchMyRsvp(meetId: meetId, userId: userId);
});
