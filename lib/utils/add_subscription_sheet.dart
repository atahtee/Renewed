import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renewed/models/subscription_database.dart';

class AddSubscriptionSheet {
  static void show(BuildContext context, SubscriptionDatabase db, VoidCallback onSubscriptionAdded) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final planTypeController = TextEditingController();
    final intervalController = TextEditingController();
    DateTime? selectedDate;

    final theme = Theme.of(context);
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Subscription',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildField(nameController, 'Subscription Name', border),
                SizedBox(height: 12),
                _buildField(amountController, 'Amount (e.g. 9.99)', border, keyboardType: TextInputType.number),
                SizedBox(height: 12),
                _buildField(planTypeController, 'Plan Type (e.g. Monthly)', border),
                SizedBox(height: 12),
                _buildField(intervalController, 'Interval in Days', border, keyboardType: TextInputType.number),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) selectedDate = picked;
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      selectedDate == null
                          ? 'Select Start Date'
                          : 'Start Date: ${DateFormat.yMMMd().format(selectedDate!)}',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                          intervalInDays: int.tryParse(intervalController.text) ?? 0,
                        );
                        Navigator.pop(context);
                        onSubscriptionAdded();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Add Subscription', style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildField(
    TextEditingController controller,
    String hint,
    OutlineInputBorder border, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: hint,
        border: border,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
