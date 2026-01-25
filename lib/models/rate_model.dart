import 'package:cloud_firestore/cloud_firestore.dart';

class Rate {
  final String id;
  final String category;
  final String location;
  final double price;

  Rate({
    required this.id,
    required this.category,
    required this.location,
    required this.price,
  });

  factory Rate.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Rate(
      id: doc.id,
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }
}
