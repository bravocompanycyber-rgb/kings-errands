import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kings_errands/widgets/errand_card.dart';

class MyAcceptedErrandsScreen extends StatefulWidget {
  const MyAcceptedErrandsScreen({super.key});

  @override
  State<MyAcceptedErrandsScreen> createState() =>
      _MyAcceptedErrandsScreenState();
}

class _MyAcceptedErrandsScreenState extends State<MyAcceptedErrandsScreen> {
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
      appBar: AppBar(title: const Text('My Accepted Errands')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('errands')
            .where('runnerId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'accepted')
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
              child: Text('You have not accepted any errands yet.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final errandDoc = snapshot.data!.docs[index];
              return ErrandCard(
                errand: errandDoc,
              );
            },
          );
        },
      ),
    );
  }
}
