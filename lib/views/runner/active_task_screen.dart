import 'package:flutter/material.dart';

class ActiveTaskScreen extends StatelessWidget {
  const ActiveTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Task')),
      body: const Center(child: Text('Active Task Screen')),
    );
  }
}
