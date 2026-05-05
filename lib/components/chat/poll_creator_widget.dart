import 'package:flutter/material.dart';

class PollCreatorWidget extends StatefulWidget {
  const PollCreatorWidget({super.key});

  @override
  State<PollCreatorWidget> createState() => _PollCreatorWidgetState();
}

class _PollCreatorWidgetState extends State<PollCreatorWidget> {
  final List<TextEditingController> _options = [TextEditingController(), TextEditingController()];
  bool _allowMultipleAnswers = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Poll', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_options.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _options[index],
                        decoration: InputDecoration(
                          hintText: 'Option ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (index >= 2)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _options.removeAt(index)),
                      )
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() => _options.add(TextEditingController())),
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Allow multiple answers'),
              value: _allowMultipleAnswers,
              onChanged: (val) => setState(() => _allowMultipleAnswers = val),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Send Poll', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
