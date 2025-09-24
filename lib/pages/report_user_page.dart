import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportUserPage extends StatefulWidget {
  final String reportedUserId; ReportUserPage({required this.reportedUserId});
  @override State<ReportUserPage> createState() => _ReportUserPageState();
}
class _ReportUserPageState extends State<ReportUserPage> {
  final _ctrl = TextEditingController();
  void _submit() { FirebaseFirestore.instance.collection('reports').add({'reportedUserId': widget.reportedUserId, 'reason': _ctrl.text, 'timestamp': FieldValue.serverTimestamp()}); Navigator.pop(context); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text('Report User')), body: Padding(padding: EdgeInsets.all(16), child: Column(children:[ Text('Why report?'), TextField(controller: _ctrl, maxLines:5), SizedBox(height:12), ElevatedButton(onPressed: _submit, child: Text('Submit')) ]))); }
}
