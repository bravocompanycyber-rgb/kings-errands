import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kings_errands/models/errand_model.dart';
import 'package:kings_errands/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update user data
  Future<void> setUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'name': user.name,
      'email': user.email,
      'role': user.role,
    });
  }

  // Create a new errand
  Future<void> createErrand(ErrandModel errand) async {
    await _firestore.collection('errands').doc(errand.id).set({
      'customerId': errand.customerId,
      'description': errand.description,
      'price': errand.price,
      'status': errand.status.toString(),
      'location': errand.location,
    });
  }

  // Get a stream of all errands
  Stream<List<ErrandModel>> getErrands() {
    return _firestore.collection('errands').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ErrandModel(
          id: doc.id,
          customerId: doc['customerId'],
          description: doc['description'],
          price: doc['price'],
          status: ErrandStatus.values.firstWhere(
            (e) => e.toString() == doc['status'],
          ),
          location: doc['location'],
          runnerId: doc['runnerId'],
        );
      }).toList();
    });
  }

  // Update an errand's status
  Future<void> updateErrandStatus(
    String errandId,
    ErrandStatus status, {
    String? runnerId,
  }) async {
    Map<String, dynamic> data = {'status': status.toString()};
    if (runnerId != null) {
      data['runnerId'] = runnerId;
    }
    await _firestore.collection('errands').doc(errandId).update(data);
  }
}
