import 'dart:io';
import 'package:flutter/material.dart';

class SIP2TestPage extends StatefulWidget {
  const SIP2TestPage({super.key});

  @override
  SIP2TestPageState createState() => SIP2TestPageState();
}

class SIP2TestPageState extends State<SIP2TestPage> {
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationCodeController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();

  String generateTimestamp() {
    DateTime now = DateTime.now();
    String year = now.year.toString(); 
    String month = now.month.toString().padLeft(2, '0');
    String day = now.day.toString().padLeft(2, '0');
    String hour = now.hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');
    String second = now.second.toString().padLeft(2, '0');
    return '$year$month$day$hour$minute$second';
  }

  Socket? _socket;
  bool _isConnecting = false;
  String _selectedTemplate = 'Patron Status';

  late Map<String, List<Widget>> _templateFields;

  @override
  void initState() {
    super.initState();
    _templateFields = {
      'Patron Status': [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('barcode'),
                controller: _barcodeController,
                decoration: const InputDecoration(labelText: 'Barcode'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                key: const ValueKey('pin'),
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'Patron Pin (If Required)'),
              ),
            ),
          ],
        ),
      ],
    };
  }

  @override
  void dispose() {
    _serverController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _locationCodeController.dispose();
    _barcodeController.dispose();
    _pinController.dispose();
    _responseController.dispose();
    _socket?.destroy();
    super.dispose();
  }

  Future<void> _connectToServer() async {
    String server = _serverController.text.trim();
    int port = int.tryParse(_portController.text) ?? 0;

    if (server.isEmpty || port == 0) {
      _updateResponse('Error: Please provide a valid server and port.');
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      _socket = await Socket.connect(server, port, timeout: const Duration(seconds: 5));
      _socket!.listen(
        (data) {
          String response = String.fromCharCodes(data);
          _updateResponse('<<<$response');
        },
        onError: (error) {
          _updateResponse('Connection Error: $error');
          _socket?.destroy();
          _socket = null;
        },
        onDone: () {
          _updateResponse('Connection closed by server.');
          _socket = null;
        },
        cancelOnError: true,
      );
      _updateResponse('\nConnected to $server:$port.');
    } catch (e) {
      _updateResponse('Error: $e');
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _login() async {
    if (_socket == null) {
      _updateResponse('Error: Not connected to the server.');
      return;
    }
    String loginMessage = _buildLoginMessage();
    try {
      _socket!.write('$loginMessage\r');
      _updateResponse('\n>>>$loginMessage\n');
    } catch (e) {
      _updateResponse('Error sending login message: $e');
    }
  }

  String _buildLoginMessage() {
    return '9300CN${_usernameController.text}|CO${_passwordController.text}|CP${_locationCodeController.text}|';
  }

  Future<void> _sendMessage() async {
    if (_socket == null) {
      _updateResponse('Error: Not connected to the server.');
      return;
    }
    String message = _buildMessage();
    try {
      _socket!.write('$message\r');
      _updateResponse('\n>>>$message');
    } catch (e) {
      _updateResponse('Error sending message: $e');
    }
  }

  String _buildMessage() {
    switch (_selectedTemplate) {
      case 'Patron Status':
        return '23001    ${generateTimestamp()}AO|AA${_barcodeController.text}|AC|AD${_pinController.text}|';
      case 'Receive Holds':
        return '9700CN${_usernameController.text}|CO${_passwordController.text}|';
      case 'Item Checkout':
        return '9900CN${_usernameController.text}|CO${_passwordController.text}|';
      default:
        return '';
    }
  }

  void _updateResponse(String response) {
    
    final Map<int, String> positionMeanings = {
      1: "Charge Privileges Denied",
      2: "Renewal Privileges Denied",
      3: "Recall Privileges Denied",
      4: "Hold Privileges Denied",
      5: "Card Reported Lost",
      6: "Too Many Items Charged",
      7: "Too Many Items Overdue",
      8: "Too Many Renewals",
      9: "Too Many Claims of Items Returned",
      10: "Too Many Items Lost",
      11: "Excessive Outstanding Fines",
      12: "Excessive Outstanding Fees",
      13: "Recall Overdue",
      14: "Too Many Items Billed",
    };

    final pattern = RegExp(r'24(.+?)AA');
    final match = pattern.firstMatch(response);
    if (match != null) {
      _responseController.text += "$response";
      final extractedData = match.group(1)?.trim();
      if (extractedData != null) {
        String parsedInfo = "\n";
        for (int position in positionMeanings.keys) {
          if (position - 1 < extractedData.length && extractedData[position - 1] == 'Y') {
            parsedInfo += "Block ${position - 1}: ${positionMeanings[position]}\n";
          }
        }
        setState(() {
          _responseController.text += "$parsedInfo";
        });
      }
    } else {
      setState(() {
        _responseController.text += " $response";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SIP2 Testing Tool')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _serverController,
                      decoration: const InputDecoration(
                        labelText: 'Server Address',
                        hintText: 'e.g., 192.168.1.1',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),          
                    
                  
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        labelText: 'Port Number',
                        hintText: 'e.g., 6000',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _isConnecting ? null : _connectToServer,
                  child: Text(_isConnecting ? 'Connecting...' : 'Connect'),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _locationCodeController,
                      decoration: const InputDecoration(labelText: 'Location Code'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ),

              const Text('Message Template (If needed I will add more templates.)', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedTemplate,
                      onChanged: (value) {
                        setState(() {
                          _selectedTemplate = value!;
                        });
                      },
                      items: _templateFields.keys
                          .map((template) => DropdownMenuItem(
                                value: template,
                                child: Text(template),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dynamic Fields
              ...?_templateFields[_selectedTemplate],

              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Send Message'),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _responseController,
                readOnly: true,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Response',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
