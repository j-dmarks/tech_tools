import 'package:flutter/material.dart';


class AddCommandPage extends StatefulWidget {
  final Function(Map<String, String>) onAddCommand;

  const AddCommandPage({super.key, required this.onAddCommand});

  @override
  _AddCommandPageState createState() => _AddCommandPageState();
}

class _AddCommandPageState extends State<AddCommandPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _commandController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Command'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commandController,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'SQL Command',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final newCommand = {
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'command': _commandController.text,
                };
                widget.onAddCommand(newCommand);
                Navigator.pop(context);
              },
              child: const Text('Add Command'),
            ),
          ],
        ),
      ),
    );
  }
}