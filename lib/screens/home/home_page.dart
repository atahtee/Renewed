import 'package:flutter/material.dart';
import 'package:renewed/database/notification_service.dart';
import 'package:renewed/database/subscription.dart';
import 'package:renewed/database/subscription_database.dart';
import 'package:renewed/utils/add_subscription_sheet.dart';
import 'package:renewed/utils/confirm_delete.dart';
import 'package:renewed/utils/subscription_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SubscriptionDatabase db = SubscriptionDatabase.instance;
  final NotificationService notificationService = NotificationService();

  List<Subscription> subscriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSubscriptions();
  }

  Future<void> loadSubscriptions() async {
    final subs = await db.getAllSubscriptions();
    subs.sort(
      (a, b) => (a.nextReminder ?? a.startDate).compareTo(
        b.nextReminder ?? b.startDate,
      ),
    );
    setState(() {
      subscriptions = subs;
      isLoading = false;
    });
    await notificationService.rescheduleAllNotifications(subs);
  }

  double get totalMonthlyCost {
    return subscriptions.fold(0, (sum, s) {
      if (s.intervalInDays <= 31) return sum + s.amount;
      return sum;
    });
  }

  int get activeCount => subscriptions.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Subscriptions',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This Month',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${totalMonthlyCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$activeCount active subscriptions',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming Payments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: subscriptions.length,
                    itemBuilder: (context, index) {
                      final sub = subscriptions[index];
                      return _buildSubscriptionCard(sub);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            AddSubscriptionSheet.show(context, db, loadSubscriptions),

        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSubscriptionCard(Subscription sub) {
    final icon = _getIconFor(sub.name);
    final color = _getColorFor(sub.name);
    final daysRemaining =
        sub.nextReminder?.difference(DateTime.now()).inDays ?? 0;
    final dueText = daysRemaining <= 0
        ? 'Due Today'
        : 'Due in $daysRemaining days';

    return GestureDetector(
      onLongPress: () => _confirmDelete(sub),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dueText,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Text(
              '\$${sub.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Subscription subscription) {
    DeleteConfirmationDialog.show(
      context: context,
      subscription: subscription,
      database: db,
      onDeleted: loadSubscriptions,
    );
  }

  IconData _getIconFor(String name) {
    final service = popularSubscriptions.firstWhere(
      (s) => s.name.toLowerCase() == name.toLowerCase(),
      orElse: () => SubscriptionService(
        '',
        Icons.subscriptions_outlined,
        Colors.blueGrey,
      ),
    );
    return service.icon;
  }

  Color _getColorFor(String name) {
    final service = popularSubscriptions.firstWhere(
      (s) => s.name.toLowerCase() == name.toLowerCase(),
      orElse: () => SubscriptionService(
        '',
        Icons.subscriptions_outlined,
        Colors.blueGrey,
      ),
    );
    return service.color;
  }
}
