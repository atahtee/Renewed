import 'package:flutter/material.dart';
import 'package:renewed/models/subscription_database.dart';

class AddSubscriptionSheet {
  static void show(BuildContext context, SubscriptionDatabase db, VoidCallback onSubscriptionAdded) {
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
          child: SingleChildScrollView(
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
                  decoration: InputDecoration(labelText: 'Plan Type (e.g., Monthly)'),
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
                    selectedDate == null ? 'Pick Start Date' : 'Date Selected: ${selectedDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                SizedBox(height: 12),
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
                      onSubscriptionAdded();
                    }
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
