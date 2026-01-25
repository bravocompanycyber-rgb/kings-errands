import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final int currentYear = DateTime.now().year;
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withAlpha(128),
      child: Center(
        child: Text(
          '© $currentYear BravoCompanyCyber™',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
