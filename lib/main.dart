import 'package:flutter/material.dart';
import 'package:renewed/models/subscription_database.dart';
import 'package:renewed/screens/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SubscriptionDatabase.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renewed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}
