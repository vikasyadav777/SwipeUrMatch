import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'subscription_page.dart';
import 'moderation_page.dart';
import 'admin_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SettingsPage extends StatefulWidget { @override State<SettingsPage> createState() => _SettingsPageState(); }
class _SettingsPageState extends State<SettingsPage> {
  String role='user'; bool loading=true; BannerAd? _banner;
  @override void initState(){ super.initState(); _loadRole(); _initAds(); }
  Future<void> _initAds(){ MobileAds.instance.initialize(); _banner = BannerAd(adUnitId: '<YOUR_BANNER_AD_UNIT_ID>', size: AdSize.banner, request: AdRequest(), listener: BannerAdListener(),); return _banner!.load(); }
  Future<void> _loadRole() async { final auth = Provider.of<AuthService>(context, listen:false); final uid = auth.currentUser!.uid; final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get(); setState(()=> role = doc.exists? (doc['role'] ?? 'user'): 'user'); loading=false; }
  @override void dispose(){ _banner?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen:false);
    return Scaffold(appBar: AppBar(title: Text('Settings')), body: loading? Center(child:CircularProgressIndicator()) : ListView(children: [
      ListTile(leading: Icon(Icons.star), title: Text('Upgrade to Premium'), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> SubscriptionPage()))),
      if (role=='admin') ListTile(leading: Icon(Icons.report), title: Text('Moderation (Admin)'), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> ModerationPage()))),
      if (role=='admin') ListTile(leading: Icon(Icons.admin_panel_settings), title: Text('Admin Panel'), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminPanel()))),
      ListTile(leading: Icon(Icons.logout), title: Text('Log out'), onTap: () async { await auth.signOut(); }),
      SizedBox(height:12),
      Center(child: _banner!=null? Container(width: _banner!.size.width.toDouble(), height: _banner!.size.height.toDouble(), child: AdWidget(ad: _banner!)) : Text('Ad placeholder'))
    ]));
  }
}
