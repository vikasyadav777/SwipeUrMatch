import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AdminPanel extends StatelessWidget {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final functions = FirebaseFunctions.instance;

  AdminPanel({super.key});

  void _promote(String uid) {
    functions.httpsCallable('promoteUser').call({'uid': uid});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              final role = d['role'] ?? 'user';
              final images = d['images'] as List? ?? [];
              return ListTile(
                leading: images.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(images[0]),
                      )
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(d['name'] ?? 'User'),
                subtitle: Text(d['email'] ?? ''),
                trailing: role == 'admin'
                    ? const Text('Admin')
                    : ElevatedButton(
                        onPressed: () => _promote(d.id),
                        child: const Text('Promote'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
