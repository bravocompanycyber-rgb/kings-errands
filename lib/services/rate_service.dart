import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kings_errands/models/rate_model.dart';

class RateService {
  final CollectionReference _ratesCollection = FirebaseFirestore.instance
      .collection('rates');

  Future<void> addRate(Rate rate) {
    return _ratesCollection.add({
      'category': rate.category,
      'location': rate.location,
      'price': rate.price,
    });
  }

  Stream<List<Rate>> getRates() {
    return _ratesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Rate.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateRate(Rate rate) {
    return _ratesCollection.doc(rate.id).update({
      'category': rate.category,
      'location': rate.location,
      'price': rate.price,
    });
  }

  Future<void> deleteRate(String id) {
    return _ratesCollection.doc(id).delete();
  }

  Future<void> populateRates() async {
    final snapshot = await _ratesCollection.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return; // Rates already exist
    }

    final List<Map<String, dynamic>> rates = [
      // TOWN SERVICE
      {'category': 'Town Service', 'location': 'Nairobi CBD', 'price': 100.0},
      {'category': 'Town Service', 'location': 'Uptown', 'price': 150.0},
      {
        'category': 'Town Service',
        'location': 'Town --> Upper hill',
        'price': 300.0,
      },
      {'category': 'Town Service', 'location': 'Town -Yaya->', 'price': 350.0},

      // WESTLANDS
      {'category': 'Westlands', 'location': 'Parkland', 'price': 350.0},
      {'category': 'Westlands', 'location': 'Riverside drive', 'price': 400.0},
      {'category': 'Westlands', 'location': 'ABC place', 'price': 400.0},

      // MOMBASA ROAD
      {'category': 'Mombasa Road', 'location': 'Nyayo Stadium', 'price': 350.0},
      {'category': 'Mombasa Road', 'location': 'South C', 'price': 400.0},
      {'category': 'Mombasa Road', 'location': 'GM', 'price': 450.0},
      {'category': 'Mombasa Road', 'location': 'South field', 'price': 500.0},
      {'category': 'Mombasa Road', 'location': 'Syokimau', 'price': 600.0},
      {'category': 'Mombasa Road', 'location': 'Athi River', 'price': 800.0},
      {'category': 'Mombasa Road', 'location': 'Kitengela', 'price': 800.0},

      // NGONG ROAD
      {'category': 'Ngong Road', 'location': 'Junction mall', 'price': 450.0},
      {'category': 'Ngong Road', 'location': 'Karen', 'price': 500.0},
      {'category': 'Ngong Road', 'location': 'Lavington', 'price': 500.0},
      {'category': 'Ngong Road', 'location': 'Kilimani', 'price': 500.0},

      // THIKA ROAD
      {'category': 'Thika Road', 'location': 'Muthaiga', 'price': 350.0},
      {'category': 'Thika Road', 'location': 'TRM mall', 'price': 450.0},
      {'category': 'Thika Road', 'location': 'Kahawa sukari', 'price': 600.0},
      {'category': 'Thika Road', 'location': 'Kamakis', 'price': 500.0},
      {'category': 'Thika Road', 'location': 'Kasarani', 'price': 600.0},

      // JOGOO ROAD
      {'category': 'Jogoo Road', 'location': 'Stadium', 'price': 300.0},
      {'category': 'Jogoo Road', 'location': 'Hamza', 'price': 350.0},
      {'category': 'Jogoo Road', 'location': 'Buru buru', 'price': 450.0},
      {'category': 'Jogoo Road', 'location': 'Donhom', 'price': 500.0},
      {'category': 'Jogoo Road', 'location': 'Umoja', 'price': 500.0},
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (var rate in rates) {
      final docRef = _ratesCollection.doc();
      batch.set(docRef, rate);
    }
    await batch.commit();
  }
}
