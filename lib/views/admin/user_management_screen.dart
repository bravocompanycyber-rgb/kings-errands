import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((doc) {
                  final fullName =
                      doc['fullName']?.toString().toLowerCase() ?? '';
                  final email = doc['email']?.toString().toLowerCase() ?? '';
                  return fullName.contains(_searchText) ||
                      email.contains(_searchText);
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user['fullName'] ?? 'No Name'),
                      subtitle: Text(user['email'] ?? 'No Email'),
                      trailing: Text(user['role'] ?? 'No Role'),
                      onTap: () => _showUserDetails(context, user),
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

  void _showUserDetails(BuildContext context, DocumentSnapshot user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('User Profile'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${user['fullName']}'),
                Text('Email: ${user['email']}'),
                Text('Role: ${user['role']}'),
                const Divider(),
                const Text(
                  'History',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('errands')
                      .where('customerId', isEqualTo: user.id)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final errands = snapshot.data!.docs;
                    if (errands.isEmpty) {
                      return const Text('No errands found.');
                    }
                    return Column(
                      children: errands.map((errand) {
                        return ListTile(
                          title: Text(errand['title'] ?? ''),
                          subtitle: Text('Status: ${errand['status']}'),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () => _editUser(context, user),
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () => _deleteUser(context, user.id),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _editUser(BuildContext context, DocumentSnapshot user) {
    final nameController = TextEditingController(text: user['fullName']);
    final emailController = TextEditingController(text: user['email']);
    final roleController = TextEditingController(text: user['role']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .update({
                      'fullName': nameController.text,
                      'email': emailController.text,
                      'role': roleController.text,
                    });
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context); // Close the user details dialog
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .delete();
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context); // Close the user details dialog
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
