import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class BillSplitCard extends StatelessWidget {
  final Map<String, dynamic> billData;
  final bool isMe;

  const BillSplitCard({super.key, required this.billData, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: "");
    final total = billData['total'] as double;
    final peopleCount = (billData['people'] as List).length;
    final perPerson = total / peopleCount;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF150D28), Color(0xFF1C1130)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.receipt, color: Color(0xFF7C3AED), size: 16),
              ),
              const SizedBox(width: 12),
              const Text('BILL SPLIT', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          Text(billData['title'] ?? 'Expense Split', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL', style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
                  Text('${currencyFormat.format(total)} ETB', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('PER PERSON', style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
                  Text('${currencyFormat.format(perPerson)} ETB', style: const TextStyle(color: const Color(0xFF10B981), fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 12)),
              onPressed: () {},
              child: const Text('Pay Your Share', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
