import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class AddGroupMembersScreen extends StatefulWidget {
  final String groupId;
  const AddGroupMembersScreen({super.key, required this.groupId});

  @override
  State<AddGroupMembersScreen> createState() => _AddGroupMembersScreenState();
}

class _AddGroupMembersScreenState extends State<AddGroupMembersScreen> {
  final List<Map<String, dynamic>> _contacts = [
    {'id': '1', 'name': 'Alex Smith', 'selected': false},
    {'id': '2', 'name': 'Sarah Connor', 'selected': false},
    {'id': '3', 'name': 'Michael Doe', 'selected': true},
    {'id': '4', 'name': 'David Miller', 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = _contacts.where((c) => c['selected'] as bool).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('$selectedCount selected', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
      body: Column(
        children: [
          // Selected Chips
          if (selectedCount > 0)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final c = _contacts[index];
                  if (!(c['selected'] as bool)) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.gradientAurora.colors.first.withOpacity(0.2),
                              child: Text(c['name'].toString().substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => setState(() => c['selected'] = false),
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.cancel, color: Colors.grey, size: 16),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(c['name'].toString().split(' ')[0], style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
          
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final c = _contacts[index];
                return CheckboxListTile(
                  value: c['selected'] as bool,
                  onChanged: (val) {
                    setState(() {
                      c['selected'] = val;
                    });
                  },
                  secondary: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    child: Text(c['name'].toString().substring(0, 1)),
                  ),
                  title: Text(c['name']),
                  activeColor: theme.colorScheme.primary,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: selectedCount > 0
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Members added.')));
                context.pop();
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.check, color: Colors.white),
            )
          : null,
    );
  }
}
