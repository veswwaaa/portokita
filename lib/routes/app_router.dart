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
import '../screen/lupa_password_screen.dart';
import '../screen/edit_profile_page.dart';
import '../screen/saved_portofolio_page.dart';
import '../screen/liked_portofolio_page.dart';
import '../services/app_state_service.dart';
import '../models/user_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  static bool _hasEvaluatedInitialLocation = false;

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      if (!_hasEvaluatedInitialLocation) {
        _hasEvaluatedInitialLocation = true;
        if (state.uri.path != '/splash') {
          return '/splash';
        }
      }
      return null;
    },
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
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const LupaPasswordScreen(),
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

          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return EditProfilePage(user: user);
        },
      ),
      GoRoute(
        path: '/saved-portfolios',
        name: 'saved-portfolios',
        builder: (context, state) => const SavedPortofolioPage(),
      ),
      GoRoute(
        path: '/liked-portfolios',
        name: 'liked-portfolios',
        builder: (context, state) => const LikedPortofolioPage(),
      ),
    ],
    observers: [_RouteObserver()],
  );
}

/// Observer untuk menyimpan setiap route change
class _RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _saveCurrentRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _saveCurrentRoute(newRoute);
    }
  }

  void _saveCurrentRoute(Route route) {
    // Dapatkan route path dari GoRoute settings
    if (route.settings.name != null && route.settings.name != '/splash') {
      AppStateService.saveLastRoute('/${route.settings.name}');
    }
  }
}
