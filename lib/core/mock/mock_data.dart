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
/// The mock login signs in as user "u1" (Budi). Ids are short and readable:
/// users u1-u5, clubs c1-c3, meets m0-m3, competitions comp1-comp2.

const String kMockCurrentUserId = 'u1';

final DateTime _now = DateTime.now();

DateTime _evening(int daysFromNow) {
  final day = _now.add(Duration(days: daysFromNow));
  return DateTime(day.year, day.month, day.day, 19);
}

// ---------------------------------------------------------------- users

final List<AppUser> mockUsers = [
  AppUser(
    id: 'u1',
    displayName: 'Budi Santoso',
    email: 'budi@example.com',
    city: 'Jakarta',
    sports: ['Pickleball', 'Badminton'],
    rating: 3.4,
    createdAt: DateTime(2026, 1, 10),
  ),
  AppUser(
    id: 'u2',
    displayName: 'Sari Wulandari',
    email: 'sari@example.com',
    city: 'Jakarta',
    sports: ['Pickleball', 'Padel'],
    rating: 3.8,
    createdAt: DateTime(2026, 1, 12),
  ),
  AppUser(
    id: 'u3',
    displayName: 'Andi Pratama',
    email: 'andi@example.com',
    city: 'Bandung',
    sports: ['Padel', 'Pickleball'],
    rating: 3.1,
    createdAt: DateTime(2026, 1, 15),
  ),
  AppUser(
    id: 'u4',
    displayName: 'Dewi Lestari',
    email: 'dewi@example.com',
    city: 'Jakarta',
    sports: ['Badminton'],
    rating: 4.2,
    createdAt: DateTime(2026, 1, 20),
  ),
  AppUser(
    id: 'u5',
    displayName: 'Rizky Maulana',
    email: 'rizky@example.com',
    city: 'Jakarta',
    sports: ['Badminton', 'Pickleball'],
    rating: 3.6,
    createdAt: DateTime(2026, 1, 25),
  ),
];

// ---------------------------------------------------------------- clubs

