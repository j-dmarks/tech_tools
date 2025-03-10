import 'package:fluent_ui/fluent_ui.dart';
import '../utils/globals.dart';
import 'package:universal_io/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart'as xml;



class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});

  @override

  SettingsPageState createState() => SettingsPageState();
}


class SettingsPageState extends State<SettingsPage>{
  final decoration = BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    );

  @override
  void initState() {
    super.initState();
    loadServers();
  }

Future<File> getLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/servers2.xml');
}

    Future<void> loadServers() async {
    final file = await getLocalFile();
    if (await file.exists()) {
      final xmlString = await file.readAsString();
      final document = xml.XmlDocument.parse(xmlString);
      final serverElements = document.findAllElements('server');
      setState(() {
        servers = serverElements.map((element) {
          return {
            'name': element.findElements('name').single.innerText,
            'host': element.findElements('host').single.innerText,
            'port': element.findElements('port').single.innerText,
            'ao': element.findElements('ao').single.innerText,
            'username': element.findElements('username').single.innerText,
            'password': element.findElements('password').single.innerText,
            'locationCode': element.findElements('locationCode').single.innerText,
          };
        }).toList();
      });
    }
  }


  Future<void> _saveServers() async {
    final builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('servers', nest: () {
      for (var server in servers) {
        builder.element('server', nest: () {
          builder.element('name', nest: server['name']);
          builder.element('host', nest: server['host']);
          builder.element('port', nest: server['port']);
          builder.element('ao', nest: server['ao']);
          builder.element('username', nest: server['username']);
          builder.element('password', nest: server['password']);
          builder.element('locationCode', nest: server['locationCode']);
        });
      }
    });
    final xmlString = builder.buildDocument().toXmlString(pretty: true, indent: '  ');
    final file = await getLocalFile();

    await file.writeAsString(xmlString);
  }

  void _addServer(Map<String, String> newServer) {
    setState(() {
      servers.add(newServer);
    });
    _saveServers();
  }


  @override
  
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(width:2), borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  TextBox(controller: serverController, decoration: decoration,placeholder: 'Sever Address',),
                  const SizedBox(height: 5),
                  TextBox(controller: portController, decoration: decoration,placeholder: 'Server Port'),
                  const SizedBox(height: 5),
                  TextBox(controller: aoController, decoration: decoration,placeholder: 'AO'),
                  
                ]
              ),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(border: Border.all(width:2), borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(5),
              child: Column(children: [
                  TextBox(controller: usernameController, decoration: decoration,placeholder: 'Username'),
                  const SizedBox(height: 5),
                  TextBox(controller: passwordController, decoration: decoration,placeholder: 'Password'),
                  const SizedBox(height: 5),
                  TextBox(controller: locationCodeController, decoration: decoration,placeholder: 'Location Code')
              ]),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(border: Border.all(width:2), borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(5),
              child:Column(children: [
                TextBox(controller: nameController,decoration: decoration,placeholder: 'Library Name'),
                const SizedBox(height: 5),
            FilledButton(
              onPressed: () {
                _addServer({
                  'name': nameController.text,
                  'host': serverController.text, // Adjust based on correct field
                  'port': portController.text,
                  'ao': aoController.text,
                  'username': usernameController.text,
                  'password': passwordController.text,
                  'locationCode': locationCodeController.text,
                });
                displayInfoBar(
                  context,
                  builder: (context, close) {
                    return InfoBar(
                      title: const Text('Server Saved'),
                      content: Text('Server: ${nameController.text}'),
                      action: IconButton(
                        icon: const Icon(FluentIcons.clear),
                        onPressed: close,
                      ),
                      severity: InfoBarSeverity.success,
                    );
                  },
                );
              },
              child: const Text('Save'),
            ),
              ],)
            )
          ],
        ),
      ),
    );
  }

}




