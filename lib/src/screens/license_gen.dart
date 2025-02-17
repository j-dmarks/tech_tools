import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter/services.dart';

class LicenseGen extends StatefulWidget {
  const LicenseGen({super.key});

  @override
  LicenseGenState createState() => LicenseGenState();
}

class LicenseGenState extends State<LicenseGen> {
  String? _selectedOption;
  String? _selectedFed;
  String? _selectedFedExpDate ;
  String? _selectedStateStandards ;
  String? _selectedStateStandardsExpDate ;
  bool _checkboxValue1 = false;
  bool _checkboxValue2 = false;
  bool _checkboxValue3 = false;
  bool _checkboxValue4 = false;
  bool _checkboxValue5 = false;
  bool _checkboxValue6 = false;
  bool _checkboxValue7 = false;
  bool _checkboxValue8 = false;
  bool _checkboxValue9 = false;
  bool _checkboxValue10 = false;
  bool _checkboxValue11 = false;

  final TextEditingController _numberOfLibrariesController = TextEditingController();
  final TextEditingController _numberOfResolversController = TextEditingController();

  final Map<String, String> _optionsMap = {
    '': '',
    'Atriuum Distributed': '1',
    'Atriuum Centralized': '0',
    'BookTracks Distributed': '2',
    'BookTracks Centralized': '3',
  };

  final Map<String, String> _fedMap = {
    '': '',
    'Library': '0',
    'District': '1',
  };

  final Map<String, String> _fedExpMap = {
    '1 Year': '1',
    '2 Years': '2',
    '3 Years': '3',
    '4 Years': '4',
    '5 Years': '5',
    '20 Years': '20',
  };

  final Map<String, String> _selectedStateStandardsMap = {
    '': '',
    'Library': '0',
    'District': '1',
  };

  final Map<String, String> _selectedStateStandardsExpDateMap = {
    '1 Year': '1',
    '2 Years': '2',
    '3 Years': '3',
    '4 Years': '4',
    '5 Years': '5',
    '20 Years': '20',
  };

  List<Widget> _responseWidgets = [];

