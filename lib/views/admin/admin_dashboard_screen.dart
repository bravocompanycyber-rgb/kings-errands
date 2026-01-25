import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kings_errands/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:kings_errands/widgets/app_footer.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.people,
            label: 'User Management',
            onTap: () => context.go('/admin/users'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.assignment,
            label: 'Errand Management',
            onTap: () => context.go('/errand-management'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.payment,
            label: 'Payment Management',
            onTap: () => context.go('/admin/payments'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.description,
            label: 'EULA Management',
            onTap: () => context.go('/admin/eula'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.message,
            label: 'Broadcast Messages',
            onTap: () => context.go('/admin/broadcast'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.help,
            label: 'FAQ Management',
            onTap: () => context.go('/admin/faq'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.attach_money,
            label: 'Rate Management',
            onTap: () => context.go('/admin/rates'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.monetization_on,
            label: 'Charge Management',
            onTap: () => context.go('/charge-management'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.local_offer,
            label: 'Promo Codes',
            onTap: () => context.go('/admin/promo-codes'),
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
