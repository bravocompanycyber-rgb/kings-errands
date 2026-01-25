import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EulaManagementScreen extends StatefulWidget {
  const EulaManagementScreen({super.key});

  @override
  State<EulaManagementScreen> createState() => _EulaManagementScreenState();
}

class _EulaManagementScreenState extends State<EulaManagementScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isLoading = false;
  String? _pdfUrl;

  @override
  void initState() {
    super.initState();
    _loadEula();
  }

  Future<void> _loadEula() async {
    setState(() {
      _isLoading = true;
    });
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

  Future<void> _uploadEula() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        File file = File(result.files.single.path!);
        await _storage.ref('eula/eula.pdf').putFile(file);
        await _loadEula();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('EULA uploaded successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to upload EULA: $e')));
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
      appBar: AppBar(title: const Text('EULA Management')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_pdfUrl != null)
              Expanded(child: SfPdfViewer.network(_pdfUrl!))
            else
              const Text('No EULA uploaded yet.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadEula,
              child: const Text('Upload New EULA'),
            ),
          ],
        ),
      ),
    );
  }
}
