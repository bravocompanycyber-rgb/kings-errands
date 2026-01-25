import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kings_errands/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:kings_errands/providers/theme_provider.dart';
import 'package:kings_errands/views/customer/customer_home_screen.dart';
import 'package:kings_errands/views/runner/runner_home_screen.dart';
import 'package:kings_errands/views/admin/admin_dashboard_screen.dart';
import 'package:kings_errands/widgets/app_footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final themeProvider = Provider.of<ThemeProvider>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('Not authenticated')));
        }
        final user = snapshot.data!;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('User data not found.')),
              );
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = userData['role'];

            Widget body;
            String title;
            if (role == 'admin') {
              body = const AdminDashboardScreen();
              title = 'Admin Dashboard';
            } else if (role == 'runner') {
              body = const RunnerHomeScreen();
              title = 'Runner Home';
            } else {
              body = const CustomerHomeScreen();
              title = 'Home';
            }

            List<Widget> appBarActions = [
              IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: 'Toggle Theme',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context.go('/profile');
                },
              ),
            ];

            if (role == 'runner' || role == 'admin') {
              appBarActions.add(
                IconButton(
                  icon: const Icon(Icons.reviews),
                  onPressed: () {
                    context.go('/reviews');
                  },
                  tooltip: 'See Reviews',
                ),
              );
            }

            appBarActions.add(
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  authService.signOut();
                  context.go('/');
                },
              ),
            );

            return Scaffold(
              appBar: AppBar(title: Text(title), actions: appBarActions),
              body: body,
              bottomNavigationBar: const AppFooter(),
            );
          },
        );
      },
    );
  }
}
