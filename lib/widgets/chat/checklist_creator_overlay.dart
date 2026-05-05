import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';

class ChecklistCreatorOverlay extends StatefulWidget {
  final Function(String title, List<String> items) onSend;

  const ChecklistCreatorOverlay({super.key, required this.onSend});

  @override
  State<ChecklistCreatorOverlay> createState() => _ChecklistCreatorOverlayState();
}

class _ChecklistCreatorOverlayState extends State<ChecklistCreatorOverlay> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _itemControllers = [TextEditingController()];
  final ScrollController _scrollController = ScrollController();

  void _addItem() {
    setState(() {
      _itemControllers.add(TextEditingController());
    });
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeItem(int index) {
    if (_itemControllers.length > 1) {
      setState(() {
        _itemControllers[index].dispose();
        _itemControllers.removeAt(index);
      });
    }
  }

  void _onSend() {
    final title = _titleController.text.trim().isEmpty ? 'Checklist' : _titleController.text.trim();
    final items = _itemControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (items.isNotEmpty) {
      widget.onSend(title, items);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var c in _itemControllers) {
      c.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                const Text(
                  'Create Checklist',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton(
                  onPressed: _onSend,
                  child: Text('Send', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Content
          Flexible(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              shrinkWrap: true,
              children: [
                const Text('Title', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GlassmorphicContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _titleController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'e.g., Grocery List',
                      hintStyle: TextStyle(color: Colors.white24),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Items', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate(_itemControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: GlassmorphicContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _itemControllers[index],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Item ${index + 1}',
                                hintStyle: const TextStyle(color: Colors.white24),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Item'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
