import 'package:flutter_test/flutter_test.dart';
import 'package:seek/features/meets/data/mock_meet_repository.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';

void main() {
  group('MockMeetRepository - RSVP', () {
    late MockMeetRepository repository;

    setUp(() {
      repository = MockMeetRepository();
    });

    test('User can join a meet with available spots', () async {
      final status = await repository.joinMeet(
        meetId: 'm1',
        userId: 'test_user_1',
        userName: 'Test User',
      );

      expect(status, RsvpStatus.going);
    });

    test('User joins waitlist when meet is full', () async {
      final status = await repository.joinMeet(
        meetId: 'm2',
        userId: 'test_user_2',
        userName: 'Test User 2',
      );

      expect(status, RsvpStatus.waitlist);
    });

    test('User cannot join a finished meet', () async {
      expect(
        () => repository.joinMeet(
          meetId: 'm0',
          userId: 'test_user_3',
          userName: 'Test User 3',
        ),
        throwsStateError,
      );
    });

    test('Leaving a meet promotes the first waitlisted participant', () async {
      await repository.leaveMeet(meetId: 'm2', userId: 'u5');

      final rsvps = await repository.watchRsvps('m2').first;

      final promotedUser = rsvps.firstWhere((rsvp) => rsvp.userId == 'u2');

      expect(promotedUser.status, RsvpStatus.going);
    });

    test('Only confirmed participants can check in', () async {
      expect(
        () => repository.setCheckedIn(
          meetId: 'm2',
          userId: 'u2',
          checkedIn: true,
        ),
        throwsStateError,
      );
    });

    test('Confirmed participant can check in', () async {
      await repository.setCheckedIn(
        meetId: 'm1',
        userId: 'u1',
        checkedIn: true,
      );

      final rsvps = await repository.watchRsvps('m1').first;

      final participant = rsvps.firstWhere((rsvp) => rsvp.userId == 'u1');

      expect(participant.checkedIn, isTrue);
    });
  });
}
