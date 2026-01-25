import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kings_errands/services/auth_service.dart';
import 'package:kings_errands/views/admin/admin_dashboard_screen.dart';
import 'package:kings_errands/views/eula_screen.dart';
import 'package:kings_errands/views/auth/login_screen.dart';
import 'package:kings_errands/views/auth/signup_screen.dart';
import 'package:kings_errands/views/customer/customer_home_screen.dart';
import 'package:kings_errands/views/runner/runner_home_screen.dart';

GoRouter createRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/login',
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/customer-home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/runner-home',
        builder: (context, state) => const RunnerHomeScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/eula',
        builder: (context, state) => const EulaScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final user = authService.currentUser;
      final isLoggedIn = user != null;
      final location = state.uri.toString();

      // If the user is not logged in, only allow access to login and signup pages.
      if (!isLoggedIn &&
          !location.startsWith('/login') &&
          !location.startsWith('/signup')) {
        return '/login';
      }

      // Handle logic for logged-in users.
      if (isLoggedIn) {
        // Show a loading indicator while fetching user details
        final userDetailsFuture = authService.getUserDetails();
        final userDetails = await userDetailsFuture;

        // If userDetails are not available yet, don't redirect.
        // This can be handled by showing a loading screen in the UI. For now, we prevent redirection.
        if (userDetails == null) {
          return null;
        }

        final userType = userDetails['userType'];
        final eulaAccepted = userDetails['eulaAccepted'] ?? false;

        // For non-customer roles, enforce EULA acceptance.
        if (userType != 'Customer' && !eulaAccepted && location != '/eula') {
          return '/eula';
        }

        // If the user is on a public page (login, signup) or has accepted the EULA,
        // redirect them to their respective dashboard.
        if (location.startsWith('/login') ||
            location.startsWith('/signup') ||
            (location == '/eula' && eulaAccepted)) {
          switch (userType) {
            case 'Admin':
              return '/admin-dashboard';
            case 'Runner':
              return '/runner-home';
            case 'Customer':
            default: // Default to customer home for any other case.
              return '/customer-home';
          }
        }
      }

      // In all other cases, no redirect is necessary.
      return null;
    },
  );
}
