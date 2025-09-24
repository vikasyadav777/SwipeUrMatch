import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget { @override State<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController(); final _pwd = TextEditingController(); bool _loading=false;
  @override Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen:false);
    return Scaffold(appBar: AppBar(title: Text('Log in')), body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
      TextField(controller: _email, decoration: InputDecoration(labelText: 'Email')),
      TextField(controller: _pwd, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
      SizedBox(height:12),
      _loading ? CircularProgressIndicator() : ElevatedButton(onPressed: () async { setState(()=>_loading=true); try { await auth.signInWithEmail(_email.text.trim(), _pwd.text.trim()); Navigator.pop(context);} catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: \$e')));} finally{ setState(()=>_loading=false);} }, child: Text('Log in'))
    ])));
  }
}
