import 'package:fluent_ui/fluent_ui.dart';
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
    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text('Edit Command'),
        actions: Wrap(
          children: [
            IconButton(
              icon: const Icon(FluentIcons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _commandController.text));
                
              },
            ),
            IconButton(
              icon: const Icon(FluentIcons.delete),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextBox(
              controller: _titleController,
              placeholder: 'Title',
            ),
            const SizedBox(height: 16),
            TextBox(
              controller: _descriptionController,
              placeholder: 'Description',
            ),
            const SizedBox(height: 16),
            TextBox(
              controller: _commandController,
              maxLines: null,
              placeholder: 'SQL Command',
              suffix: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _commandController.text));
                },
                icon: const Icon(FluentIcons.copy),
              ),
            ),
            const SizedBox(height: 16),
            Button(
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
