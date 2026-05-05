import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';

class TransactionReceiptScreen extends ConsumerWidget {
  final Map<String, dynamic> transaction;
  const TransactionReceiptScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = transaction['metadata'] as Map<String, dynamic>;
    final isIn = ['transfer_in', 'deposit'].contains(transaction['type']);
    final amount = transaction['amount'] as double;
    final shortId = "TXN${transaction['id'].toString().substring(0, 8).toUpperCase()}";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('E-Receipt', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(LucideIcons.share2, color: Colors.white70), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  const Text('Echats Official Receipt', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(DateFormat('MMM d, yyyy · HH:mm').format(DateTime.parse(transaction['created_at'])), style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 10)),
                  const SizedBox(height: 24),
                  _buildReceiptDivider(),
                  const SizedBox(height: 24),
                  Text('${isIn ? "+" : "-"}${NumberFormat.currency(symbol: "").format(amount)} ETB', style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 32, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(isIn ? 'Total Received' : 'Total Payment', style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  _buildReceiptInfo('RECIPIENT', meta['recipient_name'] ?? 'Wallet'),
                  _buildReceiptInfo('TRANSACTION ID', shortId),
                  _buildReceiptInfo('METHOD', meta['method'] ?? 'Wallet Balance'),
                  const SizedBox(height: 32),
                  const Text('SCAN TO VERIFY', style: TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: 'echats-verify-${transaction['id']}',
                    version: QrVersions.auto,
                    size: 150.0,
                    eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                    dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                  ),
                  const SizedBox(height: 32),
                  _buildReceiptDivider(),
                  const SizedBox(height: 16),
                  const Text('Thank you for using Echats Wallet', style: TextStyle(color: Colors.black38, fontSize: 10, fontStyle: FontStyle.italic)),
                  const Text('Validated by Wallet Network', style: TextStyle(color: Colors.black38, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () {},
              icon: const Icon(LucideIcons.download, color: Colors.white, size: 20),
              label: const Text('Save to Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReceiptDivider() {
    return Row(
      children: List.generate(30, (index) => Expanded(child: Container(height: 1, color: index % 2 == 0 ? Colors.black.withOpacity(0.1) : Colors.transparent))),
    );
  }
}
