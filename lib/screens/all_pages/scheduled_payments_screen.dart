import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class ScheduledPaymentsScreen extends ConsumerStatefulWidget {
  const ScheduledPaymentsScreen({super.key});

  @override
  ConsumerState<ScheduledPaymentsScreen> createState() => _ScheduledPaymentsScreenState();
}

class _ScheduledPaymentsScreenState extends ConsumerState<ScheduledPaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(scheduledPaymentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Scheduled Payments', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white70), onPressed: () => ref.refresh(scheduledPaymentsProvider)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/send-money'),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Schedule New Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 8, shadowColor: const Color(0xFF7C3AED).withOpacity(0.5)),
              ),
            ),
          ),
          Expanded(
            child: paymentsAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white38))),
              data: (payments) {
                final upcoming = payments.where((p) => p['processed'] != true).toList();
                final completed = payments.where((p) => p['processed'] == true).toList();

                if (payments.isEmpty) {
                  return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.calendar_month_outlined, color: Colors.white10, size: 64), SizedBox(height: 16), Text('No scheduled payments', style: TextStyle(color: Colors.white24, fontSize: 16))]));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        _buildSectionHeader('Upcoming Payments', upcoming.length),
                        ...upcoming.map((p) => _buildUpcomingCard(p)),
                      ],
                      if (completed.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Text('Recently Completed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildCompletedList(completed),
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

  Widget _buildUpcomingCard(Map<String, dynamic> p) {
    final recipient = p['recipient'] ?? {};
    final name = recipient['name'] ?? 'Unknown';
    final date = DateTime.tryParse(p['scheduled_for'] ?? '') ?? DateTime.now();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF16102A), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26, 
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            backgroundImage: recipient['avatar_url'] != null ? NetworkImage(recipient['avatar_url']) : null,
            child: recipient['avatar_url'] == null ? Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${DateFormat('MMM dd • h:mm a').format(date)} • ${p['frequency']}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              const SizedBox(height: 4),
              Text('ETB ${(p['amount'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.white24, size: 20), onPressed: () {}),
              IconButton(icon: const Icon(Icons.delete, color: Colors.white24, size: 20), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedList(List<Map<String, dynamic>> completed) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF16102A), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: completed.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withOpacity(0.05)),
        itemBuilder: (context, index) {
          final p = completed[index];
          final recipient = p['recipient'] ?? {};
          final date = DateTime.tryParse(p['scheduled_for'] ?? '') ?? DateTime.now();
          return ListTile(
            leading: CircleAvatar(radius: 18, backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1), child: const Icon(Icons.check, color: Color(0xFFA78BFA), size: 16)),
            title: Text(recipient['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(date), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
            trailing: Text('ETB ${(p['amount'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          );
        },
      ),
    );
  }
}
