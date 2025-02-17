import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:cron/cron.dart';

class PasswordFetcherScreen extends StatefulWidget {
  const PasswordFetcherScreen({super.key});

  @override
  PasswordFetcherScreenState createState() => PasswordFetcherScreenState();
}

class PasswordFetcherScreenState extends State<PasswordFetcherScreen> {
  String _h3Text = "Fetching password...";
  bool _isLoading = true;
  final Cron _cron = Cron();

  @override
  void initState() {
    super.initState();
    _scheduleDailyFetch();
    _fetchPassword();
  }

  void _scheduleDailyFetch() {
    _cron.schedule(Schedule.parse('0 5 * * *'), () async {
      await _fetchPassword();
    });
  }

  @override
  void dispose() {
    _cron.close();
    super.dispose();
  }

  Future<void> _fetchPassword() async {
    final url = Uri.parse('http://spotd/');
    final session = http.Client();

    try {
      final response = await session.get(url);

      if (response.statusCode == 200) {
        var document = parse(response.body);
        var h3Element = document.querySelector('h3');
        var preElement = document.querySelector('pre');

        if (h3Element != null && preElement != null) {
          String password = preElement.text;
          Provider.of<PasswordProvider>(context, listen: false)
              .setPassword(password);

          setState(() {
            _h3Text = '${h3Element.text} $password';
            _isLoading = false;
          });
        } else {
          setState(() {
            _h3Text = 'Required elements not found!';
            _isLoading = false;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title:  Text('Password Fetcher'),
        
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
                        backgroundColor: WidgetStateProperty.all(FluentTheme.of(context).navigationPaneTheme.backgroundColor),
                      ),
                      child: const Text('Copy Password'),
                    ),
                    const SizedBox(height: 10),
                    Button(
                      onPressed: (){
                        Provider.of<PasswordProvider>(context, listen: false)
                            .copyToClipboardBSI(context);
                            }, 
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(FluentTheme.of(context).navigationPaneTheme.backgroundColor),
                      ),
                            child: const Text('Copy BSI Password'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Press Ctrl + Q to copy the server password\n Press Alt + B to copy the BSI password',
                      style: TextStyle(                        
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
