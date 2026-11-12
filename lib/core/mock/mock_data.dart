import 'package:seek/features/chat/domain/entities/message.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/competitions/domain/entities/competition.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';
import 'package:seek/features/profile/domain/entities/app_user.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';

/// Fake data for building screens before Firebase is wired up.
///
/// The sports and cities match AppOptions (lib/core/config/app_options.dart).
/// The mock login signs in as user "u1" (Budi). Ids are short and readable:
/// users u1-u6, clubs c1-c5, meets m0-m6, competitions comp1-comp2.
///
/// How scores are stored (GameMatch.scoreA / scoreB):
/// - Padel: sets won (for example 2 and 1)
/// - Basketball: total points (for example 11 and 6)

const String kMockCurrentUserId = 'u1';

final DateTime _now = DateTime.now();

DateTime _evening(int daysFromNow) {
  final day = _now.add(Duration(days: daysFromNow));
  return DateTime(day.year, day.month, day.day, 19);
}

DateTime _morning(int daysFromNow) {
  final day = _now.add(Duration(days: daysFromNow));
  return DateTime(day.year, day.month, day.day, 7);
}

// ---------------------------------------------------------------- users

final List<AppUser> mockUsers = [
  AppUser(
    id: 'u1',
    displayName: 'Budi Santoso',
    email: 'budi@example.com',
    city: 'Jakarta',
    sports: ['Padel', 'Basketball'],
    rating: 3.4,
    createdAt: DateTime(2026, 1, 10),
  ),
  AppUser(
    id: 'u2',
    displayName: 'Sari Wulandari',
    email: 'sari@example.com',
    city: 'Jakarta',
    sports: ['Padel', 'Pilates'],
    rating: 3.8,
    createdAt: DateTime(2026, 1, 12),
  ),
  AppUser(
    id: 'u3',
    displayName: 'Andi Pratama',
    email: 'andi@example.com',
    city: 'Bandung',
    sports: ['Basketball', 'Mahjong'],
    rating: 3.1,
    createdAt: DateTime(2026, 1, 15),
  ),
  AppUser(
    id: 'u4',
    displayName: 'Dewi Lestari',
    email: 'dewi@example.com',
    city: 'Denpasar',
    sports: ['Pilates', 'Running'],
    rating: 4.2,
    createdAt: DateTime(2026, 1, 20),
  ),
  AppUser(
    id: 'u5',
    displayName: 'Rizky Maulana',
    email: 'rizky@example.com',
    city: 'Jakarta',
    sports: ['Basketball', 'Running'],
    rating: 3.6,
    createdAt: DateTime(2026, 1, 25),
  ),
  AppUser(
    id: 'u6',
    displayName: 'Maya Anggraini',
    email: 'maya@example.com',
    city: 'Bogor',
    sports: ['Running', 'Padel'],
    rating: 3.9,
    createdAt: DateTime(2026, 1, 28),
  ),
];

// ---------------------------------------------------------------- clubs

final List<Club> mockClubs = [
  Club(
    id: 'c1',
    name: 'Jakarta Padel Crew',
    sport: 'Padel',
    city: 'Jakarta',
    ownerId: 'u1',
    description: 'Friendly padel sessions around Senayan.',
    memberCount: 6,
    createdAt: DateTime(2026, 2, 1),
  ),
  Club(
    id: 'c2',
    name: 'Senayan Ballers',
    sport: 'Basketball',
    city: 'Jakarta',
    ownerId: 'u5',
    description: 'Pickup basketball and 1v1 tournaments.',
    memberCount: 5,
    createdAt: DateTime(2026, 2, 5),
  ),
  // Private: does not show on Discover.
  Club(
    id: 'c3',
    name: 'Bandung Mahjong Circle',
    sport: 'Mahjong',
    city: 'Bandung',
    ownerId: 'u3',
    description: 'Invite-only mahjong nights.',
    isPrivate: true,
    memberCount: 1,
    createdAt: DateTime(2026, 2, 9),
  ),
  Club(
    id: 'c4',
    name: 'Sanur Pilates Studio',
    sport: 'Pilates',
    city: 'Denpasar',
    ownerId: 'u4',
    description: 'Morning pilates classes by the beach.',
    memberCount: 2,
    createdAt: DateTime(2026, 2, 12),
  ),
  Club(
    id: 'c5',
    name: 'Bogor Runners',
    sport: 'Running',
    city: 'Bogor',
    ownerId: 'u6',
    description: 'Weekend runs around Bogor.',
    memberCount: 3,
    createdAt: DateTime(2026, 2, 15),
  ),
];

