import'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:tech_tools/src/providers/index.dart';
import 'package:tech_tools/src/utils/index.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _settingsScreenState createState() => _settingsScreenState();
}
class _settingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
   

    return ScaffoldPage(
      content: 
      Row(
        children: [
          SizedBox(width: 20),
          Align(
            alignment: Alignment.topLeft,
            child: Button(
            child: Text('Show Light Theme Color Picker'),
            onPressed: () => _showColorPicker(context),)
          ),
        ],
      ),
    );
  }
}

void _showColorPicker(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => ColorPickerWidget(
      initialColor: Provider.of<ColorProvider>(context, listen: false).selectedColor, // Set initial color
      onColorChanged: (color) {
        Provider.of<ColorProvider>(context, listen: false).updateColor(color); // Handle color change
      },
    ),
  );
}