final List<Club> mockClubs = [
  Club(
    id: 'c1',
    name: 'Jakarta Pickle Crew',
    sport: 'Pickleball',
    city: 'Jakarta',
    ownerId: 'u1',
    description: 'Friendly pickleball sessions around Senayan.',
    memberCount: 4,
    createdAt: DateTime(2026, 2, 1),
  ),
  Club(
    id: 'c2',
    name: 'Senayan Smashers',
    sport: 'Badminton',
    city: 'Jakarta',
    ownerId: 'u4',
    description: 'Weekend badminton for all levels.',
    memberCount: 3,
    createdAt: DateTime(2026, 2, 5),
  ),
  Club(
    id: 'c3',
    name: 'Bandung Padel Club',
    sport: 'Padel',
    city: 'Bandung',
    ownerId: 'u3',
    description: 'Invite-only padel group.',
    isPrivate: true,
    memberCount: 1,
    createdAt: DateTime(2026, 2, 9),
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

final List<ClubMembership> mockClubMembers = [
  _member('c1', 'u1', 'Budi Santoso', role: ClubRole.admin),
  _member('c1', 'u2', 'Sari Wulandari'),
  _member('c1', 'u3', 'Andi Pratama'),
  _member('c1', 'u5', 'Rizky Maulana'),
  _member('c2', 'u4', 'Dewi Lestari', role: ClubRole.admin),
  _member('c2', 'u5', 'Rizky Maulana'),
  _member('c2', 'u2', 'Sari Wulandari'),
  _member('c3', 'u3', 'Andi Pratama', role: ClubRole.admin),
];

// ---------------------------------------------------------------- meets

final List<Meet> mockMeets = [
  // A finished session, so scoring and standings have something to show.
  Meet(
    id: 'm0',
    clubId: 'c1',
    title: "Last Week's Round Robin",
    sport: 'Pickleball',
    startsAt: _evening(-5),
    venueName: 'Senayan Sports Hall',
    latitude: -6.2185,
    longitude: 106.8023,
    maxPlayers: 4,
    fee: 50000,
    createdBy: 'u1',
    status: MeetStatus.finished,
  ),
  // One spot left: join once to fill it, join again to reach the waitlist.
  Meet(
    id: 'm1',
    clubId: 'c1',
    title: 'Friday Night Round Robin',
    sport: 'Pickleball',
    description: 'Bring your own paddle.',
    startsAt: _evening(2),
    venueName: 'Senayan Sports Hall',
    latitude: -6.2185,
    longitude: 106.8023,
    maxPlayers: 4,
    fee: 50000,
    createdBy: 'u1',
  ),
  // Full, with one person on the waitlist.
  Meet(
    id: 'm2',
    clubId: 'c2',
    title: 'Sunday Morning Smash',
    sport: 'Badminton',
    startsAt: _evening(4),
    venueName: 'Kemang GOR',
    latitude: -6.2607,
    longitude: 106.8133,
    maxPlayers: 2,
    fee: 30000,
    createdBy: 'u4',
  ),
  // Free session with plenty of room.
  Meet(
    id: 'm3',
    clubId: 'c1',
    title: 'Beginner Open Play',
    sport: 'Pickleball',
    startsAt: _evening(6),
    venueName: 'Senayan Sports Hall',
    latitude: -6.2185,
    longitude: 106.8023,
    maxPlayers: 8,
    createdBy: 'u1',
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
  _rsvp('m0', 'u5', 'Rizky Maulana', paid: true, checkedIn: true, joinedDaysAgo: 8),
  _rsvp('m1', 'u1', 'Budi Santoso', paid: true),
  _rsvp('m1', 'u2', 'Sari Wulandari'),
  _rsvp('m1', 'u3', 'Andi Pratama'),
  _rsvp('m2', 'u4', 'Dewi Lestari', paid: true, joinedDaysAgo: 5),
  _rsvp('m2', 'u5', 'Rizky Maulana', joinedDaysAgo: 4),
  _rsvp('m2', 'u2', 'Sari Wulandari', status: RsvpStatus.waitlist, joinedDaysAgo: 1),
  _rsvp('m3', 'u1', 'Budi Santoso', joinedDaysAgo: 1),
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
  // Round robin for meet m0: 4 players, 3 rounds of 2 matches.
  _match('m0-r1-1', meetId: 'm0', round: 1, position: 0, court: 1, teamA: ['u1'], teamB: ['u2'], scoreA: 11, scoreB: 7),
  _match('m0-r1-2', meetId: 'm0', round: 1, position: 1, court: 2, teamA: ['u3'], teamB: ['u5'], scoreA: 9, scoreB: 11),
  _match('m0-r2-1', meetId: 'm0', round: 2, position: 0, court: 1, teamA: ['u1'], teamB: ['u3'], scoreA: 11, scoreB: 4),
  _match('m0-r2-2', meetId: 'm0', round: 2, position: 1, court: 2, teamA: ['u2'], teamB: ['u5'], scoreA: 8, scoreB: 11),
  _match('m0-r3-1', meetId: 'm0', round: 3, position: 0, court: 1, teamA: ['u1'], teamB: ['u5'], scoreA: 11, scoreB: 9),
  _match('m0-r3-2', meetId: 'm0', round: 3, position: 1, court: 2, teamA: ['u2'], teamB: ['u3'], scoreA: 11, scoreB: 6),
  // Bracket for competition comp1: two semi-finals and a final.
  // sf1 is finished, so its winner (u1) already sits in the final.
  _match('comp1-sf1', competitionId: 'comp1', round: 1, position: 0, teamA: ['u1'], teamB: ['u5'], scoreA: 11, scoreB: 6, nextMatchId: 'comp1-final', nextMatchSide: TeamSide.a),
  _match('comp1-sf2', competitionId: 'comp1', round: 1, position: 1, teamA: ['u2'], teamB: ['u3'], nextMatchId: 'comp1-final', nextMatchSide: TeamSide.b),
  _match('comp1-final', competitionId: 'comp1', round: 2, position: 0, teamA: ['u1'], teamB: []),
];

// ---------------------------------------------------------- competitions

final List<Competition> mockCompetitions = [
  Competition(
    id: 'comp1',
    clubId: 'c1',
    title: 'Jakarta Pickle Cup',
    sport: 'Pickleball',
    createdBy: 'u1',
    format: CompetitionFormat.singleElimination,
    status: CompetitionStatus.inProgress,
    playerIds: ['u1', 'u2', 'u3', 'u5'],
    seeds: {'u1': 1, 'u2': 2, 'u3': 3, 'u5': 4},
    maxPlayers: 4,
    startsAt: _evening(-1),
    createdAt: DateTime(2026, 2, 20),
  ),
  Competition(
    id: 'comp2',
    clubId: 'c2',
    title: 'Senayan Badminton Open',
    sport: 'Badminton',
    createdBy: 'u4',
    status: CompetitionStatus.registration,
    playerIds: ['u4', 'u5'],
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
    text: 'Anyone up for Friday?',
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
    amount: 50000,
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
    amount: 50000,
    createdAt: _now.subtract(const Duration(days: 2)),
  ),
  Payment(
    id: 'pay3',
    meetId: 'm1',
    userId: 'u3',
    amount: 50000,
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
];
