import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class MatchesPage extends StatefulWidget {
  final String uid;
  const MatchesPage({super.key, required this.uid});

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> matches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    setState(() => loading = true);
    final meId = widget.uid;

    final snap = await firestore
        .collection('swipes')
        .where('fromUserId', isEqualTo: meId)
        .where('direction', isEqualTo: 'right')
        .get();

    List<Map<String, dynamic>> temp = [];

    for (var doc in snap.docs) {
      final otherId = doc['toUserId'];
      final otherUserSnap = await firestore.collection('users').doc(otherId).get();
      if (otherUserSnap.exists) {
        temp.add({'id': otherId, ...otherUserSnap.data()!});
      }
    }

    setState(() {
      matches = temp;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (matches.isEmpty) return const Center(child: Text('No matches yet'));

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return ListTile(
            title: Text(match['name'] ?? 'No Name'),
            subtitle: Text(match['email'] ?? ''),
          );
        },
      ),
    );
  }
}
