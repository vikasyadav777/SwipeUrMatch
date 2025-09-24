import 'package:flutter/material.dart';
import 'report_user_page.dart';

class ProfilePage extends StatelessWidget {
  final String userId; ProfilePage({required this.userId});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text('Profile')), body: Column(children:[ Expanded(child: Center(child: Text('Profile: \$userId'))), ElevatedButton.icon(icon: Icon(Icons.flag, color: Colors.red), label: Text('Report User'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> ReportUserPage(reportedUserId: userId)))) ])); }