typedef ClubMembership = ({String clubId, ClubMember member});

ClubMembership _member(
  String clubId,
  String userId,
  String userName, {
  ClubRole role = ClubRole.member,
}) =>
    (
      clubId: clubId,
      member: ClubMember(
        userId: userId,
        userName: userName,
        role: role,
        joinedAt: _now.subtract(const Duration(days: 30)),
      ),
    );

// Keep memberCount in mockClubs equal to the number of members listed here.
final List<ClubMembership> mockClubMembers = [
  _member('c1', 'u1', 'Budi Santoso', role: ClubRole.admin),
  _member('c1', 'u2', 'Sari Wulandari'),
  _member('c1', 'u3', 'Andi Pratama'),
  _member('c1', 'u4', 'Dewi Lestari'),
  _member('c1', 'u5', 'Rizky Maulana'),
  _member('c1', 'u6', 'Maya Anggraini'),
  _member('c2', 'u5', 'Rizky Maulana', role: ClubRole.admin),
  _member('c2', 'u1', 'Budi Santoso'),
  _member('c2', 'u2', 'Sari Wulandari'),
  _member('c2', 'u3', 'Andi Pratama'),
  _member('c2', 'u6', 'Maya Anggraini'),
  _member('c3', 'u3', 'Andi Pratama', role: ClubRole.admin),
  _member('c4', 'u4', 'Dewi Lestari', role: ClubRole.admin),
  _member('c4', 'u2', 'Sari Wulandari'),
  _member('c5', 'u6', 'Maya Anggraini', role: ClubRole.admin),
  _member('c5', 'u1', 'Budi Santoso'),
  _member('c5', 'u5', 'Rizky Maulana'),
];

// ---------------------------------------------------------------- meets

final List<Meet> mockMeets = [
  // A finished padel round robin (3 pairs), so scoring and standings have
  // something to show.
  Meet(
    id: 'm0',
    clubId: 'c1',
    title: "Last Week's Padel Round Robin",
    sport: 'Padel',
    startsAt: _evening(-5),
    venueName: 'Senayan Padel Court',
    latitude: -6.2185,
    longitude: 106.8023,
    maxPlayers: 6,
    fee: 100000,
    createdBy: 'u1',
    status: MeetStatus.finished,
  ),
  // One spot left: join once to fill it, join again to reach the waitlist.
  Meet(
    id: 'm1',
    clubId: 'c1',
    title: 'Friday Night Padel',
    sport: 'Padel',
    description: 'Bring your own racket.',
    startsAt: _evening(2),
    venueName: 'Senayan Padel Court',
    latitude: -6.2185,
    longitude: 106.8023,
    maxPlayers: 4,
    fee: 100000,
    createdBy: 'u1',
  ),
  // Full, with one person on the waitlist. Created by u5, so the default
  // user (u1) is NOT allowed to manage it.
  Meet(
    id: 'm2',
    clubId: 'c2',
    title: 'Sunday Pickup Basketball',
    sport: 'Basketball',
    startsAt: _evening(4),
    venueName: 'Senayan Basketball Hall',
    latitude: -6.2250,
    longitude: 106.8000,
    maxPlayers: 4,
    fee: 30000,
    createdBy: 'u5',
  ),
  // Free session with plenty of room.
  Meet(
    id: 'm3',
    clubId: 'c1',
    title: 'Beginner Padel Clinic',
    sport: 'Padel',
    startsAt: _evening(6),
    venueName: 'Senayan Padel Court',
    latitude: -6.2185,
    longitude: 106.8023,
    maxPlayers: 8,
    createdBy: 'u1',
  ),
  // Running and pilates have no team scoring: no Scoring button for these.
  Meet(
    id: 'm4',
    clubId: 'c5',
    title: 'Saturday Morning 5K',
    sport: 'Running',
    startsAt: _morning(3),
    venueName: 'Kebun Raya Bogor',
    latitude: -6.5976,
    longitude: 106.7997,
    maxPlayers: 20,
    createdBy: 'u6',
  ),
  Meet(
    id: 'm5',
    clubId: 'c4',
    title: 'Sunrise Pilates Class',
    sport: 'Pilates',
    startsAt: _morning(5),
    venueName: 'Sanur Beach Studio',
    latitude: -8.6905,
    longitude: 115.2630,
    maxPlayers: 10,
    fee: 150000,
    createdBy: 'u4',
  ),
  // Mahjong is free-for-all, so it has no team A vs B scoring either.
  Meet(
    id: 'm6',
    clubId: 'c3',
    title: 'Mahjong Night',
    sport: 'Mahjong',
    startsAt: _evening(7),
    venueName: 'Dago Community Hall',
    latitude: -6.8915,
    longitude: 107.6107,
    maxPlayers: 4,
    createdBy: 'u3',
  ),
];

