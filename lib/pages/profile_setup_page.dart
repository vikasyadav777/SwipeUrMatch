import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileSetupPage extends StatefulWidget { @override State<ProfileSetupPage> createState() => _ProfileSetupPageState(); }
class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _bio=TextEditingController();
  final picker = ImagePicker();
  List<String> images = [];
  bool _saving=false;
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;
    setState(()=>_saving=true);
    final auth = Provider.of<AuthService>(context, listen:false);
    final uid = auth.currentUser!.uid;
    final file = File(picked.path);
    final ref = FirebaseStorage.instance.ref().child('images').child(uid).child(DateTime.now().millisecondsSinceEpoch.toString());
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    images.add(url);
    await FirebaseFirestore.instance.collection('users').doc(uid).set({'images': images, 'bio': _bio.text.trim()}, SetOptions(merge:true));
    setState(()=>_saving=false);
  }
  @override Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen:false);
    return Scaffold(appBar: AppBar(title: Text('Complete profile')), body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
      TextField(controller: _bio, decoration: InputDecoration(labelText: 'Short bio')),
      SizedBox(height:12),
      Wrap(spacing:8, children: [ for(final img in images) CircleAvatar(radius:36, backgroundImage: NetworkImage(img)), if (images.length<4) GestureDetector(onTap: pickImage, child: CircleAvatar(radius:36, child: Icon(Icons.add_a_photo))) ]),
      SizedBox(height:12),
      _saving ? CircularProgressIndicator() : ElevatedButton(onPressed: () async { setState(()=>_saving=true); final uid = auth.currentUser!.uid; await FirebaseFirestore.instance.collection('users').doc(uid).set({'bio': _bio.text.trim(), 'images': images}, SetOptions(merge:true)); setState(()=>_saving=false); Navigator.pushReplacementNamed(context, '/home'); }, child: Text('Save'))
    ])));
  }
}
