import 'package:fluent_ui/fluent_ui.dart';


class AddCommandPage extends StatefulWidget {
  final Function(Map<String, String>) onAddCommand;

  const AddCommandPage({super.key, required this.onAddCommand});

  @override
  AddCommandPageState createState() => AddCommandPageState();
}

class AddCommandPageState extends State<AddCommandPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _commandController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        title:  Text('Add New Command'),
      ),
      content: SingleChildScrollView(
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
              ),
            const SizedBox(height: 16),
            Button(
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