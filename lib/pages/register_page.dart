import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => _loading = true);
                      try {
                        final userCredential = await auth
                            .registerWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );

                        if (userCredential != null &&
                            userCredential.user != null) {
                          // save user profile in Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userCredential.user!.uid)
                              .set({
                            'name': _nameController.text.trim(),
                            'email': _emailController.text.trim(),
                            'bio': '',
                            'images': [],
                            'interests': [],
                            'freeMatch': true,
                            'role': 'user',
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }

                        if (!mounted) return;
                        Navigator.pop(context); // back to login
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Registration failed: $e")),
                        );
                      } finally {
                        setState(() => _loading = false);
                      }
                    },
                    child: const Text("Create Account"),
                  ),
          ],
        ),
      ),
    );
  }
}
