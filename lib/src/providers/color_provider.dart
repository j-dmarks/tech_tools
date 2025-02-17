import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorProvider extends ChangeNotifier {
  Color _selectedColor = Color.fromARGB(155, 98, 83, 233);
  Color get selectedColor => _selectedColor;
  ColorProvider(){
    _loadColor();
  }
  void updateColor(Color color){
    _selectedColor = color;
    _saveColor();
    notifyListeners();
  }


  Future<void> _loadColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? color = prefs.getInt('color');
    if (color != null) {
      _selectedColor = Color(color);
    }
    notifyListeners();
  }

  Future<void> _saveColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('color', _selectedColor.value);
    notifyListeners();
  }
}