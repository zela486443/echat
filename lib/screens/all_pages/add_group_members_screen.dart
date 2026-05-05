import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';

class AddGroupMembersScreen extends ConsumerStatefulWidget {
  const AddGroupMembersScreen({super.key});

  @override
  ConsumerState<AddGroupMembersScreen> createState() => _AddGroupMembersScreenState();
}

class _AddGroupMembersScreenState extends ConsumerState<AddGroupMembersScreen> {
  final List<String> _selectedIds = [];
  final List<Map<String, String>> _contacts = [
    {'id': '1', 'name': 'Abebe B.', 'username': 'abebe', 'avatar': 'A'},
    {'id': '2', 'name': 'Melat V.', 'username': 'melat', 'avatar': 'M'},
    {'id': '3', 'name': 'Zola X.', 'username': 'zola', 'avatar': 'Z'},
    {'id': '4', 'name': 'Tigist W.', 'username': 'tigi', 'avatar': 'T'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${_selectedIds.length} of ${_contacts.length} selected', style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ),
      body: AuroraGradientBg(
        child: Column(
          children: [
            if (_selectedIds.isNotEmpty) _buildSelectedChips(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  final isSelected = _selectedIds.contains(contact['id']);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassmorphicContainer(
                      padding: const EdgeInsets.all(8),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (v) {
                          setState(() {
                            if (v!) _selectedIds.add(contact['id']!);
                            else _selectedIds.remove(contact['id']);
                          });
                        },
                        title: Text(contact['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('@${contact['username']}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        secondary: CircleAvatar(backgroundColor: AppTheme.primary.withOpacity(0.2), child: Text(contact['avatar']!, style: const TextStyle(color: Colors.white))),
                        activeColor: AppTheme.primary,
                        checkColor: Colors.white,
                        
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIds.isEmpty ? null : FloatingActionButton(
        onPressed: () => context.pop(_selectedIds),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }

  Widget _buildSelectedChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _selectedIds.length,
        itemBuilder: (context, index) {
          final id = _selectedIds[index];
          final contact = _contacts.firstWhere((c) => c['id'] == id);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              avatar: CircleAvatar(backgroundColor: AppTheme.primary, child: Text(contact['avatar']!, style: const TextStyle(fontSize: 10, color: Colors.white))),
              label: Text(contact['name']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
              onDeleted: () => setState(() => _selectedIds.remove(id)),
              deleteIconColor: Colors.white54,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }
}
