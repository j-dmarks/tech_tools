import 'package:fluent_ui/fluent_ui.dart';
import '../utils/globals.dart';
import '../utils/sip2_connection.dart';
import '../utils/sip2_message_builder.dart';
import '../utils/sip2_response_parser.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final decoration = BoxDecoration(
    border: Border.all(),
    borderRadius: BorderRadius.circular(0),
  );

  bool isLoading = false; // Loading indicator state

  @override
  void initState() {
    super.initState();
  }

  void _showLoading(bool state) {
    setState(() {
      isLoading = state;
    });
  }

  Future<void> _connectToServer() async {
    _showLoading(true);
    try {
      socket = await connectToServer(
        serverController.text.trim(),
        int.tryParse(portController.text) ?? 0,
        (response) => setState(() => responseController.text += '<--$response' + parseResponse(response)),
      );
    } catch (e) {
      setState(() => responseController.text += 'Connection failed: $e\n');
    }
    _showLoading(false);
  }

  Future<void> _login() async {
    if (socket == null) {
      setState(() => responseController.text += 'Error: Not connected to the server.\n');
      return;
    }
    _showLoading(true);
    sendMessage(socket!, buildLoginMessage(usernameController.text, passwordController.text, locationCodeController.text),
        (response) => setState(() => responseController.text += response));
    _showLoading(false);
  }

Future<void> _sendMessage(String selectedTemplate) async {
  if (socket == null) {
    setState(() => responseController.text += 'Error: Not connected to the server.\n');
    return;
  }
  _showLoading(true);
  String message = buildMessage(
    selectedTemplate,
    barcodeController.text,
    pinController.text,
    usernameController.text,
    passwordController.text,
    itemBarcodeController.text,
  );

  sendMessage(socket!, message, (response) {
    setState(() => responseController.text += response);
  });

  _showLoading(false);
}



  Widget _buildInputSection(String title, List<Widget> fields) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          ...fields,
        ],
      ),
    );
  }

  Widget _buildButtonSection(List<Widget> buttons) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 2), borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(5),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: buttons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildInputSection('Patron Information', [
            TextBox(controller: barcodeController, decoration: decoration, placeholder: 'Patron Barcode',),
            const SizedBox(height: 5),
            TextBox(controller: pinController, decoration: decoration, placeholder: 'Patron PIN (if required)',),
          ]),
          const SizedBox(height: 10),
          _buildInputSection('Item Information', [
            TextBox(controller: itemBarcodeController, decoration: decoration, placeholder: 'Item Barcode',),
          ]),
          const SizedBox(height: 10),
          _buildButtonSection([
            FilledButton(onPressed: _connectToServer, child: const Text('Connect')),
            FilledButton(onPressed: _login, child: const Text('Login')),
          ]),
          const SizedBox(height: 10),
          _buildButtonSection([
            FilledButton(onPressed: () => _sendMessage('Patron Status'), child: const Text('Patron Status')),
            FilledButton(onPressed: () => _sendMessage('Patron Information'), child: const Text('Patron Information')),
          ]),
          const SizedBox(height: 10),
          _buildButtonSection([
            FilledButton(onPressed: () => _sendMessage('Item Information'), child: const Text('Item Information')),
            FilledButton(onPressed: () => _sendMessage('Item Checkout'), child: const Text('Item Checkout')),
            FilledButton(onPressed: () => _sendMessage('Item Checkin'), child: const Text('Item Checkin')),
            FilledButton(onPressed: () => _sendMessage('Renew Item'), child: const Text('Renew Item')),
            FilledButton(onPressed: () => _sendMessage('Renew All Items'), child: const Text('Renew All Items')),
            FilledButton(onPressed: responseController.clear, child: const Text('clear'))
          ]),
          const SizedBox(height: 10),
          if (isLoading) const ProgressRing(), // Show loader when loading
          const SizedBox(height: 10),
          TextBox(
            controller: responseController,
            readOnly: true,
            minLines: 8,
            maxLines: 20,
            decoration: decoration.copyWith(
              border: Border.all(),
            ),
          ),
        ],
      ),
    );
  }
}
