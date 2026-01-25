import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kings_errands/widgets/errand_card.dart';

class AvailableErrandsScreen extends StatefulWidget {
  const AvailableErrandsScreen({super.key});

  @override
  State<AvailableErrandsScreen> createState() => _AvailableErrandsScreenState();
}

class _AvailableErrandsScreenState extends State<AvailableErrandsScreen> {
  final ErrandService _errandService = ErrandService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Errands')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _errandService.getAvailableErrands(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final errands = snapshot.data!.docs;

          if (errands.isEmpty) {
            return const Center(
              child: Text('No errands available at the moment.'),
            );
          }

          return ListView.builder(
            itemCount: errands.length,
            itemBuilder: (context, index) {
              final errand = errands[index];
              return ErrandCard(
                errand: errand,
              );
            },
          );
        },
      ),
    );
  }
}

class ErrandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAvailableErrands() {
    return _firestore
        .collection('errands')
        .where('status', isEqualTo: 'posted')
        .snapshots();
  }

  Future<void> acceptErrand(String errandId, String runnerId) {
    return _firestore.collection('errands').doc(errandId).update({
      'status': 'accepted',
      'runnerId': runnerId,
    });
  }
}
