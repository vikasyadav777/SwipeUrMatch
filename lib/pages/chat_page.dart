import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ChatPage extends StatefulWidget {
  final String matchId; final String otherUserId;
  ChatPage({required this.matchId, required this.otherUserId});
  @override State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final _ctrl = TextEditingController();
  @override Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final uid = auth.currentUser!.uid;
    final messagesRef = FirebaseFirestore.instance.collection('messages');
    return Scaffold(appBar: AppBar(title: Text('Chat')), body: Column(children:[ Expanded(child: StreamBuilder<QuerySnapshot>(stream: messagesRef.where('matchId', isEqualTo: widget.matchId).orderBy('timestamp', descending:true).snapshots(), builder:(context,snap){ if(!snap.hasData) return Center(child:CircularProgressIndicator()); final docs = snap.data!.docs; return ListView.builder(reverse:true, itemCount:docs.length, itemBuilder:(context,i){ final m = docs[i]; final isMe = m['senderId']==uid; return ListTile(title: Align(alignment: isMe? Alignment.centerRight: Alignment.centerLeft, child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: isMe? Colors.pink[100]: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: Text(m['text'])))); }); })), SafeArea(child: Row(children:[ Expanded(child: TextField(controller: _ctrl, decoration: InputDecoration(hintText: 'Message'))), IconButton(icon: Icon(Icons.send), onPressed: () async { final text = _ctrl.text.trim(); if (text.isEmpty) return; await messagesRef.add({'matchId': widget.matchId, 'senderId': uid, 'text': text, 'timestamp': FieldValue.serverTimestamp()}); _ctrl.clear(); }) ]) ) ]));
  }
}
