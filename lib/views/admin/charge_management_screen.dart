import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChargeManagementScreen extends StatefulWidget {
  const ChargeManagementScreen({super.key});

  @override
  State<ChargeManagementScreen> createState() => _ChargeManagementScreenState();
}

class _ChargeManagementScreenState extends State<ChargeManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bulkyChargeController = TextEditingController();
  final _cancellationPenaltyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCharges();
  }

  @override
  void dispose() {
    _bulkyChargeController.dispose();
    _cancellationPenaltyController.dispose();
    super.dispose();
  }

  Future<void> _loadCharges() async {
    final doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('charges')
        .get();
    if (doc.exists) {
      _bulkyChargeController.text = (doc.data()?['bulky_item_charge'] ?? 0)
          .toString();
      _cancellationPenaltyController.text =
          (doc.data()?['cancellation_penalty'] ?? 0).toString();
    }
  }

  Future<void> _saveCharges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('settings')
            .doc('charges')
            .set({
              'bulky_item_charge':
                  int.tryParse(_bulkyChargeController.text) ?? 0,
              'cancellation_penalty':
                  int.tryParse(_cancellationPenaltyController.text) ?? 0,
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Charges updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update charges: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Charges')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _bulkyChargeController,
                    decoration: const InputDecoration(
                      labelText: 'Bulky/Heavy Item Charge (KES)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        (value == null || int.tryParse(value) == null)
                        ? 'Please enter a valid number'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cancellationPenaltyController,
                    decoration: const InputDecoration(
                      labelText: 'Cancellation Penalty (KES)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        (value == null || int.tryParse(value) == null)
                        ? 'Please enter a valid number'
                        : null,
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveCharges,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Save Charges'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
