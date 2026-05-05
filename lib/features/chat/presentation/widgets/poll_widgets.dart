import 'package:flutter/material.dart';

class PollCreatorDialog extends StatefulWidget {
  final Future<void> Function(String question, List<String> options) onSend;

  const PollCreatorDialog({super.key, required this.onSend});

  @override
  State<PollCreatorDialog> createState() => _PollCreatorDialogState();
}

class _PollCreatorDialogState extends State<PollCreatorDialog> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionsControllers = [TextEditingController(), TextEditingController()];

  void _addOption() {
    if (_optionsControllers.length < 10) {
      setState(() => _optionsControllers.add(TextEditingController()));
    }
  }

  void _submit() {
    if (_questionController.text.trim().isEmpty) return;
    
    final validOptions = _optionsControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (validOptions.length < 2) return;

    widget.onSend(_questionController.text.trim(), validOptions);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Create a Poll'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Ask a question'),
            ),
            const SizedBox(height: 16),
            ..._optionsControllers.asMap().entries.map((entry) {
              int idx = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: 'Option ${idx + 1}',
                    suffixIcon: _optionsControllers.length > 2 
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => setState(() => _optionsControllers.removeAt(idx)),
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
            if (_optionsControllers.length < 10)
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Send')),
      ],
    );
  }
}
