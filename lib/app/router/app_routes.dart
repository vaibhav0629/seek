/// Every path in the app lives here. Use these instead of typing strings.
///
///   context.go(AppRoutes.discover);          // switch tab / replace screen
///   context.push(AppRoutes.meet(meetId));    // open a screen on top
class AppRoutes {
  AppRoutes._();

  // Login and the four bottom tabs
  static const login = '/login';
  static const discover = '/discover';
  static const myClubs = '/my-clubs';
  static const create = '/create';
  static const profile = '/profile';

  // Create flows
  static const newClub = '/clubs/new';
  static const newMeet = '/meets/new';

  // Detail screens
  static String club(String clubId) => '/clubs/$clubId';
  static String clubChat(String clubId) => '/clubs/$clubId/chat';
  static String meet(String meetId) => '/meets/$meetId';
  static String meetScoring(String meetId) => '/meets/$meetId/scoring';
  static String meetPayments(String meetId) => '/meets/$meetId/payments';
  static String competition(String competitionId) =>
      '/competitions/$competitionId';
}
