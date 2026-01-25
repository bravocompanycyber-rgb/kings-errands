import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PromoCodeManagementScreen extends StatefulWidget {
  const PromoCodeManagementScreen({super.key});

  @override
  State<PromoCodeManagementScreen> createState() =>
      _PromoCodeManagementScreenState();
}

class _PromoCodeManagementScreenState extends State<PromoCodeManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _promoCode;
  double? _discount;
  DateTime? _expiryDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promo Code Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPromoCodeForm(),
            const SizedBox(height: 20),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Existing Promo Codes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildPromoCodeList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Promo Code'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a promo code';
              }
              return null;
            },
            onSaved: (value) => _promoCode = value,
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Discount (%)'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a discount percentage';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onSaved: (value) => _discount = double.tryParse(value ?? '0'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _expiryDate == null
                      ? 'No expiry date chosen'
                      : 'Expiry: ${_expiryDate!.toLocal().toString().substring(0, 10)}',
                ),
              ),
              TextButton(
                onPressed: _selectExpiryDate,
                child: const Text('Choose Date'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addPromoCode,
            child: const Text('Add Promo Code'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _addPromoCode() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_expiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an expiry date')),
        );
        return;
      }

      _firestore.collection('promoCodes').add({
        'code': _promoCode,
        'discount': _discount,
        'expiryDate': _expiryDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _formKey.currentState!.reset();
      setState(() {
        _expiryDate = null;
      });
    }
  }

  Widget _buildPromoCodeList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('promoCodes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No promo codes found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              // Safe access to data
              final code = data['code'] as String? ?? 'N/A';
              final discount = data['discount'] as num? ?? 0;
              final timestamp = data['expiryDate'] as Timestamp?;
              final expiry = timestamp?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '$discount% off - Expires on ${expiry != null ? expiry.toLocal().toString().substring(0, 10) : 'N/A'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => doc.reference.delete(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
