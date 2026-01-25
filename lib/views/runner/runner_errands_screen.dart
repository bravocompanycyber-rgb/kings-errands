import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:kings_errands/widgets/errand_card.dart';

class RunnerErrandsScreen extends StatelessWidget {
  const RunnerErrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Errands')),
      body: user == null
          ? const Center(child: Text('Please log in to see your errands.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('errands')
                  .where('runnerId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('You have no errands assigned.'),
                  );
                }

                final errands = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: errands.length,
                  itemBuilder: (context, index) {
                    final errand = errands[index];
                    return GestureDetector(
                      onTap: () => context.go('/errand-details/${errand.id}'),
                      child: ErrandCard(errand: errand),
                    );
                  },
                );
              },
            ),
    );
  }
}
