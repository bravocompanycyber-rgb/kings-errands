import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

class ErrandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'errands';

  // Create a new errand
  Future<void> createErrand(
    String title,
    String description,
    String location,
    double fee,
    String customerId,
  ) async {
    try {
      await _firestore.collection(_collectionName).add({
        'title': title,
        'description': description,
        'location': location,
        'fee': fee,
        'customerId': customerId,
        'status': 'new', // new, accepted, completed
        'runnerId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log(e.toString());
    }
  }

  // Get all available errands
  Stream<QuerySnapshot> getAvailableErrands() {
    return _firestore
        .collection(_collectionName)
        .where('status', isEqualTo: 'new')
        .snapshots();
  }

  // Get errands for a specific customer
  Stream<QuerySnapshot> getCustomerErrands(String customerId) {
    return _firestore
        .collection(_collectionName)
        .where('customerId', isEqualTo: customerId)
        .snapshots();
  }

  // Get errands for a specific runner
  Stream<QuerySnapshot> getRunnerErrands(String runnerId) {
    return _firestore
        .collection(_collectionName)
        .where('runnerId', isEqualTo: runnerId)
        .snapshots();
  }

  // Get accepted errands for a specific runner
  Stream<QuerySnapshot> getAcceptedErrands(String runnerId) {
    return _firestore
        .collection(_collectionName)
        .where('runnerId', isEqualTo: runnerId)
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  // Accept an errand
  Future<void> acceptErrand(String errandId, String runnerId) async {
    try {
      await _firestore.collection(_collectionName).doc(errandId).update({
        'status': 'accepted',
        'runnerId': runnerId,
      });
    } catch (e) {
      developer.log(e.toString());
    }
  }

  // Complete an errand
  Future<void> completeErrand(String errandId) async {
    try {
      await _firestore.collection(_collectionName).doc(errandId).update({
        'status': 'completed',
      });
    } catch (e) {
      developer.log(e.toString());
    }
  }
}
