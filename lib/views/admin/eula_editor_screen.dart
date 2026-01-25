import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EulaEditorScreen extends StatefulWidget {
  const EulaEditorScreen({super.key});

  @override
  State<EulaEditorScreen> createState() => _EulaEditorScreenState();
}

class _EulaEditorScreenState extends State<EulaEditorScreen> {
  final _eulaController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEula();
  }

  Future<void> _loadEula() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('eula')
          .get();
      if (doc.exists) {
        _eulaController.text = doc.data()?['content'] ?? '';
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEula() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance.collection('settings').doc('eula').set({
        'content': _eulaController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('EULA saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save EULA: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit EULA')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _eulaController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'EULA Content',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveEula,
                    child: const Text('Save EULA'),
                  ),
                ],
              ),
            ),
    );
  }
}
