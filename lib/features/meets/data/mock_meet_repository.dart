import 'package:seek/core/mock/mock_data.dart';
import 'package:seek/core/mock/mock_support.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/meets/domain/repositories/meet_repository.dart';

class MockMeetRepository implements MeetRepository {
  MockMeetRepository() {
    // Make the going/waitlist counts match the seeded RSVPs.
    for (final meet in mockMeets) {
      _recount(meet.id);
    }
  }

  final MockCollection<Meet> _meets = MockCollection<Meet>(mockMeets);
  final MockCollection<Rsvp> _rsvps = MockCollection<Rsvp>(mockRsvps);

  @override
  Stream<List<Meet>> watchMeets({String? clubId, String? sport}) {
    return _meets.watch((meets) {
      final result = meets
          .where((m) => clubId == null || m.clubId == clubId)
          .where((m) =>
              sport == null || m.sport.toLowerCase() == sport.toLowerCase())
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      return result;
    });
  }

  @override
  Stream<Meet?> watchMeet(String meetId) {
    return _meets.watch(
      (meets) => meets.where((m) => m.id == meetId).firstOrNull,
    );
  }

  @override
  Stream<List<Rsvp>> watchRsvps(String meetId) {
    return _rsvps.watch((rsvps) {
      final result = rsvps
          .where((r) => r.meetId == meetId)
          .where((r) => r.status != RsvpStatus.cancelled)
          .toList()
        ..sort((a, b) => _time(a.joinedAt).compareTo(_time(b.joinedAt)));
      return result;
    });
  }

  @override
  Stream<Rsvp?> watchMyRsvp({required String meetId, required String userId}) {
    return _rsvps.watch((rsvps) {
      final mine = rsvps
          .where((r) => r.meetId == meetId && r.userId == userId)
          .firstOrNull;
      return mine?.status == RsvpStatus.cancelled ? null : mine;
    });
  }

  @override
  Future<String> createMeet(Meet meet) async {
    await mockDelay();
    final id = meet.id.isEmpty ? mockId('meet') : meet.id;
    _meets.mutate((items) => items.add(_copy(meet, id: id)));
    return id;
  }

  @override
  Future<RsvpStatus> joinMeet({
    required String meetId,
    required String userId,
    required String userName,
  }) async {
    await mockDelay();
    final meet = _meets.items.firstWhere(
      (m) => m.id == meetId,
      orElse: () => throw StateError('No meet with id $meetId'),
    );
    final existing = _rsvps.items
        .where((r) => r.meetId == meetId && r.userId == userId)
        .firstOrNull;
    if (existing != null && existing.status != RsvpStatus.cancelled) {
      return existing.status; // already signed up
    }
    final status = meet.isFull ? RsvpStatus.waitlist : RsvpStatus.going;
    final rsvp = Rsvp(
      userId: userId,
      meetId: meetId,
      userName: userName,
      status: status,
      joinedAt: DateTime.now(),
    );
    _rsvps.mutate((items) {
      items.removeWhere((r) => r.meetId == meetId && r.userId == userId);
      items.add(rsvp);
    });
    _recount(meetId);
    return status;
  }

  @override
  Future<void> leaveMeet({
    required String meetId,
    required String userId,
  }) async {
    await mockDelay();
    final index = _rsvps.items
        .indexWhere((r) => r.meetId == meetId && r.userId == userId);
    if (index == -1) return;
    final leaving = _rsvps.items[index];
    _rsvps.mutate((items) {
      items[index] = leaving.copyWith(status: RsvpStatus.cancelled);
      if (leaving.status == RsvpStatus.going) {
        // Promote the longest-waiting person. (Real app: also notify them
        // with a push notification.)
        final waiting = items
            .where((r) => r.meetId == meetId && r.status == RsvpStatus.waitlist)
            .toList()
          ..sort((a, b) => _time(a.joinedAt).compareTo(_time(b.joinedAt)));
        if (waiting.isNotEmpty) {
          final next = items.indexWhere(
            (r) => r.meetId == meetId && r.userId == waiting.first.userId,
          );
          items[next] = items[next].copyWith(status: RsvpStatus.going);
        }
      }
    });
    _recount(meetId);
  }

  @override
  Future<void> setPaid({
    required String meetId,
    required String userId,
    required bool paid,
  }) async {
    await mockDelay();
    _rsvps.mutate((items) {
      final index =
          items.indexWhere((r) => r.meetId == meetId && r.userId == userId);
      if (index == -1) return;
      items[index] = items[index]
          .copyWith(paid: paid, paidAt: paid ? DateTime.now() : null);
    });
  }

  @override
  Future<void> setCheckedIn({
    required String meetId,
    required String userId,
    required bool checkedIn,
  }) async {
    await mockDelay();
    _rsvps.mutate((items) {
      final index =
          items.indexWhere((r) => r.meetId == meetId && r.userId == userId);
      if (index == -1) return;
      items[index] = items[index].copyWith(checkedIn: checkedIn);
    });
  }

  /// Recalculates goingCount and waitlistCount from the RSVPs.
  void _recount(String meetId) {
    final going = _rsvps.items
        .where((r) => r.meetId == meetId && r.status == RsvpStatus.going)
        .length;
    final waiting = _rsvps.items
        .where((r) => r.meetId == meetId && r.status == RsvpStatus.waitlist)
        .length;
    _meets.mutate((items) {
      final index = items.indexWhere((m) => m.id == meetId);
      if (index == -1) return;
      items[index] =
          _copy(items[index], goingCount: going, waitlistCount: waiting);
    });
  }

  DateTime _time(DateTime? value) => value ?? DateTime.fromMillisecondsSinceEpoch(0);

  Meet _copy(Meet m, {String? id, int? goingCount, int? waitlistCount}) => Meet(
        id: id ?? m.id,
        clubId: m.clubId,
        title: m.title,
        sport: m.sport,
        description: m.description,
        startsAt: m.startsAt,
        venueName: m.venueName,
        latitude: m.latitude,
        longitude: m.longitude,
        geohash: m.geohash,
        maxPlayers: m.maxPlayers,
        fee: m.fee,
        createdBy: m.createdBy,
        status: m.status,
        goingCount: goingCount ?? m.goingCount,
        waitlistCount: waitlistCount ?? m.waitlistCount,
        createdAt: m.createdAt ?? DateTime.now(),
      );
}
