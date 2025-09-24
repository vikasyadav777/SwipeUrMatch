import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      body: Center(child: Padding(padding: EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('SwipeUrMatch', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())), child: Text('Log in')),
        OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage())), child: Text('Sign up')),
        SizedBox(height: 12),
        ElevatedButton.icon(icon: Icon(Icons.login), label: Text('Continue with Google'), onPressed: () async {
          try {
            final cred = await auth.signInWithGoogle();
            if (cred != null && cred.user != null) {
              final snap = await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).get();
              if (!snap.exists) {
                await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({'name': cred.user!.displayName ?? '', 'email': cred.user!.email ?? '', 'bio': '', 'images': [], 'interests': [], 'freeMatch': true, 'role': 'user', 'createdAt': FieldValue.serverTimestamp()});
              }
            }
          } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign-in failed: \$e'))); }
        }),
        SizedBox(height: 8),
        ElevatedButton.icon(icon: Icon(Icons.apple), label: Text('Continue with Apple'), onPressed: () async {
          try {
            final cred = await auth.signInWithApple();
            if (cred != null && cred.user != null) {
              final snap = await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).get();
              if (!snap.exists) {
                await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({'name': cred.user!.displayName ?? '', 'email': cred.user!.email ?? '', 'bio': '', 'images': [], 'interests': [], 'freeMatch': true, 'role': 'user', 'createdAt': FieldValue.serverTimestamp()});
              }
            }
          } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Apple sign-in failed: \$e'))); }
        }),
      ]))),
    );
  }
}
