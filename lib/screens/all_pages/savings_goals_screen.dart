import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/wallet_provider.dart';

class SavingsGoalsScreen extends ConsumerStatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  ConsumerState<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends ConsumerState<SavingsGoalsScreen> {
  void _showAddFunds(Map<String, dynamic> goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1030),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text('Add Funds to Goal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Amount in ETB', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Add Funds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Savings Goals', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white70), onPressed: () => ref.refresh(savingsGoalsProvider)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Create New Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 8, shadowColor: const Color(0xFF7C3AED).withOpacity(0.5)))),
          ),
          Expanded(
            child: goalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white38))),
              data: (goals) {
                final active = goals.where((g) => g['status'] == 'active').toList();
                final completed = goals.where((g) => g['status'] == 'completed').toList();

                if (goals.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.savings_outlined, color: Colors.white10, size: 64),
                        SizedBox(height: 16),
                        Text('No savings goals yet', style: TextStyle(color: Colors.white24, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (active.isNotEmpty) ...[
                        _buildSectionHeader('Active Goals', active.length),
                        ...active.map((g) => _buildGoalCard(g)),
                      ],
                      if (completed.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Row(children: [Text('Completed Goals', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.emoji_events, color: Colors.amber, size: 20)]),
                        const SizedBox(height: 16),
                        ...completed.map((g) => _buildCompletedCard(g)),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text('$count Active', style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> g) {
    double current = (g['current_amount'] ?? 0).toDouble();
    double target = (g['target_amount'] ?? 1).toDouble();
    double pct = (current / target);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF18102E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(g['emoji'] ?? '🎯', style: const TextStyle(fontSize: 24)))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(g['name'] ?? 'Untitled', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Target: ${target.toStringAsFixed(0)} ETB', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                ]),
              ),
              const Icon(Icons.more_vert, color: Colors.white24, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${current.toStringAsFixed(0)} ETB', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text('${(pct * 100).toInt()}%', style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 14))]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: pct.clamp(0, 1), backgroundColor: Colors.white.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)), minHeight: 8)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _showAddFunds(g), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0), child: const Text('Add Funds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)))),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(Map<String, dynamic> g) {
    double target = (g['target_amount'] ?? 0).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF2D1250).withOpacity(0.8), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.2))),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('🏆', style: TextStyle(fontSize: 24)))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g['name'] ?? 'Untitled', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Goal Reached: ${target.toStringAsFixed(0)} ETB', style: const TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}
