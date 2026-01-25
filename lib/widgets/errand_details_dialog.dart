import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ErrandDetailsDialog extends StatelessWidget {
  final DocumentSnapshot errand;

  const ErrandDetailsDialog({super.key, required this.errand});

  @override
  Widget build(BuildContext context) {
    final errandData = errand.data() as Map<String, dynamic>;

    return AlertDialog(
      title: Text(errandData['title'] ?? 'No Title'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(errandData['description'] ?? 'No Description'),
            const SizedBox(height: 10),
            Text('Price: \$${errandData['price']}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
