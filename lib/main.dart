import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renewed/database/notification_service.dart';
import 'package:renewed/database/subscription_database.dart';
import 'package:renewed/screens/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Initialization failed',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
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
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();
  bool _hasShownPermissionDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check permission status when app becomes active
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatusOnResume();
    }
  }

  Future<void> _handleNotificationPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final hasDismissedPrompt = prefs.getBool('hasDismissedPrompt') ?? false;
    if (hasDismissedPrompt) return;
    final status = await _notificationService.checkPermissionStatus();

    if (status == NotificationPermissionStatus.unknown ||
        status == NotificationPermissionStatus.denied) {
      if (!_hasShownPermissionDialog && mounted) {
        _hasShownPermissionDialog = true;
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          await NotificationService.showPermissionDialog(context);
          await prefs.setBool('hasDismissedPrompt', true);
        }
      }
    }
  }

  Future<void> _checkPermissionStatusOnResume() async {
    final prefs = await SharedPreferences.getInstance();
    final status = await _notificationService.checkPermissionStatus();

    if (status == NotificationPermissionStatus.granted) {
      final db = SubscriptionDatabase.instance;
      final subscriptions = await db.getAllSubscriptions();
      await _notificationService.rescheduleAllNotifications(subscriptions);

      final hasShownEnabledMessage =
          prefs.getBool('hasShownEnabledMessage') ?? false;

      if (!hasShownEnabledMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notifications enabled! Your reminders are now active.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await prefs.setBool('hasShownEnabledMessage', true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
