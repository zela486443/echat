import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../providers/stars_provider.dart';
import '../core/constants.dart';

class GiftPickerOverlay extends StatefulWidget {
  final int balance;
  final Function(Gift, String?) onSend;
  final VoidCallback onClose;

  const GiftPickerOverlay({super.key, required this.balance, required this.onSend, required this.onClose});

  @override
  State<GiftPickerOverlay> createState() => _GiftPickerOverlayState();
}

class _GiftPickerOverlayState extends State<GiftPickerOverlay> {
  Gift? _selected;
  String _filter = 'all';
  final TextEditingController _messageController = TextEditingController();

  final List<String> _rarities = ['all', 'common', 'rare', 'epic', 'legendary'];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'all'
        ? AVAILABLE_GIFTS
        : AVAILABLE_GIFTS.where((g) => g.rarity.name == _filter).toList();

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
                    Icon(LucideIcons.gift, color: AppTheme.primary, size: 20),
                    SizedBox(width: 10),
                    Text('Send a Gift', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('${widget.balance} Stars', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _rarities.map((r) => GestureDetector(
                  onTap: () => setState(() => _filter = r),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _filter == r ? AppTheme.primary : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(r.toUpperCase(), style: TextStyle(color: _filter == r ? Colors.white : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )).toList(),
              ),
            ),
          ),

          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.85, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final gift = filtered[i];
                final active = _selected?.id == gift.id;
                return GestureDetector(
                  onTap: () => setState(() => _selected = gift),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: getRarityColor(gift.rarity).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppTheme.primary : getRarityColor(gift.rarity).withOpacity(0.2), width: active ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(gift.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(gift.name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 10),
                            const SizedBox(width: 2),
                            Text('${gift.stars}', style: TextStyle(color: getRarityColor(gift.rarity), fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Selection Footer
          if (_selected != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _messageController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Add a message... (optional)',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: widget.balance < _selected!.stars
                          ? null
                          : () => widget.onSend(_selected!, _messageController.text),
                      child: Text(
                        widget.balance < _selected!.stars
                            ? 'Need ${_selected!.stars - widget.balance} more Stars'
                            : 'Send ${_selected!.emoji} for ${_selected!.stars} Stars',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
