import 'package:fluent_ui/fluent_ui.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:io';
import 'add_command_page.dart';
import 'command_detail_page.dart';
import 'package:flutter/services.dart'; // Add this import

class CommandListPage extends StatefulWidget {
  const CommandListPage({super.key});

  @override
  _CommandListPageState createState() => _CommandListPageState();
}

class _CommandListPageState extends State<CommandListPage> {
  List<Map<String, String>> commands = [];

  @override
  void initState() {
    super.initState();
    _loadCommands();
  }

  Future<void> _loadCommands() async {
    final file = File('commands.xml');
    if (await file.exists()) {
      final xmlString = await file.readAsString();
      final document = xml.XmlDocument.parse(xmlString);
      final commandElements = document.findAllElements('command');
      setState(() {
        commands = commandElements.map((element) {
          return {
            'title': element.findElements('title').single.innerText,
            'description': element.findElements('description').single.innerText,
            'command': element.findElements('sql').single.innerText,
          };
        }).toList();
      });
    }
  }

  Future<void> _saveCommands() async {
    final builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('commands', nest: () {
      for (var command in commands) {
        builder.element('command', nest: () {
          builder.element('title', nest: command['title']);
          builder.element('description', nest: command['description']);
          builder.element('sql', nest: command['command']);
        });
      }
    });
    final file = File('commands.xml');
    await file.writeAsString(builder.buildDocument().toXmlString(pretty: true));
  }

  void _addCommand(Map<String, String> newCommand) {
    setState(() {
      commands.add(newCommand);
    });
    _saveCommands();
  }

  void _editCommand(int index, Map<String, String> updatedCommand) {
    setState(() {
      commands[index] = updatedCommand;
    });
    _saveCommands();
  }

  void _deleteCommand(int index) {
    setState(() {
      commands.removeAt(index);
    });
    _saveCommands();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      
      content: ListView.builder(
        itemCount: commands.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(commands[index]['title']!),
            subtitle: Text(commands[index]['description']!),
            trailing: IconButton(
              icon: const Icon(FluentIcons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: commands[index]['command'] ?? ''));
                
              },
            ),
            onPressed: () {
              Navigator.push(
                context,
                FluentPageRoute(
                  builder: (context) => CommandDetailPage(
                    command: commands[index],
                    onSave: (updatedCommand) => _editCommand(index, updatedCommand),
                    onDelete: () {
                      _deleteCommand(index);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      header: PageHeader(
        title: const Text('SQL Commands'),
        commandBar: IconButton(
          icon: const Icon(FluentIcons.add),
          onPressed: () {
            Navigator.push(
              context,
              FluentPageRoute(
                builder: (context) => AddCommandPage(onAddCommand: _addCommand),
              ),
            );
          },
        ),
      ),
    );
  }
}