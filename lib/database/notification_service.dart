import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:renewed/database/subscription.dart';
import 'dart:io';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  Future<void> initialize() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize timezone
    await _initializeTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        
      },
    );
  }

  Future<void> _initializeTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}


 Future<void> scheduleSubscriptionNotification(Subscription subscription) async {
  if (subscription.nextReminder == null) return;

  final notificationTime = subscription.nextReminder!.subtract(
    const Duration(days: 1),
  );

  if (notificationTime.isBefore(DateTime.now())) return;

  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'subscription_channel',
    'Subscription Renewals',
    channelDescription: 'Notifications for upcoming subscription renewals',
    importance: Importance.high,
    priority: Priority.high,
  );

  const darwinPlatformChannelSpecifics = DarwinNotificationDetails();

  final platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: darwinPlatformChannelSpecifics,
  );

  await _notificationsPlugin.zonedSchedule(
    subscription.id,
    'Subscription Renewal',
    'Your ${subscription.name} subscription renews tomorrow for \$${subscription.amount.toStringAsFixed(2)}',
    tz.TZDateTime.from(notificationTime, tz.local),
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

  Future<void> cancelSubscriptionNotification(int subscriptionId) async {
    await _notificationsPlugin.cancel(subscriptionId);
  }

 Future<bool> requestNotificationPermission() async {
  final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    if (Platform.isAndroid) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }
  }
  return false;
}

  Future<void> rescheduleAllNotifications(
      List<Subscription> subscriptions) async {
    // Cancel all existing notifications
    await _notificationsPlugin.cancelAll();

    // Schedule new notifications for each subscription
    for (final subscription in subscriptions) {
      await scheduleSubscriptionNotification(subscription);
    }
  }
}



