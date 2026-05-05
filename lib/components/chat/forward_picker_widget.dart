import 'package:flutter/material.dart';

class ForwardPickerWidget extends StatelessWidget {
  const ForwardPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forward to...'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Contact $index'),
                  trailing: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Send'),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
