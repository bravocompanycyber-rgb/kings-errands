import 'package:flutter/material.dart';
import 'package:kings_errands/models/rate_model.dart';
import 'package:kings_errands/services/rate_service.dart';

class RatesManagementScreen extends StatefulWidget {
  const RatesManagementScreen({super.key});

  @override
  State<RatesManagementScreen> createState() => _RatesManagementScreenState();
}

class _RatesManagementScreenState extends State<RatesManagementScreen> {
  final RateService _rateService = RateService();

  @override
  void initState() {
    super.initState();
    _rateService.populateRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Rates')),
      body: StreamBuilder<List<Rate>>(
        stream: _rateService.getRates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No rates found.'));
          }

          final rates = snapshot.data!;
          return ListView.builder(
            itemCount: rates.length,
            itemBuilder: (context, index) {
              final rate = rates[index];
              return ListTile(
                title: Text(rate.location),
                subtitle: Text(rate.category),
                trailing: Text('Ksh ${rate.price.toStringAsFixed(2)}'),
                onTap: () => _showAddEditRateDialog(rate: rate),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditRateDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditRateDialog({Rate? rate}) {
    final formKey = GlobalKey<FormState>();
    final categoryController = TextEditingController(text: rate?.category);
    final locationController = TextEditingController(text: rate?.location);
    final priceController = TextEditingController(text: rate?.price.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(rate == null ? 'Add Rate' : 'Edit Rate'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a category' : null,
                ),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a location' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a price' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newRate = Rate(
                    id: rate?.id ?? '',
                    category: categoryController.text,
                    location: locationController.text,
                    price: double.parse(priceController.text),
                  );
                  if (rate == null) {
                    await _rateService.addRate(newRate);
                  } else {
                    await _rateService.updateRate(newRate);
                  }
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(rate == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }
}
