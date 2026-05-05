import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class BillSplitMember {
  final String userId;
  final String name;
  bool selected;

  BillSplitMember({required this.userId, required this.name, this.selected = true});
}

class BillSplitCreatorOverlay extends StatefulWidget {
  final List<Map<String, String>> participants;
  final Function(String title, double amount, List<BillSplitMember> members) onCreated;
  final VoidCallback onClose;

  const BillSplitCreatorOverlay({
    super.key,
    required this.participants,
    required this.onCreated,
    required this.onClose,
  });

  @override
  State<BillSplitCreatorOverlay> createState() => _BillSplitCreatorOverlayState();
}

class _BillSplitCreatorOverlayState extends State<BillSplitCreatorOverlay> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late List<BillSplitMember> _members;

  @override
  void initState() {
    super.initState();
    _members = widget.participants.map((p) => BillSplitMember(userId: p['userId']!, name: p['name']!)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final selectedCount = _members.where((m) => m.selected).length;
    final perPerson = selectedCount > 0 ? amount / selectedCount : 0.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF150D28),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle
          Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.receipt, color: AppTheme.primary, size: 20),
                    SizedBox(width: 10),
                    Text('Split Bill', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(LucideIcons.x, color: Colors.white38), onPressed: widget.onClose),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildFieldLabel('Title'),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDec('e.g. Dinner at Habesha'),
                ),
                const SizedBox(height: 20),
                
                _buildFieldLabel('Total Amount (ETB)'),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDec('0.00').copyWith(prefixIcon: const Icon(LucideIcons.banknote, color: Colors.white30, size: 18)),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel('Split Between'),
                    Text('$selectedCount people', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ..._members.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => setState(() => m.selected = !m.selected),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: Colors.white.withOpacity(0.03),
                    title: Text(m.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    trailing: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: m.selected ? AppTheme.primary : Colors.transparent,
                        border: Border.all(color: m.selected ? AppTheme.primary : Colors.white30),
                      ),
                      child: m.selected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
                    ),
                  ),
                )),

                if (amount > 0 && selectedCount >= 2) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text('Each person pays', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${perPerson.toStringAsFixed(2)} ETB', style: TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      final t = _titleController.text.trim();
                      if (t.isEmpty || amount <= 0 || selectedCount < 2) return;
                      widget.onCreated(t, amount, _members.where((m) => m.selected).toList());
                    },
                    child: const Text('Create Split', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
