
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrandBiddingScreen extends StatefulWidget {
  final String errandId;

  const ErrandBiddingScreen({super.key, required this.errandId});

  @override
  ErrandBiddingScreenState createState() => ErrandBiddingScreenState();
}

class ErrandBiddingScreenState extends State<ErrandBiddingScreen> {
  final _bidController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _placeBid() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('errands')
            .doc(widget.errandId)
            .collection('bids')
            .doc(user.uid)
            .set({
          'bidAmount': double.parse(_bidController.text),
          'runnerId': user.uid,
          'runnerName': user.displayName ?? 'Anonymous',
          'timestamp': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place a Bid'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _bidController,
                decoration: const InputDecoration(
                  labelText: 'Your Bid Amount',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bid amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _placeBid,
                child: const Text('Place Bid'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
