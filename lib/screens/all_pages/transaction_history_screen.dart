import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  String _activeTab = 'All';
  String _searchQuery = "";

  final List<Map<String, dynamic>> _transactions = [
    {'id': '1', 'type': 'transfer_in', 'amount': 1500.0, 'description': 'From Abel Tesfaye', 'time': '10:45 AM', 'date': 'TODAY', 'status': 'completed'},
    {'id': '2', 'type': 'transfer_out', 'amount': 450.0, 'description': 'Bill Payment', 'time': '9:15 AM', 'date': 'TODAY', 'status': 'completed'},
    {'id': '3', 'type': 'deposit', 'amount': 5000.0, 'description': 'Bank Transfer', 'time': '4:30 PM', 'date': 'YESTERDAY', 'status': 'completed'},
    {'id': '4', 'type': 'transfer_out', 'amount': 120.0, 'description': 'Coffee Shop', 'time': '11:20 AM', 'date': 'YESTERDAY', 'status': 'pending'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildSearchBarSliver(),
              _buildFilterTabsSliver(),
              _buildTransactionListSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0A1A).withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
      title: const Text('Transaction History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      actions: [
        IconButton(icon: const Icon(LucideIcons.refreshCw, color: Colors.white24, size: 18), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBarSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(
            children: [
              const Icon(LucideIcons.search, color: Colors.white38, size: 17),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Search by recipient or note', hintStyle: TextStyle(color: Colors.white24, fontSize: 13), border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabsSliver() {
    final tabs = ['All', 'Received', 'Sent', 'Top-up'];
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final t = tabs[index];
            final active = _activeTab == t;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF7C3AED) : const Color(0xFF151122),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: active ? const Color(0xFF7C3AED) : Colors.white.withOpacity(0.05)),
                    boxShadow: active ? [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                  ),
                  child: Center(child: Text(t, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold))),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionListSliver() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) return _buildDateHeader('TODAY');
            if (index == 3) return _buildDateHeader('YESTERDAY');
            final txn = _transactions[index % _transactions.length];
            return _buildTransactionCard(txn);
          },
          childCount: 10,
        ),
      ),
    );
  }

  Widget _buildDateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 12),
      child: Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> txn) {
    final bool isIn = txn['type'] == 'transfer_in' || txn['type'] == 'deposit';
    Color iconColor;
    IconData icon;
    Color bg;

    if (txn['type'] == 'transfer_in') {
      iconColor = const Color(0xFF10B981);
      icon = LucideIcons.arrowDownLeft;
      bg = const Color(0xFF10B981).withOpacity(0.1);
    } else if (txn['type'] == 'transfer_out') {
      iconColor = Colors.redAccent;
      icon = LucideIcons.arrowUpRight;
      bg = Colors.redAccent.withOpacity(0.1);
    } else {
      iconColor = const Color(0xFF7C3AED);
      icon = LucideIcons.wallet;
      bg = const Color(0xFF7C3AED).withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn['description'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${txn['time']} · ${txn['type'].toString().replaceAll('_', ' ')}', style: const TextStyle(color: Colors.white24, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${isIn ? '+' : '-'}${txn['amount']} ETB', style: TextStyle(color: isIn ? const Color(0xFF10B981) : Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: txn['status'] == 'completed' ? const Color(0xFF10B981).withOpacity(0.1) : Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(txn['status'].toString().toUpperCase(), style: TextStyle(color: txn['status'] == 'completed' ? const Color(0xFF10B981) : Colors.amber, fontSize: 8, fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(color: const Color(0xFF0D0A1A), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(LucideIcons.home, 'Home', false),
            _buildNavItem(LucideIcons.wallet, 'Wallet', true),
            _buildNavItem(LucideIcons.barChart2, 'Insights', false),
            _buildNavItem(LucideIcons.user, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? const Color(0xFF7C3AED) : Colors.white24, size: 22),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: active ? const Color(0xFF7C3AED) : Colors.white24, fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
