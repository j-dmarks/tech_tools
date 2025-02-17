import 'package:fluent_ui/fluent_ui.dart';

class ColorPickerWidget extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerWidget({
    Key? key,
    required this.initialColor,
    required this.onColorChanged,
  }) : super(key: key);


  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late int alpha;
  late int red;
  late int green;
  late int blue;

  final List<Color> colorPalette = [
    Colors.red, Colors.green, Colors.blue, Colors.orange,
    Colors.purple, Colors.yellow, Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    alpha = widget.initialColor.alpha;
    red = widget.initialColor.red;
    green = widget.initialColor.green;
    blue = widget.initialColor.blue;
  }

  void _updateColor() {
    final newColor = Color.fromARGB(alpha, red, green, blue);
    widget.onColorChanged(newColor);
    setState(() {}); // Update UI
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Pick a Color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color Preview
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Color.fromARGB(alpha, red, green, blue),
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 10),

          // Color Palette
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colorPalette.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    alpha = color.alpha;
                    red = color.red;
                    green = color.green;
                    blue = color.blue;
                    _updateColor();
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color.fromARGB(alpha, red, green, blue) == color
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // ARGB Controls (Sliders + Input Fields)
          _buildColorControl('Alpha', alpha, (value) => alpha = value),
          _buildColorControl('Red', red, (value) => red = value),
          _buildColorControl('Green', green, (value) => green = value),
          _buildColorControl('Blue', blue, (value) => blue = value),
        ],
      ),
      actions: [
        Button(
          child: const Text('Close'),
          onPressed: ()=> Navigator.pop(context),
        ),
      ],      
    );
  }

  Widget _buildColorControl(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        // Label
        SizedBox(width: 50, child: Text('$label:')),

        // Text Input Field
        SizedBox(
          width: 50,
          child: TextBox(
            controller: TextEditingController(text: value.toString()),
            onSubmitted: (val) {
              int newValue = int.tryParse(val) ?? value;
              if (newValue < 0) newValue = 0;
              if (newValue > 255) newValue = 255;
              onChanged(newValue);
              _updateColor();
            },
          ),
        ),

        const SizedBox(width: 10),

        // Slider
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            onChanged: (val) {
              onChanged(val.toInt());
              _updateColor();
            },
          ),
        ),
      ],
    );
  }
}