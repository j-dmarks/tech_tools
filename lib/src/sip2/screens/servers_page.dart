import 'package:fluent_ui/fluent_ui.dart';
import '../utils/globals.dart';
import 'package:xml/xml.dart' as xml;
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

class ServersPage extends StatefulWidget{
  const ServersPage({super.key});

  @override

  ServersPageState createState() => ServersPageState();
}


class ServersPageState extends State<ServersPage>{
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
    return ListView.builder(
      itemCount: servers.length,
      itemBuilder: (context, index) {
        final server = servers[index];
        return ListTile(
          title: Text(
            server['name']!,
          ),
          subtitle: Text(
            '${server['host']}:${server['port']}',
          ),
          onPressed: () {
            nameController.text = server['name']!;
            serverController.text = server['host']!;
            portController.text = server['port']!;
            aoController.text = server['ao']!;
            usernameController.text = server['username']!;
            passwordController.text = server['password']!;
            locationCodeController.text = server['locationCode']!; 
            displayInfoBar(context, builder: (context, close) {
              return InfoBar(
                title: const Text('Server Loaded'),
                content:  Text(
                    'Server: ${nameController.text}'),
                action: IconButton(
                  icon: const Icon(FluentIcons.clear),
                  onPressed: close,
                ),
                severity: InfoBarSeverity.success,
              );
            });                 
          },
          trailing: IconButton(
            icon: Icon(FluentIcons.delete, color: Colors.red),
            onPressed: () {
              setState(() => servers.remove(server));
              _saveServers();
            },
          ),
        );
      },
    );
  }

}