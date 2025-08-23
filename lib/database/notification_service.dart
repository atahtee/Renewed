import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:renewed/database/subscription_database.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:renewed/database/subscription.dart';
import 'dart:io';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

enum NotificationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  unknown,
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  NotificationPermissionStatus _permissionStatus =
      NotificationPermissionStatus.unknown;

  NotificationPermissionStatus get permissionStatus => _permissionStatus;

  Future<void> initialize() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

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
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    await checkPermissionStatus();
  }

  Future<void> _initializeTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<NotificationPermissionStatus> checkPermissionStatus() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        _permissionStatus = NotificationPermissionStatus.granted;
      } else if (status.isPermanentlyDenied) {
        _permissionStatus = NotificationPermissionStatus.permanentlyDenied;
      } else {
        _permissionStatus = NotificationPermissionStatus.denied;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        final granted =
            await iosPlugin.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
        _permissionStatus = granted
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied;
      }
    }

    return _permissionStatus;
  }

  Future<NotificationPermissionStatus> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        _permissionStatus = NotificationPermissionStatus.granted;
      } else if (status.isPermanentlyDenied) {
        _permissionStatus = NotificationPermissionStatus.permanentlyDenied;
      } else {
        _permissionStatus = NotificationPermissionStatus.denied;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        _permissionStatus = (granted == true)
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied;
      }
    }

    return _permissionStatus;
  }

  static Future<void> showPermissionDialog(BuildContext context) async {
    final notificationService = NotificationService();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Enable Notifications'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stay on top of your subscriptions with timely reminders.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Get notified 1 day before your subscriptions renew',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not Now'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final status = await notificationService
                    .requestNotificationPermission();

                if (status == NotificationPermissionStatus.permanentlyDenied &&
                    context.mounted) {
                  _showSettingsDialog(context);
                }
              },
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showSettingsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Permission Required'),
          content: const Text(
            'Notifications have been disabled. To enable them, please go to your device settings and allow notifications for this app.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> scheduleSubscriptionNotification(
    Subscription subscription,
  ) async {
    if (_permissionStatus != NotificationPermissionStatus.granted) {
      print('Cannot schedule notification: Permission not granted');
      return false;
    }
    if (subscription.nextReminder == null) return false;
    var nextReminder = subscription.nextReminder!;
    while (nextReminder.isBefore(DateTime.now())) {
      nextReminder = nextReminder.add(
        Duration(days: subscription.intervalInDays),
      );
    }
    final notificationTime = nextReminder.subtract(const Duration(days: 1));
    if (notificationTime.isBefore(DateTime.now())) return false;
    try {
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'subscription_channel',
        'Subscription Renewals',
        channelDescription: 'Notifications for upcoming subscription renewals',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );
      const darwinPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
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
      );
      subscription.nextReminder = nextReminder;
      await SubscriptionDatabase.isar.writeTxn(() async {
        await SubscriptionDatabase.isar.subscriptions.put(subscription);
      });
      return true;
    } catch (e) {
      print('Failed to schedule notification: $e');
      return false;
    }
  }

  Future<void> cancelSubscriptionNotification(int subscriptionId) async {
    await _notificationsPlugin.cancel(subscriptionId);
  }

  Future<int> rescheduleAllNotifications(
    List<Subscription> subscriptions,
  ) async {
    await _notificationsPlugin.cancelAll();

    if (_permissionStatus != NotificationPermissionStatus.granted) {
      print('Cannot schedule notifications: Permission not granted');
      return 0;
    }

    int scheduledCount = 0;
    for (final subscription in subscriptions) {
      final scheduled = await scheduleSubscriptionNotification(subscription);
      if (scheduled) scheduledCount++;
    }

    return scheduledCount;
  }

  Future<int> getPendingNotificationsCount() async {
    final pendingNotifications = await _notificationsPlugin
        .pendingNotificationRequests();
    return pendingNotifications.length;
  }

  bool shouldPromptForPermission() {
    return _permissionStatus == NotificationPermissionStatus.denied ||
        _permissionStatus == NotificationPermissionStatus.unknown;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
