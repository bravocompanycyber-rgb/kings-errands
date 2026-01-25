import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:otp/otp.dart';

class ErrandDetailsScreen extends StatefulWidget {
  final String errandId;

  const ErrandDetailsScreen({super.key, required this.errandId});

  @override
  State<ErrandDetailsScreen> createState() => _ErrandDetailsScreenState();
}

class _ErrandDetailsScreenState extends State<ErrandDetailsScreen> {
  late Future<DocumentSnapshot> _errandFuture;
  final TextEditingController _otpController = TextEditingController();
  String? _generatedOtp;
  bool _isOtpVerified = false;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 60;
  bool _isCooldownActive = false;

  @override
  void initState() {
    super.initState();
    _errandFuture = FirebaseFirestore.instance
        .collection('errands')
        .doc(widget.errandId)
        .get();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _isCooldownActive = true;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds == 0) {
        timer.cancel();
        setState(() {
          _isCooldownActive = false;
          _cooldownSeconds = 60;
        });
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  void _generateOtp() {
    final otp = OTP.generateTOTPCodeString(
      '${widget.errandId}${DateTime.now().millisecondsSinceEpoch}',
      DateTime.now().millisecondsSinceEpoch,
    );
    setState(() {
      _generatedOtp = otp.substring(otp.length - 6);
    });
    _startCooldown();
  }

  void _verifyOtp() {
    if (_otpController.text == _generatedOtp) {
      setState(() {
        _isOtpVerified = true;
      });
    } else {
      if(mounted){
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
      }
    }
  }

  Future<void> _markAsCompleted() async {
    if (!_isOtpVerified) {
      if(mounted){
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please verify OTP first')));
      }
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('errands')
          .doc(widget.errandId)
          .update({'status': 'completed'});
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errand marked as completed!')),
        );
        context.pop();
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Errand Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: _errandFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Errand not found.'));
          }

          final errand = snapshot.data!;
          final errandData = errand.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errandData['title'],
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(errandData['description']),
                const SizedBox(height: 8),
                Text('Status: ${errandData['status']}'),
                const SizedBox(height: 24),
                if (errandData['status'] == 'assigned') ...[
                  ElevatedButton(
                    onPressed: _isCooldownActive ? null : _generateOtp,
                    child: Text(
                      _isCooldownActive
                          ? 'Resend OTP in $_cooldownSeconds s'
                          : 'Generate OTP',
                    ),
                  ),
                  if (_generatedOtp != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Generated OTP: $_generatedOtp',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(labelText: 'Enter OTP'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _verifyOtp,
                    child: const Text('Verify OTP'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isOtpVerified ? _markAsCompleted : null,
                    child: const Text('Complete Errand'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