  Future<void> _sendPayload() async {
    const url = 'http://plone.internal.booksys.com/atriuum/create_generic_serial_num';

    final data = {
      'CreateLicenses': 'on',
      'L_ATRIUUM': _selectedOption ?? '',
      'T_ATRIUUMNUM': _numberOfLibrariesController.text,
      'C_ATRIUUMHISTORY': _checkboxValue1 ? 'on' : '',
      if (_checkboxValue2) 'C_ATRIUUMAUTH': 'on',
      if (_checkboxValue3) 'C_ATRIUUMACQ': 'on',
      if (_checkboxValue4) 'C_ATRIUUMSERIALS': 'on',
      if (_checkboxValue5) 'C_ATRIUUMSCS': 'on',
      'L_ATRIUUMFEDS': _selectedFed ?? '',
      'T_FEDEXPDATE': _selectedFedExpDate ?? '',
      'T_NUMFEDSSERVICES': _numberOfResolversController.text,
      'L_ATRIUUMSTATE': _selectedStateStandards ?? '',
      'T_STATEEXPDATE': _selectedStateStandardsExpDate ?? '',
      if (_checkboxValue6) 'C_ATRIUUMSIF': 'on',
      if (_checkboxValue7) 'C_ATRIUUMDEBT': 'on',
      'C_ATRIUUMRBS': _checkboxValue8 ? 'on' : '',
      'C_ATRIUUMILL': _checkboxValue9 ? 'on' : '',
      'C_ATRIUUMKIOSK': _checkboxValue10 ? 'on' : '',
      'C_POWERSCHOOL': _checkboxValue11 ? 'on' : '',
      'printSelection': 'product',
    };

    try {
      final response = await http.post(Uri.parse(url), body: data);
      if (response.statusCode == 200) {
        final document = parse(response.body);
        final table = document.getElementById('generatedTable');
        if (table != null) {
          List<Widget> widgets = [];
          widgets.add(const Text(
            'Your license numbers are:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ));
          final rows = table.getElementsByTagName('tr');
          for (var row in rows) {
            final cells = row.getElementsByTagName('td');
            if (cells.length == 2) {
              final licenseTextController = TextEditingController(text: cells[1].text.trim());
              widgets.add(Row(
                children: [
                  Text(
                    cells[0].text.trim(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextBox(                      
                      controller: licenseTextController,
                      suffix: IconButton(
                          icon: const Icon(FluentIcons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: licenseTextController.text));                                                       
                          },
                        ),
                      ),
                    ),
                
                ],
              ));
            } else if (cells.length == 1) {
              widgets.add(Text(
                cells[0].text.trim(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ));
            }
          }
          setState(() {
            _responseWidgets = widgets;
          });
        } else {
          setState(() {
            _responseWidgets = [const Text('No table found in response')];
          });
        }
      } else {
        setState(() {
          _responseWidgets = [Text('Error: ${response.statusCode}')];
        });
      }
    } catch (e) {
      setState(() {
        _responseWidgets = [Text('Error: $e')];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title:  Text('License Generator'),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  const Text('Select Option:'),
                  const SizedBox(width: 10),
                  ComboBox<String>(
                    value: _selectedOption,
                    placeholder: const Text('Select an option'),
                    items: _optionsMap.entries.map((entry) {
                      return ComboBoxItem<String>(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedOption = newValue),
                  ),
                  const SizedBox(width: 10),
                  const Text('Number of libraries:'),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 55, maxWidth: 100),
                    child: TextBox(
                      controller: _numberOfLibrariesController,
                      keyboardType: TextInputType.number,
                      
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue1,
                    content: const Text('Obfuscate History'),
                    onChanged: (value) => setState(() => _checkboxValue1 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue2,
                    content: const Text('Authority'),
                    onChanged: (value) => setState(() => _checkboxValue2 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue3,
                    content: const Text('Acquisitions'),
                    onChanged: (value) => setState(() => _checkboxValue3 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue4,
                    content: const Text('Serials'),
                    onChanged: (value) => setState(() => _checkboxValue4 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue5,
                    content: const Text('Self Check Station'),
                    onChanged: (value) => setState(() => _checkboxValue5 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  const SizedBox(width: 10),
                  const Text('Federated Searching (SURFit):'),
                  const SizedBox(width: 10),
                  ComboBox<String>(
                    value: _selectedFed,
                    items: _fedMap.entries.map((entry) {
                      return ComboBoxItem<String>(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedFed = newValue),
                  ),
                  const SizedBox(width: 10),
                  const Text('Expiration Date (SURFit):'),
                  const SizedBox(width: 10),
                  ComboBox<String>(
                    value: _selectedFedExpDate,
                    items: _fedExpMap.entries.map((entry) {
                      return ComboBoxItem<String>(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedFedExpDate = newValue),
                  ),
                  const SizedBox(width: 10),
                  const Text('Number of Resolvers:'),
                  const SizedBox(width: 10),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 55, maxWidth: 100),
                      child: TextBox(
                        controller: _numberOfResolversController,
                        keyboardType: TextInputType.number,
                        
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  

                ],
              ),
              const SizedBox(height: 10),
              Row(
                children:[
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  const SizedBox(width: 10),
                  const Text('State Standards (SS):'),
                  const SizedBox(width: 10),
                  ComboBox<String>(
                    value: _selectedStateStandards,
                    items: _selectedStateStandardsMap.entries.map((entry) {
                      return ComboBoxItem<String>(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedStateStandards = newValue),
                  ),
                  const SizedBox(width: 10),
                  const Text('Expiration Date (SS):'),
                  const SizedBox(width: 10),
                  ComboBox<String>(
                    value: _selectedStateStandardsExpDate,
                    items: _selectedStateStandardsExpDateMap.entries.map((entry) {
                      return ComboBoxItem<String>(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedStateStandardsExpDate = newValue),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                ]
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue6,
                    content: const Text('SIF'),
                    onChanged: (value) => setState(() => _checkboxValue6 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue7,
                    content: const Text('Atriuum Debt'),
                    onChanged: (value) => setState(() => _checkboxValue7 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue8,
                    content: const Text('RBS'),
                    onChanged: (value) => setState(() => _checkboxValue8 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue9,
                    content: const Text('ILL'),
                    onChanged: (value) => setState(() => _checkboxValue9 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue10,
                    content: const Text('Kiosk'),
                    onChanged: (value) => setState(() => _checkboxValue10 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                  Checkbox(
                    checked: _checkboxValue11,
                    content: const Text('PowerSchool'),
                    onChanged: (value) => setState(() => _checkboxValue11 = value!),
                  ),
                  Container(
                    width: 3,
                    height: 30, // Adjust height as needed
                    color: FluentTheme.of(context).inactiveColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Button(
                  onPressed: _sendPayload,
                  child: const Text('Generate'),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _responseWidgets,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
