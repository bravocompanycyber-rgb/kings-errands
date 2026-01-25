import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FaqManagementScreen extends StatefulWidget {
  const FaqManagementScreen({super.key});

  @override
  State<FaqManagementScreen> createState() => _FaqManagementScreenState();
}

class _FaqManagementScreenState extends State<FaqManagementScreen> {
  String _selectedRole = 'customer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showFaqDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              items: const [
                DropdownMenuItem(
                  value: 'customer',
                  child: Text('Customer FAQs'),
                ),
                DropdownMenuItem(value: 'runner', child: Text('Runner FAQs')),
                DropdownMenuItem(value: 'admin', child: Text('Admin FAQs')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select FAQ Category',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('faqs')
                  .where('role', isEqualTo: _selectedRole)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final faqs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final faq = faqs[index];
                    return ListTile(
                      title: Text(faq['question']),
                      subtitle: Text(faq['answer']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showFaqDialog(faq: faq),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteFaq(faq.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFaqDialog({DocumentSnapshot? faq}) {
    final questionController = TextEditingController(text: faq?['question']);
    final answerController = TextEditingController(text: faq?['answer']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(faq == null ? 'Add FAQ' : 'Edit FAQ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isNotEmpty &&
                    answerController.text.isNotEmpty) {
                  if (faq == null) {
                    _addFaq(questionController.text, answerController.text);
                  } else {
                    _updateFaq(
                      faq.id,
                      questionController.text,
                      answerController.text,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addFaq(String question, String answer) async {
    await FirebaseFirestore.instance.collection('faqs').add({
      'question': question,
      'answer': answer,
      'role': _selectedRole,
    });
  }

  Future<void> _updateFaq(String id, String question, String answer) async {
    await FirebaseFirestore.instance.collection('faqs').doc(id).update({
      'question': question,
      'answer': answer,
    });
  }

  Future<void> _deleteFaq(String id) async {
    await FirebaseFirestore.instance.collection('faqs').doc(id).delete();
  }
}
