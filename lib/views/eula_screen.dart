import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class EulaScreen extends StatefulWidget {
  const EulaScreen({super.key});

  @override
  State<EulaScreen> createState() => _EulaScreenState();
}

class _EulaScreenState extends State<EulaScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  String? _pdfUrl;
  bool _hasAccepted = false;

  @override
  void initState() {
    super.initState();
    _loadEula();
    _checkIfEulaAccepted();
  }

  Future<void> _loadEula() async {
    try {
      final url = await _storage.ref('eula/eula.pdf').getDownloadURL();
      setState(() {
        _pdfUrl = url;
      });
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkIfEulaAccepted() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _hasAccepted = userDoc.data()?['eula_accepted'] ?? false;
        });
      }
    }
  }

  Future<void> _acceptEula() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'eula_accepted': true,
      });
      if (mounted) {
        context.go('/'); // Or to the appropriate screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('End-User License Agreement')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pdfUrl != null
                    ? SfPdfViewer.network(_pdfUrl!)
                    : const Center(child: Text('EULA not available.')),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _hasAccepted ? null : _acceptEula,
              child: const Text('I Accept'),
            ),
          ),
        ],
      ),
    );
  }
}
