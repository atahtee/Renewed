import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renewed/database/subscription_database.dart';
import 'package:renewed/utils/subscription_service.dart';

class AddSubscriptionSheet {
  static void show(
    BuildContext context,
    SubscriptionDatabase db,
    VoidCallback onSubscriptionAdded,
  ) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final planTypeController = TextEditingController();
    final intervalController = TextEditingController();
    DateTime? selectedDate;

    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Autocomplete<SubscriptionService>(
                  displayStringForOption: (SubscriptionService option) =>
                      option.name,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<SubscriptionService>.empty();
                    }
                    return popularSubscriptions.where((option) {
                      return option.name.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (SubscriptionService selection) {
                    nameController.text = selection.name;
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController fieldController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        if (fieldController.text.isEmpty &&
                            nameController.text.isNotEmpty) {
                          fieldController.text = nameController.text;
                        }

                        return TextField(
                          controller: fieldController,
                          focusNode: fieldFocusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            hintText: 'Subscription Name',
                            border: border,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: fieldController.text.isEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onPressed: () {
                                      fieldFocusNode.requestFocus();

                                      fieldController.text = ' ';
                                      Future.delayed(
                                        Duration(milliseconds: 100),
                                        () {
                                          fieldController.clear();
                                        },
                                      );
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      fieldController.clear();
                                      nameController.clear();
                                    },
                                  ),
                          ),
                          onChanged: (value) {
                            if (nameController.text != value) {
                              nameController.text = value;
                            }
                          },
                        );
                      },
                  optionsViewBuilder:
                      (
                        BuildContext context,
                        AutocompleteOnSelected<SubscriptionService> onSelected,
                        Iterable<SubscriptionService> options,
                      ) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final option = options.elementAt(index);
                                  return InkWell(
                                    onTap: () {
                                      // Update both controllers when an option is selected
                                      nameController.text = option.name;
                                      onSelected(option);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: option.color.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              option.icon,
                                              color: option.color,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            option.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                ),
                const SizedBox(height: 12),
                _buildField(
                  amountController,
                  'Amount (e.g. 9.99)',
                  border,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    labelText: 'Plan Type',
                    border: border,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  value: planTypeController.text.isEmpty
                      ? null
                      : planTypeController.text,
                  items: const [
                    DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                    DropdownMenuItem(
                      value: 'Annually',
                      child: Text('Annually'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      planTypeController.text = value;
                      intervalController.text = value == 'Monthly'
                          ? '30'
                          : '365';
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Please select a plan type' : null,
                ),
                const SizedBox(height: 12),
                _buildField(
                  intervalController,
                  'Interval in Days',
                  border,
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
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
                const SizedBox(height: 24),
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
                          intervalInDays:
                              int.tryParse(intervalController.text) ?? 0,
                        );
                        Navigator.pop(context);
                        onSubscriptionAdded();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Subscription',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: hint,
        border: border,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
