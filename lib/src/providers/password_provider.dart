
import 'package:flutter/services.dart';
import 'package:tech_tools/src/providers/bsipass.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PasswordProvider extends ChangeNotifier {
  String _password = '';
  final String _bsipassword = bsipass;

  String get password => _password;

  void setPassword(String password) {
    _password = password;
    
    notifyListeners();
  }

  void copyToClipboard(BuildContext context) {
    if (_password.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _password));
      
    }
  }
  void copyToClipboardBSI(BuildContext context) {
    if (_bsipassword.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _bsipassword));
      
    }
  }
}