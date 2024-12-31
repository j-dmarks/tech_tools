import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CommandDetailPage extends StatefulWidget {
  final Map<String, String> command;
  final Function(Map<String, String>) onSave;
  final VoidCallback onDelete;

  const CommandDetailPage({super.key, required this.command, required this.onSave, required this.onDelete});

  @override
  _CommandDetailPageState createState() => _CommandDetailPageState();
}

class _CommandDetailPageState extends State<CommandDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _commandController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.command['title']);
    _descriptionController = TextEditingController(text: widget.command['description']);
    _commandController = TextEditingController(text: widget.command['command']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Command'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _commandController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Command copied to clipboard')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: widget.onDelete,
          ),
        ],
      ),
      body: Padding(
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
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'SQL Command',
                suffixIcon: IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _commandController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Command copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final updatedCommand = {
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'command': _commandController.text,
                };
                widget.onSave(updatedCommand);
                Navigator.pop(context);
              },
              child: const Text('Save Command'),
            ),
          ],
        ),
      ),
    );
  }
}
