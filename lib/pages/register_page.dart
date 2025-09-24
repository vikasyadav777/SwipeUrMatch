import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'profile_setup_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _pwd, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => _loading = true);
                      try {
                        final cred = await auth.registerWithEmail(
                          _email.text.trim(),
                          _pwd.text.trim(),
                        );

                        // Save user data to Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(cred.user!.uid)
                            .set({
                          'name': _name.text.trim(),
                          'email': _email.text.trim(),
                          'bio': '',
                          'images': [],
                          'interests': [],
                          'freeMatch': true,
                          'role': 'user',
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileSetupPage()));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sign up failed: $e')));
                      } finally {
                        setState(() => _loading = false);
                      }
                    },
                    child: const Text('Create account'),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = await auth.signInWithGoogle();
                if (user != null) {
                  // Save new user to Firestore if not exists
                  final doc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.user!.uid)
                      .get();
                  if (!doc.exists) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.user!.uid)
                        .set({
                      'name': user.user!.displayName ?? 'No Name',
                      'email': user.user!.email ?? '',
                      'bio': '',
                      'images': [],
                      'interests': [],
                      'freeMatch': true,
                      'role': 'user',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  }
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfileSetupPage()));
                }
              },
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
