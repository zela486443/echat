import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WalletDashboard extends StatelessWidget {
  const WalletDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.history),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Balance Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: theme.primaryColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Balance', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('\$12,450.00', style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('**** **** **** 4092', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                      const Icon(LucideIcons.creditCard, color: Colors.white),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickActionBtn(context, icon: LucideIcons.arrowUp, label: 'Send'),
                _QuickActionBtn(context, icon: LucideIcons.arrowDown, label: 'Request'),
                _QuickActionBtn(context, icon: LucideIcons.plusCircle, label: 'Top Up'),
                _QuickActionBtn(context, icon: LucideIcons.moreHorizontal, label: 'More'),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Recent Transactions
            Text('Recent Transactions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.2)),
              itemBuilder: (context, index) {
                final isNegative = index % 2 == 0;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isNegative ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    child: Icon(
                      isNegative ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                      color: isNegative ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(isNegative ? 'Sent to Alex' : 'Received from Sarah', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Today, 10:4${index} AM', style: const TextStyle(color: Colors.grey)),
                  trailing: Text(
                    isNegative ? '-\$150.00' : '+\$300.00',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isNegative ? Colors.red : Colors.green,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _QuickActionBtn(BuildContext context, {required IconData icon, required String label}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Icon(icon, color: theme.primaryColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
