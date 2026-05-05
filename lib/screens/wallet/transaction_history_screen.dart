import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/wallet_service.dart';
import '../../models/wallet_transaction.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

final walletServiceProvider = Provider((ref) => WalletService());

final walletDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.watch(walletServiceProvider);
  return service.getWalletBalance(forceRefresh: true);
});

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  String _selectedTab = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletAsync = ref.watch(walletDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A), // Matching web app BG
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Transaction History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 20),
            onPressed: () => ref.refresh(walletDataProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF16102A),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search by recipient or note',
                  hintStyle: TextStyle(color: Colors.grey),
                  icon: Icon(LucideIcons.search, color: Colors.grey, size: 18),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterTab(
                  label: 'All',
                  active: _selectedTab == 'all',
                  onTap: () => setState(() => _selectedTab = 'all'),
                ),
                _FilterTab(
                  label: 'Received',
                  active: _selectedTab == 'received',
                  onTap: () => setState(() => _selectedTab = 'received'),
                ),
                _FilterTab(
                  label: 'Sent',
                  active: _selectedTab == 'sent',
                  onTap: () => setState(() => _selectedTab = 'sent'),
                ),
                _FilterTab(
                  label: 'Top-up',
                  active: _selectedTab == 'topup',
                  onTap: () => setState(() => _selectedTab = 'topup'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // List
          Expanded(
            child: walletAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
              data: (data) {
                final List txnsJson = data['transactions'] ?? [];
                final allTxns = txnsJson.map((e) => WalletTransaction.fromJson(e)).toList();
                
                final filtered = allTxns.where((t) {
                  if (_selectedTab != 'all') {
                    if (_selectedTab == 'received' && t.type != 'transfer_in') return false;
                    if (_selectedTab == 'sent' && t.type != 'transfer_out') return false;
                    if (_selectedTab == 'topup' && t.type != 'deposit') return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    if (!(t.description ?? '').toLowerCase().contains(q) && 
                        !t.amount.toString().contains(q)) return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const _EmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final t = filtered[index];
                    return _TransactionCard(transaction: t);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF7C3AED) : const Color(0xFF16102A),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: active ? const Color(0xFF7C3AED) : Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIn = transaction.type == 'transfer_in' || transaction.type == 'deposit';
    final amountColor = isIn ? const Color(0xFF10b981) : const Color(0xFFef4444);
    
    return InkWell(
      onTap: () => context.push('/transaction-detail/${transaction.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16102A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(transaction.type),
                color: amountColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(transaction.type, transaction.description),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('h:mm a').format(transaction.createdAt)} • ${transaction.description ?? ''}',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIn ? "+" : "-"}${transaction.amount.toStringAsFixed(2)} ETB',
                  style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    transaction.status.toUpperCase(),
                    style: TextStyle(color: _getStatusColor(transaction.status), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'deposit': return LucideIcons.wallet;
      case 'transfer_in': return LucideIcons.arrowDownLeft;
      case 'transfer_out': return LucideIcons.arrowUpRight;
      case 'withdrawal': return LucideIcons.arrowUpRight;
      default: return LucideIcons.refreshCw;
    }
  }

  String _getTitle(String type, String? desc) {
    if (desc != null && desc.isNotEmpty) return desc;
    switch (type) {
      case 'deposit': return 'Wallet Top-up';
      case 'transfer_in': return 'Received';
      case 'transfer_out': return 'Sent';
      default: return 'Transaction';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return const Color(0xFF10b981);
      case 'pending': return const Color(0xFFf59e0b);
      case 'failed': return const Color(0xFFef4444);
      default: return Colors.grey;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.search, color: Color(0xFF7C3AED), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No transactions found', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Your transaction history is empty',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