Rsvp _rsvp(
  String meetId,
  String userId,
  String userName, {
  RsvpStatus status = RsvpStatus.going,
  bool paid = false,
  bool checkedIn = false,
  int joinedDaysAgo = 3,
}) =>
    Rsvp(
      userId: userId,
      meetId: meetId,
      userName: userName,
      status: status,
      paid: paid,
      checkedIn: checkedIn,
      joinedAt: _now.subtract(Duration(days: joinedDaysAgo)),
      paidAt: paid ? _now.subtract(Duration(days: joinedDaysAgo)) : null,
    );

final List<Rsvp> mockRsvps = [
  _rsvp('m0', 'u1', 'Budi Santoso', paid: true, checkedIn: true, joinedDaysAgo: 9),
  _rsvp('m0', 'u2', 'Sari Wulandari', paid: true, checkedIn: true, joinedDaysAgo: 9),
  _rsvp('m0', 'u3', 'Andi Pratama', paid: true, checkedIn: true, joinedDaysAgo: 8),
  _rsvp('m0', 'u4', 'Dewi Lestari', paid: true, checkedIn: true, joinedDaysAgo: 8),
  _rsvp('m0', 'u5', 'Rizky Maulana', paid: true, checkedIn: true, joinedDaysAgo: 7),
  _rsvp('m0', 'u6', 'Maya Anggraini', paid: true, checkedIn: true, joinedDaysAgo: 7),
  _rsvp('m1', 'u1', 'Budi Santoso', paid: true),
  _rsvp('m1', 'u2', 'Sari Wulandari'),
  _rsvp('m1', 'u3', 'Andi Pratama'),
  _rsvp('m2', 'u5', 'Rizky Maulana', paid: true, joinedDaysAgo: 5),
  _rsvp('m2', 'u1', 'Budi Santoso', joinedDaysAgo: 4),
  _rsvp('m2', 'u3', 'Andi Pratama', joinedDaysAgo: 3),
  _rsvp('m2', 'u6', 'Maya Anggraini', joinedDaysAgo: 3),
  _rsvp('m2', 'u2', 'Sari Wulandari', status: RsvpStatus.waitlist, joinedDaysAgo: 1),
  _rsvp('m3', 'u1', 'Budi Santoso', joinedDaysAgo: 1),
  _rsvp('m4', 'u6', 'Maya Anggraini', joinedDaysAgo: 4),
  _rsvp('m4', 'u1', 'Budi Santoso', joinedDaysAgo: 2),
  _rsvp('m4', 'u5', 'Rizky Maulana', joinedDaysAgo: 1),
  _rsvp('m5', 'u4', 'Dewi Lestari', paid: true, joinedDaysAgo: 4),
  _rsvp('m5', 'u2', 'Sari Wulandari', joinedDaysAgo: 2),
  _rsvp('m6', 'u3', 'Andi Pratama', joinedDaysAgo: 1),
];

// -------------------------------------------------------------- matches

GameMatch _match(
  String id, {
  String? meetId,
  String? competitionId,
  required int round,
  int position = 0,
  int? court,
  required List<String> teamA,
  required List<String> teamB,
  int? scoreA,
  int? scoreB,
  String? nextMatchId,
  TeamSide? nextMatchSide,
}) {
  final finished = scoreA != null && scoreB != null;
  return GameMatch(
    id: id,
    meetId: meetId,
    competitionId: competitionId,
    round: round,
    position: position,
    court: court,
    teamA: teamA,
    teamB: teamB,
    scoreA: scoreA,
    scoreB: scoreB,
    status: finished ? MatchStatus.finished : MatchStatus.scheduled,
    nextMatchId: nextMatchId,
    nextMatchSide: nextMatchSide,
    playedAt: finished ? _now.subtract(const Duration(days: 5)) : null,
  );
}

