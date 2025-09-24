import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ModerationPage extends StatelessWidget {
  final CollectionReference reports =
      FirebaseFirestore.instance.collection('reports');
  final functions = FirebaseFunctions.instance;

  ModerationPage({super.key});

  void _blockUser(String uid, BuildContext context) {
    functions.httpsCallable('blockUser').call({'uid': uid});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('User blocked')));
  }

  void _deleteReport(String id, BuildContext context) {
    reports.doc(id).delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Report deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderation')),
      body: StreamBuilder<QuerySnapshot>(
        stream: reports.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              return Card(
                child: ListTile(
                  title: Text('Reported: ${d['reportedUserId']}'),
                  subtitle: Text('Reason: ${d['reason']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.block),
                        onPressed: () =>
                            _blockUser(d['reportedUserId'], context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteReport(d.id, context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
