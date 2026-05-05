import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../services/wallet_service.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final String transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  ConsumerState<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends ConsumerState<TransactionDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _transaction;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final service = WalletService();
    final result = await service.getTransaction(widget.transactionId);
    if (mounted) {
      setState(() {
        _transaction = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0A1A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
      );
    }

    final recipient = _transaction!['recipient'] as Map<String, dynamic>?;
    final metadata = _transaction!['metadata'] as Map<String, dynamic>? ?? {};
    final isIn = ['transfer_in', 'deposit'].contains(_transaction!['type']);
    final status = _transaction!['status'] ?? 'pending';
    final amount = (_transaction!['amount'] ?? 0).toDouble();
    final shortId = "TXN${_transaction!['id'].toString().toUpperCase().substring(0, 8)}";
    final recipientName = recipient?['name'] ?? metadata['recipient_name'] ?? 'Wallet Transfer';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHero(isIn, amount, status),
                _buildDetailsSection(metadata, shortId, recipientName),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
      title: const Text('Transaction Detail', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHero(bool isIn, double amount, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.2), width: 2)),
            child: const Center(child: Icon(LucideIcons.check, color: Color(0xFF7C3AED), size: 40)),
          ),
          const SizedBox(height: 24),
          Text('${isIn ? "+" : "-"}${NumberFormat.currency(symbol: "").format(amount)} ETB', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(status.toUpperCase(), style: const TextStyle(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> metadata, String shortId, String recipientName) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          _buildDetailRow('From/To', recipientName, LucideIcons.user),
          _buildDivider(),
          _buildDetailRow('Transaction ID', shortId, LucideIcons.hash, trailing: const Icon(LucideIcons.copy, color: Colors.white24, size: 16)),
          _buildDivider(),
          _buildDetailRow('Date & Time', DateFormat('MMM d, yyyy, h:mm a').format(DateTime.parse(_transaction!['created_at'])), LucideIcons.clock),
          _buildDivider(),
          _buildDetailRow('Payment Method', metadata['method'] ?? 'Wallet Balance', LucideIcons.wallet),
          if (metadata['note'] != null) ...[
            _buildDivider(),
            _buildDetailRow('Reference Note', '"${metadata['note']}"', LucideIcons.fileText),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Widget? trailing}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF7C3AED), size: 18)),
      title: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      trailing: trailing,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.03), indent: 70);
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () => context.push('/transaction-receipt', extra: _transaction),
              icon: const Icon(LucideIcons.download, color: Colors.white, size: 20),
              label: const Text('Download Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.1)), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () {},
              icon: const Icon(LucideIcons.alertCircle, color: Colors.white38, size: 20),
              label: const Text('Report an Issue', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
