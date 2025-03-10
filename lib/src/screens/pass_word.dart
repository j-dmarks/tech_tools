import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:cron/cron.dart';
import 'package:flutter/services.dart';

class PasswordFetcherScreen extends StatefulWidget {
  const PasswordFetcherScreen({super.key});

  @override
  PasswordFetcherScreenState createState() => PasswordFetcherScreenState();
}

class PasswordFetcherScreenState extends State<PasswordFetcherScreen> {
  String _h3Text = "Fetching passwords...";
  bool _isLoading = true;
  final Cron _cron = Cron();
  List<Map<String, String>> passwordEntries = []; // Stores {date, password}
  late TextEditingController prevPassController;

  @override
  void initState() {
    super.initState();
    prevPassController = TextEditingController();
    _scheduleDailyFetch();
    _fetchPasswords();
  }

  void _scheduleDailyFetch() {
    _cron.schedule(Schedule.parse('0 5 * * *'), () async {
      await _fetchPasswords();
    });
  }

  @override
  void dispose() {
    prevPassController.dispose();
    _cron.close();
    super.dispose();
  }

  Future<void> _fetchPasswords() async {
    final url = Uri.parse('http://spotd/');
    final session = http.Client();

    try {
      final response = await session.get(url);
      if (response.statusCode == 200) {
        var document = parse(response.body);
        var h3Element = document.querySelector('h3');
        var preElements = document.querySelectorAll('pre');

        if (preElements.length < 2) {
          setState(() {
            _h3Text = 'Required elements not found!';
            _isLoading = false;
          });
          return;
        }

        String prevPass = preElements[1].text.trim();
        passwordEntries = _extractPasswords(prevPass);

        String password = preElements[0].text.trim();
        Provider.of<PasswordProvider>(context, listen: false)
            .setPassword(password);

        setState(() {
          _h3Text = h3Element != null ? '${h3Element.text} $password' : 'Required elements not found!';
          _isLoading = false;
        });
      } else {
        setState(() {
          _h3Text = 'Failed to fetch the page!';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _h3Text = 'An error occurred: $e';
        _isLoading = false;
      });
    } finally {
      session.close();
    }
  }

  List<Map<String, String>> _extractPasswords(String preText) {
    List<String> lines = preText.split('\n').where((line) => line.isNotEmpty).toList();
    List<Map<String, String>> extractedPasswords = [];

    for (var line in lines) {
      List<String> words = line.split(" ");
      if (words.length > 4) {
        String firstFourWords = words.sublist(0, 4).join(" "); // Get first four words
        String password = words.last; // Get last word (password)

        extractedPasswords.add({
          'date': firstFourWords,
          'password': password,
        });
      }
    }
    return extractedPasswords;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Password Fetcher'),
      ),
      content: Center(
        child: _isLoading
            ? const ProgressRing()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _h3Text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Button(
                      onPressed: () {
                        Provider.of<PasswordProvider>(context, listen: false)
                            .copyToClipboard(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            FluentTheme.of(context).navigationPaneTheme.backgroundColor),
                      ),
                      child: const Text('Copy Password'),
                    ),
                    const SizedBox(height: 10),
                    Button(
                      onPressed: () {
                        Provider.of<PasswordProvider>(context, listen: false)
                            .copyToClipboardBSI(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            FluentTheme.of(context).navigationPaneTheme.backgroundColor),
                      ),
                      child: const Text('Copy BSI Password'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Press Ctrl + Q to copy the server password\nPress Alt + B to copy the BSI password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: passwordEntries.length,
                        itemBuilder: (context, index) {
                          var reversedList = passwordEntries.reversed.toList();
                          return ListTile(
                            title: Text(
                              reversedList[index]['date']!,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              reversedList[index]['password']!,
                              style:  TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                            trailing: Button(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: passwordEntries[index]['password']!));
                                },
                                child: Text('Copy'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
