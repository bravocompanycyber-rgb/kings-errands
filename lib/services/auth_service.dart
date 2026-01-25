import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<User?> signUp(
    String email,
    String password,
    String userType, {
    String? fullName,
    String? phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'userType': userType,
          'fullName': fullName,
          'phone': phone,
          'eulaAccepted': userType == 'Customer' ? true : false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        DocumentSnapshot userData = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        return {
          'user': user,
          'userType': userData['userType'],
          'eulaAccepted': userData['eulaAccepted'],
        };
      }
      return null;
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }

  // Send password reset email
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      // Check if user exists
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return 'User with this email does not exist.';
      }

      final userId = userQuery.docs.first.id;

      // Check for recent password reset requests
      final resetRequestQuery = await _firestore
          .collection('passwordReset')
          .doc(userId)
          .get();

      if (resetRequestQuery.exists) {
        final lastRequest = resetRequestQuery.data()!['timestamp'] as Timestamp;
        final fiveMinutesAgo = Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch - 5 * 60 * 1000,
        );

        if (lastRequest.compareTo(fiveMinutesAgo) > 0) {
          return 'Please wait 5 minutes before requesting another password reset.';
        }
      }

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);

      // Log the password reset request
      await _firestore.collection('passwordReset').doc(userId).set({
        'timestamp': FieldValue.serverTimestamp(),
      });

      return 'success';
    } catch (e) {
      developer.log(e.toString());
      return 'An error occurred. Please try again later.';
    }
  }

  Future<void> acceptEULA(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'eulaAccepted': true,
      });
    } catch (e) {
      developer.log(e.toString());
    }
  }
  
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();
        return userData.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      developer.log('Error getting user details: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user type
  Future<String?> getUserType() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        return userData['userType'];
      }
      return null;
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }
}