final List<GameMatch> mockMatches = [
  // Padel round robin for meet m0: 3 pairs, so 3 rounds with one match each
  // (one pair sits out every round). Scores are sets won.
  // Pairs: [u1, u2], [u3, u4], [u5, u6]
  _match('m0-r1-1', meetId: 'm0', round: 1, court: 1, teamA: ['u3', 'u4'], teamB: ['u5', 'u6'], scoreA: 2, scoreB: 0),
  _match('m0-r2-1', meetId: 'm0', round: 2, court: 1, teamA: ['u1', 'u2'], teamB: ['u5', 'u6'], scoreA: 2, scoreB: 1),
  _match('m0-r3-1', meetId: 'm0', round: 3, court: 1, teamA: ['u1', 'u2'], teamB: ['u3', 'u4'], scoreA: 1, scoreB: 2),
  // 1v1 basketball bracket for competition comp1 (scores are points):
  // two semi-finals and a final. sf1 is finished, so its winner (u1)
  // already sits in the final.
  _match('comp1-sf1', competitionId: 'comp1', round: 1, position: 0, teamA: ['u1'], teamB: ['u5'], scoreA: 11, scoreB: 6, nextMatchId: 'comp1-final', nextMatchSide: TeamSide.a),
  _match('comp1-sf2', competitionId: 'comp1', round: 1, position: 1, teamA: ['u2'], teamB: ['u3'], nextMatchId: 'comp1-final', nextMatchSide: TeamSide.b),
  _match('comp1-final', competitionId: 'comp1', round: 2, position: 0, teamA: ['u1'], teamB: []),
];

// ---------------------------------------------------------- competitions

final List<Competition> mockCompetitions = [
  Competition(
    id: 'comp1',
    clubId: 'c2',
    title: 'Senayan 1v1 Basketball Cup',
    sport: 'Basketball',
    createdBy: 'u1',
    format: CompetitionFormat.singleElimination,
    status: CompetitionStatus.inProgress,
    playerIds: ['u1', 'u2', 'u3', 'u5'],
    seeds: {'u1': 1, 'u2': 2, 'u3': 3, 'u5': 4},
    maxPlayers: 4,
    startsAt: _evening(-1),
    createdAt: DateTime(2026, 2, 20),
  ),
  // Open for registration. Created by u5, so u1 is NOT allowed to manage it.
  Competition(
    id: 'comp2',
    clubId: 'c2',
    title: 'Weekend 1v1 Open',
    sport: 'Basketball',
    createdBy: 'u5',
    status: CompetitionStatus.registration,
    playerIds: ['u5', 'u6'],
    maxPlayers: 8,
    startsAt: _evening(14),
    createdAt: DateTime(2026, 2, 22),
  ),
];

// ----------------------------------------------------------------- chat

final List<Message> mockMessages = [
  Message(
    id: 'msg1',
    chatId: 'c1',
    senderId: 'u2',
    senderName: 'Sari Wulandari',
    text: 'Anyone up for padel on Friday?',
    sentAt: _now.subtract(const Duration(hours: 5)),
  ),
  Message(
    id: 'msg2',
    chatId: 'c1',
    senderId: 'u1',
    senderName: 'Budi Santoso',
    text: 'Yes! I booked the court at Senayan.',
    sentAt: _now.subtract(const Duration(hours: 4)),
  ),
  Message(
    id: 'msg3',
    chatId: 'c1',
    senderId: 'system',
    senderName: 'seek',
    text: 'Andi Pratama joined the club',
    sentAt: _now.subtract(const Duration(hours: 3)),
    isSystem: true,
  ),
];

// ------------------------------------------------------------- payments

final List<Payment> mockPayments = [
  Payment(
    id: 'pay1',
    meetId: 'm1',
    userId: 'u1',
    amount: 100000,
    method: PaymentMethod.bankTransfer,
    status: PaymentStatus.paid,
    confirmedBy: 'u1',
    paidAt: _now.subtract(const Duration(days: 2)),
    createdAt: _now.subtract(const Duration(days: 3)),
  ),
  Payment(
    id: 'pay2',
    meetId: 'm1',
    userId: 'u2',
    amount: 100000,
    createdAt: _now.subtract(const Duration(days: 2)),
  ),
  Payment(
    id: 'pay3',
    meetId: 'm1',
    userId: 'u3',
    amount: 100000,
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
];
