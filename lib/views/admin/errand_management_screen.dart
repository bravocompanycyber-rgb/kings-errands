import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kings_errands/widgets/errand_card.dart';

class ErrandManagementScreen extends StatelessWidget {
  const ErrandManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Errand Management')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('errands').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final errands = snapshot.data!.docs;

          if (errands.isEmpty) {
            return const Center(child: Text('No errands found.'));
          }

          return ListView.builder(
            itemCount: errands.length,
            itemBuilder: (context, index) {
              final errand = errands[index];
              return ErrandCard(errand: errand);
            },
          );
        },
      ),
    );
  }
}
