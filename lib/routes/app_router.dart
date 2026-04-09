import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import '../screen/spalshScreen.dart';
import '../component/main_navigation.dart';
import '../screen/homepage.dart';
import '../screen/searchpage.dart';
import '../screen/upload_portfolio.dart';
import '../screen/profilepage.dart';
// import '../screen/splash_screen.dart';
import '../screen/splash_screen1.dart';
import '../screen/register_screen.dart';
import '../component/login_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          final skip = state.uri.queryParameters['skip'] == 'true';
          return SplashScreen(showImmediately: skip);
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterFormContainer(),
      ),
      // Shell Route dengan Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          // Home Route
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: HomePage()),
          ),

          // Search Route
          GoRoute(
            path: '/search',
            name: 'search',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: SearchPage()),
          ),

          // Upload Route
          GoRoute(
            path: '/upload',
            name: 'upload',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: UploadPortfolio()),
          ),

          // Profile Route
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),
    ],
  );
}
