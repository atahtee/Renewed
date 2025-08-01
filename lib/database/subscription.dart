import 'package:isar/isar.dart';

part 'subscription.g.dart';

@Collection()
class Subscription {
  Id id = Isar.autoIncrement;
  late String name;
  late double amount;
  late String planType;
  late DateTime startDate;
  late int intervalInDays;
  DateTime? nextReminder;
}
