import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionPage extends StatefulWidget { @override State<SubscriptionPage> createState() => _SubscriptionPageState(); }
class _SubscriptionPageState extends State<SubscriptionPage> {
  List<Package> _packages = [];
  @override void initState(){ super.initState(); _loadOfferings(); }
  Future<void> _loadOfferings() async { try { Offerings offerings = await Purchases.getOfferings(); if (offerings.current != null) setState(()=> _packages = offerings.current!.availablePackages); } catch (e){ print('Error loading offerings: \$e'); } }
  Future<void> _purchase(Package pkg) async { try { await Purchases.purchasePackage(pkg); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchase successful'))); } catch (e){ print('Purchase error: \$e'); } }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text('Upgrade')), body: _packages.isEmpty? Center(child:CircularProgressIndicator()): ListView.builder(itemCount:_packages.length, itemBuilder:(context,i){ final p=_packages[i]; return ListTile(
  title: Text(p.storeProduct.title),
  subtitle: Text(p.storeProduct.description),
  trailing: Text(p.storeProduct.priceString),
  onTap: () => _purchase(p),
);
 })); }
}
