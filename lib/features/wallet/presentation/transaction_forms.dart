import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/wallet_controller.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum TransactionType { send, add, request }

class TransactionFormScreen extends ConsumerStatefulWidget {
  final TransactionType type;
  
  const TransactionFormScreen({super.key, required this.type});

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController(); // Or Phone/Username
  final _noteController = TextEditingController();

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    
    final controller = ref.read(walletControllerProvider.notifier);
    
    // Hardcoded target ID for the prototype mapping
    const targetUserId = 'mock-user-id';

    if (widget.type == TransactionType.send) {
      await controller.sendMoney(targetUserId, amount, _noteController.text);
    } else if (widget.type == TransactionType.request) {
      await controller.requestMoney(targetUserId, amount, _noteController.text);
    }
    
    if (mounted && !ref.read(walletControllerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.type.name.toUpperCase()} Success!'), backgroundColor: Colors.green));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(walletControllerProvider).isLoading;
    
    String title = 'Add Money';
    IconData icon = LucideIcons.plusCircle;
    if (widget.type == TransactionType.send) {
      title = 'Send Money';
      icon = LucideIcons.arrowUpRight;
    } else if (widget.type == TransactionType.request) {
      title = 'Request Money';
      icon = LucideIcons.arrowDownLeft;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(radius: 40, backgroundColor: theme.primaryColor.withOpacity(0.1), child: Icon(icon, size: 40, color: theme.primaryColor)),
            const SizedBox(height: 32),
            
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.displayMedium,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                prefixText: '\$ ', 
                hintText: '0.00',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
            const SizedBox(height: 32),
            
            if (widget.type != TransactionType.add) ...[
              TextField(
                controller: _recipientController,
                decoration: const InputDecoration(labelText: 'To (Username or Phone)', prefixIcon: Icon(LucideIcons.user)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'What is this for?', prefixIcon: Icon(LucideIcons.messageSquare)),
              ),
            ] else ...[
              // Add Money options (Credit Card mockup)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.primaryColor),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.creditCard),
                    const SizedBox(width: 16),
                    Expanded(child: Text('Visa ending in 4092', style: theme.textTheme.titleMedium)),
                    const Text('Change', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
            
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(title),
            )
          ],
        ),
      ),
    );
  }
}
