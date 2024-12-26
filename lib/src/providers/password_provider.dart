import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordProvider extends ChangeNotifier {
  String _password = '';

  String get password => _password;

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void copyToClipboard(BuildContext context) {
    if (_password.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _password));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password copied to clipboard!')),
      );
    }
  }
}