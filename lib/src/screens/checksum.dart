import 'package:fluent_ui/fluent_ui.dart';

class Mod10CheckDigitScreen extends StatefulWidget {
  const Mod10CheckDigitScreen({super.key});

  @override
  Mod10CheckDigitScreenState createState() => Mod10CheckDigitScreenState();
}

class Mod10CheckDigitScreenState extends State<Mod10CheckDigitScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = "";
  String _check = "";

  /// Function to calculate mod 10 check digit
  int calculateCheckDigit(String input) {
    List<int> digits = input.split('').map(int.parse).toList();
    int sum = 0;
    bool doubleIt = true;

    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = digits[i];
      if (doubleIt) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      doubleIt = !doubleIt;
    }

    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit;
  }

  void _calculate() {
    String input = _controller.text.trim();
    if (input.isNotEmpty && RegExp(r'^\d+$').hasMatch(input)) {
      int checkDigit = calculateCheckDigit(input);
      setState(() {
        _result = "Check Digit: $checkDigit";
        _check = "Full Barcode:$input$checkDigit";
      });
    } else {
      setState(() {
        _result = "Invalid input. Please enter digits only.";
        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('Mod 10 Check Digit Calculator')),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextBox(
              controller: _controller,
              keyboardType: TextInputType.number,
              placeholder: 'Enter a number',
              onSubmitted: (value) => _calculate(),
            ),
            const SizedBox(height: 20),
            Button(
              onPressed: _calculate,
              child: const Text('Calculate Check Digit'),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              style: FluentTheme.of(context).typography.body?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                SelectableText( _check,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
