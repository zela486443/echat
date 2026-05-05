import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // In a full implementation, this uses Supabase .select() mapping
    final mockTransactions = List.generate(20, (i) => {
      'id': 'tx_$i',
      'title': i % 2 == 0 ? 'Sent to Alex' : 'Received from Sarah',
      'amount': i % 2 == 0 ? -150.00 : 300.00,
      'date': DateTime.now().subtract(Duration(days: i)),
      'status': i == 0 ? 'Pending' : 'Completed',
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(icon: const Icon(LucideIcons.filter), onPressed: () {}),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockTransactions.length,
        separatorBuilder: (context, _) => const Divider(),
        itemBuilder: (context, index) {
          final tx = mockTransactions[index];
          final isNegative = (tx['amount'] as double) < 0;
          
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Stack(
               children: [
                 CircleAvatar(
                    backgroundColor: isNegative ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    child: Icon(
                      isNegative ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                      color: isNegative ? Colors.red : Colors.green,
                    ),
                  ),
                 if (tx['status'] == 'Pending')
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    ),
                  )
               ],
            ),
            title: Text(tx['title'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('ID: ${tx['id']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isNegative ? '-\$${(-(tx['amount'] as double)).toStringAsFixed(2)}' : '+\$${(tx['amount'] as double).toStringAsFixed(2)}',

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isNegative ? Colors.red : Colors.green,
                  ),
                ),
                if (tx['status'] == 'Pending')
                   const Text('Pending', style: TextStyle(color: Colors.orange, fontSize: 12)),
              ],
            ),
            onTap: () {}, // Navigate to Transaction Receipt
          );
        },
      ),
    );
  }
}
