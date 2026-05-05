import 'package:flutter/material.dart';

class BillSplitCreatorDialog extends StatefulWidget {
  final Future<void> Function(String title, double amount) onSend;

  const BillSplitCreatorDialog({super.key, required this.onSend});

  @override
  State<BillSplitCreatorDialog> createState() => _BillSplitCreatorDialogState();
}

class _BillSplitCreatorDialogState extends State<BillSplitCreatorDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  void _submit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (title.isEmpty || amount == null || amount <= 0) return;

    widget.onSend(title, amount);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Split a Bill'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'What is this for?', hintText: 'e.g. Dinner at Mamas'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Total Amount', prefixText: '\$ '),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Send Request')),
      ],
    );
  }
}

class BillSplitCardWidget extends StatelessWidget {
  final String title;
  final double totalAmount;

  const BillSplitCardWidget({super.key, required this.title, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: theme.primaryColor),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Text('\$${totalAmount.toStringAsFixed(2)}', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {}, // Deep link to Payment/Wallet processing
              child: const Text('Pay Your Share'),
            ),
          )
        ],
      ),
    );
  }
}
