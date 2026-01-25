import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kings_errands/services/auth_service.dart';
import 'package:kings_errands/widgets/app_footer.dart';

class RunnerHomeScreen extends StatefulWidget {
  const RunnerHomeScreen({super.key});

  @override
  State<RunnerHomeScreen> createState() => _RunnerHomeScreenState();
}

class _RunnerHomeScreenState extends State<RunnerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome, Runner!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => context.push('/chat_list'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/available-errands'),
              child: const Text('View Available Errands'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/my-accepted-errands'),
              child: const Text('My Accepted Errands'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/profile'),
              child: const Text('My Profile'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
