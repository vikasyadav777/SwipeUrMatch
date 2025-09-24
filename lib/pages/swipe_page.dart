import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key}); // fixed constructor

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> profiles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final me = auth.currentUser;
    if (me == null) return;

    final snap = await firestore.collection('users').get();
    setState(() {
      profiles = snap.docs
          .where((d) => d.id != me.uid) // exclude self
          .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
          .toList();
      loading = false;
    });
  }

  Future<void> swipeRight(String toUserId) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final me = auth.currentUser;
    if (me == null) return;

    await firestore.collection('swipes').add({
      'fromUserId': me.uid,
      'toUserId': toUserId,
      'direction': 'right',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (profiles.isEmpty) return const Center(child: Text('No profiles found'));

    final profile = profiles.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Swipe')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: SizedBox(
            width: 300,
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(profile['name'] ?? 'No Name', style: const TextStyle(fontSize: 24)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => profiles.removeAt(0)); // swipe left
                      },
                      child: const Text('✖️'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await swipeRight(profile['id']);
                        setState(() => profiles.removeAt(0)); // swipe right
                      },
                      child: const Text('❤️'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
