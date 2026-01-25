import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptScreen extends StatelessWidget {
  final String errandId;

  const ReceiptScreen({super.key, required this.errandId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('errands')
            .doc(errandId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final errand = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Image.asset('assets/logo/logo.png', height: 100)),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Kings Errands',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                Text(
                  'Errand: ${errand['title']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Description: ${errand['description']}'),
                Text('Price: \$${errand['price']}'),
                Text('Payment Method: ${errand['paymentMethod']}'),
                const Divider(),
                Text('Customer: ${errand['customerName']}'),
                Text('Runner: ${errand['runnerName'] ?? 'Not assigned'}'),
                const Divider(),
                Text('Date: ${errand['createdAt'].toDate()}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
