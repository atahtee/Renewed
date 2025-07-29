import 'package:flutter/material.dart';
import 'package:renewed/models/subscription.dart';
import 'package:renewed/models/subscription_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SubscriptionDatabase db = SubscriptionDatabase.instance;

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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black54,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black54),
            onPressed: () {},
          ),
        ],
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
        onPressed: () => showAddSubscriptionSheet(context, db),

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

    return Container(
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
    );
  }

  IconData _getIconFor(String name) {
    name = name.toLowerCase();
    if (name.contains('netflix')) return Icons.movie_outlined;
    if (name.contains('spotify')) return Icons.music_note_outlined;
    if (name.contains('adobe')) return Icons.design_services_outlined;
    if (name.contains('notion')) return Icons.note_outlined;
    return Icons.subscriptions_outlined;
  }

  Color _getColorFor(String name) {
    name = name.toLowerCase();
    if (name.contains('netflix')) return Colors.red;
    if (name.contains('spotify')) return Colors.green;
    if (name.contains('adobe')) return Colors.purple;
    if (name.contains('notion')) return Colors.black87;
    return Colors.blueGrey;
  }

  void showAddSubscriptionSheet(BuildContext context, SubscriptionDatabase db) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final planTypeController = TextEditingController();
    final intervalController = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Subscription Name'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: planTypeController,
                decoration: InputDecoration(
                  labelText: 'Plan Type (e.g., Monthly)',
                ),
              ),
              TextField(
                controller: intervalController,
                decoration: InputDecoration(labelText: 'Interval in Days'),
                keyboardType: TextInputType.number,
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
                child: Text(
                  selectedDate == null ? 'Pick Start Date' : 'Date Selected',
                ),
              ),
              ElevatedButton(
                child: Text('Add Subscription'),
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      amountController.text.isNotEmpty &&
                      planTypeController.text.isNotEmpty &&
                      intervalController.text.isNotEmpty &&
                      selectedDate != null) {
                    await db.addSubscription(
                      name: nameController.text,
                      amount: double.tryParse(amountController.text) ?? 0,
                      planType: planTypeController.text,
                      startDate: selectedDate!,
                      intervalInDays: int.parse(intervalController.text),
                    );
                    Navigator.pop(context);
                    await loadSubscriptions();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
