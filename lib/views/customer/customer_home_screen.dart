import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kings_errands/services/auth_service.dart';
import 'package:kings_errands/widgets/app_footer.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome, Customer!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => context.go('/chat_list'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/create-errand'),
              child: const Text('Request a New Errand'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/my-errands'),
              child: const Text('View My Errands'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
