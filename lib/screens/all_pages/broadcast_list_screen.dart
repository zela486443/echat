import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_locales.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';

class BroadcastListScreen extends ConsumerStatefulWidget {
  const BroadcastListScreen({super.key});

  @override
  ConsumerState<BroadcastListScreen> createState() => _BroadcastListScreenState();
}

class _BroadcastListScreenState extends ConsumerState<BroadcastListScreen> {
  final Set<String> _selectedIds = {};
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  final List<PublicProfile> _suggestedContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final service = ref.read(supabaseServiceProvider);
    final profiles = await service.searchProfiles(''); // Fallback to first 20
    if (mounted) {
      setState(() {
        _suggestedContacts.addAll(profiles);
        _isLoading = false;
      });
    }
  }

  void _handleBroadcast() {
    if (_messageController.text.trim().isEmpty || _selectedIds.isEmpty) return;
    setState(() => _isSending = true);
    // Real implementation would loop through selectedIds and send messages
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${ref.tr('broadcast_sent')} ${_selectedIds.length} ${ref.tr('recipients')}! 📡'), backgroundColor: Colors.blue));
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: Row(children: [Text(ref.tr('broadcast'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(width: 8), const Icon(Icons.radio, color: Colors.blue, size: 18)]),
        actions: [
          if (_selectedIds.isNotEmpty) Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle), child: Text('${_selectedIds.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))))),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue)) : Column(
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Align(alignment: Alignment.centerLeft, child: Text(ref.tr('select_recipients').toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)))),
          Expanded(
            child: ListView.builder(
              itemCount: _suggestedContacts.length,
              itemBuilder: (context, index) {
                final c = _suggestedContacts[index];
                bool isSelected = _selectedIds.contains(c.id);
                return ListTile(
                  onTap: () => setState(() => isSelected ? _selectedIds.remove(c.id) : _selectedIds.add(c.id)),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.05),
                        backgroundImage: c.avatarUrl != null ? NetworkImage(c.avatarUrl!) : null,
                        child: c.avatarUrl == null ? Text(c.name?[0] ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
                      ),
                      if (isSelected) Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 10))),
                    ],
                  ),
                  title: Text(c.name ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text('@${c.username}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                );
              },
            ),
          ),
          _buildInputPanel(),
        ],
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
      child: Column(
        children: [
          TextField(controller: _messageController, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: ref.tr('type_message_hint'), hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: (_selectedIds.isEmpty || _isSending) ? null : _handleBroadcast,
              icon: _isSending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send, color: Colors.white),
              label: Text(_isSending ? ref.tr('sending') : '${ref.tr('broadcast_to')} ${_selectedIds.length} ${ref.tr('recipients')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), disabledBackgroundColor: Colors.blue.withOpacity(0.3)),
            ),
          ),
        ],
      ),
    );
  }
}
