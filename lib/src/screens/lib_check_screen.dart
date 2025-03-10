import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class LibCheckScreen extends StatefulWidget {
  const LibCheckScreen({super.key});

  @override
  State<LibCheckScreen> createState() => _LibCheckScreenState();
}

class _LibCheckScreenState extends State<LibCheckScreen> {
  final _responseController = TextEditingController();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _libraries = [];
  List<Map<String, dynamic>> _filteredLibraries = [];
  
  String _searchParameter = 'name'; // Default search by name

  @override
  void dispose() {
    _responseController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      print('Could not launch $url');
    }
  }
  Future<void> libsCheck() async {
    final response = await http.get(Uri.parse('https://prod-bsi.web.app/api/v3/allLibraries'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _responseController.text = response.body;
        _libraries = data.map((lib) => Map<String, dynamic>.from(lib)).toList();
        _filteredLibraries = List.from(_libraries);
      });
    } else {
      setState(() {
        _responseController.text = 'Libs Check Failed';
        _libraries = [];
        _filteredLibraries = [];
      });
    }
  }

  void _filterLibraries(String query) {
    setState(() {
      _filteredLibraries = _libraries
          .where((lib) =>
              lib[_searchParameter] != null &&
              lib[_searchParameter].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const libristaURL = "https:librista.com/";
    return ScaffoldPage(
      header: const PageHeader(title: Text('Librista Sites')),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fetch Libraries Button
            Row(
              children: [
                Button(
                  onPressed: libsCheck,
                  child: const Text('Load libraries'),
                ),
                const SizedBox(width: 10),
                Button(onPressed:() => _launchURL(libristaURL),
                child: const Text("librista.com")),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Dropdown for Search Parameter
                SizedBox(
                  width: 150,
                  child: ComboBox<String>(
                    value: _searchParameter,
                    items: const [
                      ComboBoxItem(value: 'name', child: Text('Name')),
                      ComboBoxItem(value: 'hostname', child: Text('Hostname')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _searchParameter = value!;
                        _filterLibraries(_searchController.text);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // Search Box
                Expanded(
                  child: TextBox(
                    controller: _searchController,
                    placeholder: 'Search...',
                    onChanged: _filterLibraries,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Library List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredLibraries.length,
                itemBuilder: (context, index) {
                  final lib = _filteredLibraries[index];
                  final opacUrl = "${lib['scheme']}://${lib['hostname']}/opac/${lib["library"]}/";
                  final logonURL = "${lib['scheme']}://${lib['hostname']}/libs/${lib["library"]}/";
                  return Card(
                    child: ListTile(
                      title: Text(lib['name'] ?? 'Unknown Library'),
                      subtitle: Text('${lib['city']}, ${lib['state']}'),
                      trailing: Row(
                        children: [
                          Text(lib['hostname'] ?? ''),
                          const SizedBox(width: 5,),
                          Button(
                          onPressed:() => _launchURL(opacUrl),
                          child: const Text("Go to OPAC")
                          ,),
                          const SizedBox(width: 5,),
                          Button(
                            onPressed:() => _launchURL(logonURL),
                            child: const Text("Go to LibrarianLogON")
                            ),
                            const SizedBox(width: 5),
                            
                          ],
                      ), 
                      
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Raw API Response Box
            
          ],
        ),
      ),
    );
  }
}
