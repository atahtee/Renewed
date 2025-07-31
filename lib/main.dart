import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renewed/database/notification_service.dart';
import 'package:renewed/database/subscription_database.dart';
import 'package:renewed/screens/home/home_page.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await SubscriptionDatabase.initialize();
    final notificationService = NotificationService();
    await notificationService.initialize();

    if (Platform.isAndroid) {
      await notificationService.requestNotificationPermission();
    }

    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Initialization failed: ${e.toString()}'),
          ),
        ),
      ),
    );
  }
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
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      home: const HomePage(),
    );
  }
}