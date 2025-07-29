import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:renewed/models/subscription.dart';

class SubscriptionDatabase {

  static final SubscriptionDatabase instance = SubscriptionDatabase._internal();

  static late Isar isar;

  SubscriptionDatabase._internal();


  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([SubscriptionSchema], directory: dir.path);
  }

  final List<Subscription> currentSubscriptions = [];

  Future<void> addSubscription({
    required String name,
    required double amount,
    required String planType,
    required DateTime startDate,
    required int intervalInDays,
  }) async {
    final nextReminder = startDate.add(Duration(days: intervalInDays));
    final subscription = Subscription()
      ..name = name
      ..amount = amount
      ..planType = planType
      ..startDate = startDate
      ..intervalInDays = intervalInDays
      ..nextReminder = nextReminder;

    await isar.writeTxn(() async {
      await isar.subscriptions.put(subscription);
    });
  }

  Future<List<Subscription>> getAllSubscriptions() async {
    return await isar.subscriptions.where().findAll();
  }

  Future<void> deleteSubscription(int id) async {
    await isar.writeTxn(() async {
      await isar.subscriptions.delete(id);
    });
  }

  Future<void> updateReminder(int id) async {
    final subscription = await isar.subscriptions.get(id);
    if (subscription != null) {
      subscription.nextReminder = subscription.startDate.add(
        Duration(days: subscription.intervalInDays),
      );

      await isar.writeTxn(() async {
        await isar.subscriptions.put(subscription);
      });
    }
  }

  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.subscriptions.clear();
    });
  }
}
