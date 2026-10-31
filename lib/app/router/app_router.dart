import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/app/router/app_routes.dart';
import 'package:seek/app/shell/create_screen.dart';
import 'package:seek/app/shell/main_shell.dart';
import 'package:seek/core/config/app_config.dart';
import 'package:seek/core/utils/auth_refresh_notifier.dart';
import 'package:seek/features/auth/presentation/screens/login_screen.dart';
import 'package:seek/features/chat/presentation/screens/chat_screen.dart';
import 'package:seek/features/clubs/presentation/screens/club_detail_screen.dart';
import 'package:seek/features/clubs/presentation/screens/create_club_screen.dart';
import 'package:seek/features/clubs/presentation/screens/my_clubs_screen.dart';
import 'package:seek/features/competitions/presentation/screens/competition_screen.dart';
import 'package:seek/features/discover/presentation/screens/discover_screen.dart';
import 'package:seek/features/meets/presentation/screens/create_meet_screen.dart';
import 'package:seek/features/meets/presentation/screens/meet_detail_screen.dart';
import 'package:seek/features/payments/presentation/screens/payments_screen.dart';
import 'package:seek/features/profile/presentation/screens/profile_screen.dart';
import 'package:seek/features/scoring/presentation/screens/scoring_screen.dart';

/// The app's router. Owned by the tech lead.
///
/// To add a screen: create it in your feature's presentation/screens folder,
/// add its path to AppRoutes, then add one GoRoute below.
final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh =
      AuthRefreshNotifier(FirebaseAuth.instance.authStateChanges());
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.discover,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      if (kBypassAuth) return null;
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final onLogin = state.matchedLocation == AppRoutes.login;
      if (!loggedIn && !onLogin) return AppRoutes.login;
      if (loggedIn && onLogin) return AppRoutes.discover;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // The four bottom tabs. Each tab keeps its own screen history.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.discover,
              builder: (context, state) => const DiscoverScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.myClubs,
              builder: (context, state) => const MyClubsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.create,
              builder: (context, state) => const CreateScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // Full-screen routes (open on top of the tabs).
      // The "new" routes MUST stay above the ":id" routes, otherwise
      // /clubs/new would be read as a club with the id "new".
      GoRoute(
        path: AppRoutes.newClub,
        builder: (context, state) => const CreateClubScreen(),
      ),
      GoRoute(
        path: AppRoutes.newMeet,
        builder: (context, state) => const CreateMeetScreen(),
      ),
      GoRoute(
        path: '/clubs/:clubId',
        builder: (context, state) =>
            ClubDetailScreen(clubId: state.pathParameters['clubId']!),
        routes: [
          GoRoute(
            path: 'chat',
            builder: (context, state) =>
                ChatScreen(clubId: state.pathParameters['clubId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/meets/:meetId',
        builder: (context, state) =>
            MeetDetailScreen(meetId: state.pathParameters['meetId']!),
        routes: [
          GoRoute(
            path: 'scoring',
            builder: (context, state) =>
                ScoringScreen(meetId: state.pathParameters['meetId']!),
          ),
          GoRoute(
            path: 'payments',
            builder: (context, state) =>
                PaymentsScreen(meetId: state.pathParameters['meetId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/competitions/:competitionId',
        builder: (context, state) => CompetitionScreen(
          competitionId: state.pathParameters['competitionId']!,
        ),
      ),
    ],
  );
});
