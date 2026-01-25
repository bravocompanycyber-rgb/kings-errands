import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kings_errands/widgets/errand_card.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending Confirmation'),
            Tab(text: 'Completed Payments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentList(status: 'pending_payment_confirmation'),
          _buildPaymentList(status: 'payment_completed'),
        ],
      ),
    );
  }

  Widget _buildPaymentList({required String status}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('errands')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final errands = snapshot.data!.docs;

        if (errands.isEmpty) {
          return Center(child: Text('No payments in this category.'));
        }

        return ListView.builder(
          itemCount: errands.length,
          itemBuilder: (context, index) {
            final errand = errands[index];
            return ErrandCard(
              errand: errand,
              showApproveButton: status == 'pending_payment_confirmation',
              showRejectButton: status == 'pending_payment_confirmation',
              onApprove: () => _confirmPayment(errand.id),
              onReject: () => _rejectPayment(errand.id),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmPayment(String errandId) async {
    await FirebaseFirestore.instance.collection('errands').doc(errandId).update(
      {'status': 'waiting_approval', 'paymentStatus': 'payment_confirmed'},
    );
  }

  Future<void> _rejectPayment(String errandId) async {
    await FirebaseFirestore.instance.collection('errands').doc(errandId).update(
      {'status': 'payment_rejected', 'paymentStatus': 'payment_rejected'},
    );
  }
}
