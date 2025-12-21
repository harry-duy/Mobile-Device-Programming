import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/customer_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Delivery Customer',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const CustomerHomeScreen(),
    );
  }
}