import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:kings_errands/widgets/errand_card.dart';

class MyErrandsScreen extends StatefulWidget {
  const MyErrandsScreen({super.key});

  @override
  State<MyErrandsScreen> createState() => _MyErrandsScreenState();
}

class _MyErrandsScreenState extends State<MyErrandsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You need to be logged in to view your errands.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Errands')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('errands')
            .where('customerId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have not posted any errands yet.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final errandDoc = snapshot.data!.docs[index];
              return ErrandCard(
                errand: errandDoc,
                showCancelButton: true,
                showReviewButton: true,
                showReceiptButton: true,
                onCancel: () => _cancelErrand(errandDoc),
                onReview: () => context.push('/review/${errandDoc.id}'),
                onViewReceipt: () => context.push('/receipt/${errandDoc.id}'),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _cancelErrand(DocumentSnapshot errandDoc) async {
    final errandData = errandDoc.data() as Map<String, dynamic>;
    final errandId = errandDoc.id;
    final status = errandData['status'];

    try {
      if (status == 'posted') {
        // Just delete the errand, no penalty
        await _firestore.collection('errands').doc(errandId).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errand cancelled successfully.')),
        );
      } else if (status == 'accepted') {
        // Apply penalty
        final chargesDoc = await _firestore
            .collection('settings')
            .doc('charges')
            .get();
        final penalty = chargesDoc.data()?['cancellation_penalty'] ?? 100;

        await _firestore.collection('errands').doc(errandId).update({
          'status': 'cancelled_by_customer',
          'cancellationPenalty': penalty,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Errand cancelled. A penalty of KES $penalty has been applied.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to cancel errand: $e')));
    }
  }
}
