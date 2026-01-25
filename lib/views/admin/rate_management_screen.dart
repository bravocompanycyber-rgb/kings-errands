import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RateManagementScreen extends StatefulWidget {
  const RateManagementScreen({super.key});

  @override
  State<RateManagementScreen> createState() => _RateManagementScreenState();
}

class _RateManagementScreenState extends State<RateManagementScreen> {
  @override
  void initState() {
    super.initState();
    _populateInitialRates();
  }

  Future<void> _populateInitialRates() async {
    final ratesCollection = FirebaseFirestore.instance.collection('rates');
    final snapshot = await ratesCollection.limit(1).get();

    if (snapshot.docs.isEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      final initialRates = {
        'Town Service': {
          'Nairobi CBD': 100,
          'Uptown': 150,
          'Town -> Upper hill': 300,
          'Town -> Yaya': 350,
        },
        'Westlands': {
          'Parkland': 350,
          'Riverside drive': 400,
          'ABC place': 400,
        },
        'Mombasa Road': {
          'Nyayo Stadium': 350,
          'South C': 400,
          'GM': 450,
          'South field': 500,
          'Syokimau': 600,
          'Athi River': 800,
          'Kitengela': 800,
        },
        'Ngong Road': {
          'Junction mall': 450,
          'Karen': 500,
          'Lavington': 500,
          'Kilimani': 500,
        },
        'Thika Road': {
          'Muthaiga': 350,
          'TRM mall': 450,
          'Kahawa sukari': 600,
          'Kamakis': 500,
          'Kasarani': 600,
        },
        'Jogoo Road': {
          'Stadium': 300,
          'Hamza': 350,
          'Buru buru': 450,
          'Donhom': 500,
          'Umoja': 500,
        },
      };

      initialRates.forEach((category, rates) {
        rates.forEach((name, price) {
          final docRef = ratesCollection.doc();
          batch.set(docRef, {
            'category': category,
            'name': name,
            'price': price,
          });
        });
      });

      await batch.commit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showRateDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rates')
            .orderBy('category')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rates = snapshot.data!.docs;
          // Group by category
          Map<String, List<QueryDocumentSnapshot>> groupedRates = {};
          for (var rate in rates) {
            final category = rate['category'] as String;
            if (groupedRates[category] == null) {
              groupedRates[category] = [];
            }
            groupedRates[category]!.add(rate);
          }

          final categories = groupedRates.keys.toList();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryRates = groupedRates[category]!;

              return ExpansionTile(
                title: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                children: categoryRates.map((rate) {
                  return ListTile(
                    title: Text(rate['name']),
                    subtitle: Text('KES ${rate['price']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showRateDialog(rate: rate),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRate(rate.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

  void _showRateDialog({DocumentSnapshot? rate}) {
    final nameController = TextEditingController(text: rate?['name']);
    final priceController = TextEditingController(
      text: rate?['price']?.toString(),
    );
    final categoryController = TextEditingController(text: rate?['category']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(rate == null ? 'Add Rate' : 'Edit Rate'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Location Name'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (KES)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final price = int.tryParse(priceController.text);
                final category = categoryController.text;
                if (name.isNotEmpty && price != null && category.isNotEmpty) {
                  if (rate == null) {
                    _addRate(category, name, price);
                  } else {
                    _updateRate(rate.id, category, name, price);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addRate(String category, String name, int price) async {
    await FirebaseFirestore.instance.collection('rates').add({
      'category': category,
      'name': name,
      'price': price,
    });
  }

  Future<void> _updateRate(
    String id,
    String category,
    String name,
    int price,
  ) async {
    await FirebaseFirestore.instance.collection('rates').doc(id).update({
      'category': category,
      'name': name,
      'price': price,
    });
  }

  Future<void> _deleteRate(String id) async {
    await FirebaseFirestore.instance.collection('rates').doc(id).delete();
  }
}
