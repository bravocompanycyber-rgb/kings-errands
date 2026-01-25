import 'package:flutter/material.dart' hide RadioGroup;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kings_errands/services/auth_service.dart';
import 'package:kings_errands/widgets/radio_group.dart';

class CreateErrandScreen extends StatefulWidget {
  const CreateErrandScreen({super.key});

  @override
  State<CreateErrandScreen> createState() => _CreateErrandScreenState();
}

class _CreateErrandScreenState extends State<CreateErrandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _promoCodeController = TextEditingController();
  DateTime? _deadline;
  bool _isLoading = false;
  bool _isBulky = false;

  String? _selectedRoute;
  String? _selectedLocation;
  int? _price;
  int _basePrice = 0;
  int _extraCharge = 0;
  String _paymentOption = 'Pay Later';

  double _discountPercentage = 0.0;
  bool _promoCodeApplied = false;
  String? _promoCodeMessage;

  @override
  void initState() {
    super.initState();
    _fetchExtraCharges();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchExtraCharges() async {
    final doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('charges')
        .get();
    if (doc.exists) {
      setState(() {
        _extraCharge = doc.data()?['bulky_item_charge'] ?? 0;
      });
    }
  }

  void _updatePrice() {
    int originalPrice = _basePrice;
    if (_isBulky) {
      originalPrice += _extraCharge;
    }

    if (_promoCodeApplied) {
      _price = (originalPrice * (1 - _discountPercentage)).round();
    } else {
      _price = originalPrice;
    }
    setState(() {});
  }

  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _promoCodeMessage = 'Please enter a promo code';
      });
      return;
    }

    final promoCodeQuery = await FirebaseFirestore.instance
        .collection('promoCodes')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    if (promoCodeQuery.docs.isEmpty) {
      setState(() {
        _promoCodeMessage = 'Invalid promo code';
      });
      return;
    }

    final promoCodeDoc = promoCodeQuery.docs.first;
    final data = promoCodeDoc.data();
    final expiryDate = (data['expiryDate'] as Timestamp).toDate();

    if (expiryDate.isBefore(DateTime.now())) {
      setState(() {
        _promoCodeMessage = 'Promo code has expired';
      });
      return;
    }

    setState(() {
      _discountPercentage = (data['discount'] as num).toDouble() / 100;
      _promoCodeApplied = true;
      _promoCodeMessage = 'Promo code applied!';
      _updatePrice();
    });
  }

  void _removePromoCode() {
    setState(() {
      _promoCodeController.clear();
      _discountPercentage = 0.0;
      _promoCodeApplied = false;
      _promoCodeMessage = null;
      _updatePrice();
    });
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _createErrand() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_deadline == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a deadline.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final user = AuthService().currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('errands').add({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'price': _price,
            'deadline': Timestamp.fromDate(_deadline!),
            'customerId': user.uid,
            'status': 'posted', // Directly posted for runners
            'paymentStatus': _paymentOption == 'Pay Now' ? 'paid' : 'pending',
            'isBulky': _isBulky,
            'createdAt': FieldValue.serverTimestamp(),
            'route': _selectedRoute,
            'location': _selectedLocation,
            'promoCode': _promoCodeApplied ? _promoCodeController.text : null,
            'discountAmount': _promoCodeApplied
                ? (_basePrice * _discountPercentage)
                : null,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Errand posted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create errand: $e'),
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
      appBar: AppBar(title: const Text('Request a New Errand')),
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
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'What do you need done?',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a title';
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rates')
                        .orderBy('category')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final categories = snapshot.data!.docs;
                      Map<String, List<DocumentSnapshot>> groupedRates = {};
                      for (var rate in categories) {
                        final category = rate['category'] as String;
                        if (groupedRates[category] == null) {
                          groupedRates[category] = [];
                        }
                        groupedRates[category]!.add(rate);
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedRoute,
                        items: groupedRates.keys.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRoute = value;
                            _selectedLocation = null;
                            _price = null;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select Route',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a route';
                          } else {
                            return null;
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedRoute != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('rates')
                          .where('category', isEqualTo: _selectedRoute)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final locations = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedLocation,
                          items: locations.map((doc) {
                            final name = doc['name'] as String;
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLocation = value;
                              final selectedDoc = locations.firstWhere(
                                (doc) => doc['name'] == value,
                              );
                              _basePrice = selectedDoc['price'] as int;
                              _updatePrice();
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Select Location',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a location';
                            } else {
                              return null;
                            }
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Is this a bulky or heavy item?'),
                    value: _isBulky,
                    onChanged: (bool? value) {
                      setState(() {
                        _isBulky = value!;
                        _updatePrice();
                      });
                    },
                    subtitle: Text('Adds an extra charge of KES $_extraCharge'),
                  ),
                  const SizedBox(height: 16),
                  if (_price != null)
                    Text(
                      'Total Price: KES $_price',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _promoCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Promo Code',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_promoCodeApplied,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _promoCodeApplied
                            ? _removePromoCode
                            : _applyPromoCode,
                        child: Text(_promoCodeApplied ? 'Remove' : 'Apply'),
                      ),
                    ],
                  ),
                  if (_promoCodeMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _promoCodeMessage!,
                        style: TextStyle(
                          color: _promoCodeApplied ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Details',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _deadline == null
                              ? 'No deadline selected'
                              : 'Deadline: ${_deadline!.month}/${_deadline!.day}/${_deadline!.year}',
                        ),
                        TextButton(
                          onPressed: () => _selectDeadline(context),
                          child: const Text('Select Date'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Option',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  RadioGroupWidget<String>(
                    groupValue: _paymentOption,
                    onChanged: (String? value) {
                      setState(() {
                        _paymentOption = value!;
                      });
                    },
                    items: const [
                      RadioItem(label: 'Pay Now', value: 'Pay Now'),
                      RadioItem(label: 'Pay Later', value: 'Pay Later'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _createErrand,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Submit Errand'),
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