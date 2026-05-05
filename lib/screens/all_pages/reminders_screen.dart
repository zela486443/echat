import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/social_utilities_service.dart';
import '../../widgets/aurora_gradient_bg.dart';
import '../../widgets/glassmorphic_container.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final reminders = await ref.read(socialUtilsProvider).loadReminders();
    if (mounted) {
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReminder(String id) async {
    await ref.read(socialUtilsProvider).deleteReminder(id);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Reminders', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          if (_reminders.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16), 
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), 
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), 
                  child: Text('${_reminders.length}', style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))
                )
              )
            ),
        ],
      ),
      body: AuroraGradientBg(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty 
            ? _buildEmptyState() 
            : _buildReminderList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, 
            height: 64, 
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)), 
            child: const Icon(Icons.notifications_none, color: Colors.white38, size: 32)
          ),
          const SizedBox(height: 16),
          const Text('No reminders set', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Long-press any message to set a reminder', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildReminderList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final r = _reminders[index];
        final remindAt = DateTime.parse(r['remind_at']);
        final isExpired = remindAt.isBefore(DateTime.now());

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassmorphicContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, 
                  height: 40, 
                  decoration: BoxDecoration(
                    color: (isExpired ? Colors.grey : Colors.blue).withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(12)
                  ), 
                  child: Icon(Icons.notifications, color: isExpired ? Colors.grey : Colors.blue, size: 20)
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${r['content']}"', 
                        style: TextStyle(
                          color: isExpired ? Colors.white38 : Colors.white, 
                          fontSize: 13, 
                          height: 1.4,
                          decoration: isExpired ? TextDecoration.lineThrough : null
                        )
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM d, h:mm a').format(remindAt), 
                        style: TextStyle(color: isExpired ? Colors.white24 : Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (r['chat_id'] != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white38, size: 18), 
                        onPressed: () => context.push('/chat/${r['chat_id']}')
                      ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), 
                      onPressed: () => _deleteReminder(r['id'])
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
