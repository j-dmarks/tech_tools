import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:tech_tools/src/screens/index.dart';
import 'src/providers/index.dart';
import 'src/utils/index.dart';
const String appTitle = 'Tech Tools';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await flutter_acrylic.Window.initialize();
  await flutter_acrylic.Window.hideWindowControls();
  await WindowManager.instance.ensureInitialized();
  await windowManager.setTitleBarStyle(
    TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PasswordProvider()),
        ChangeNotifierProvider(create: (_) => ColorProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Register global hotkeys
    Future.delayed(Duration.zero, () {
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      GlobalHotkeyManager().registerHotkeys(() {
        passwordProvider.copyToClipboard(context);
      });
      GlobalHotkeyManager().registerbsi(() {
        passwordProvider.copyToClipboardBSI(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorProvider = Provider.of<ColorProvider>(context);
    final selectedColor = themeProvider.themeMode == ThemeMode.dark
      ? darken(colorProvider.selectedColor, 0.3) // Darken in dark mode
      : colorProvider.selectedColor;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        _updateAcrylicEffect(themeProvider.themeMode); // Ensure window effect updates

        return FluentApp(
          debugShowCheckedModeBanner: false,
          title: appTitle,
          themeMode: themeProvider.themeMode,
          theme: FluentThemeData(
            brightness: Brightness.light,
            accentColor: Colors.green,
            
            scaffoldBackgroundColor: const Color.fromARGB(255, 243, 242, 241),
            navigationPaneTheme: NavigationPaneThemeData(
              
              backgroundColor: selectedColor,
              highlightColor: const Color.fromARGB(255, 255, 153, 0),
              
            ),
          ),
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.blue,
            scaffoldBackgroundColor: const Color.fromARGB(255, 41, 40, 40),
            navigationPaneTheme:  NavigationPaneThemeData(
              backgroundColor: Colors.black,
            ),
          ),
          home:  MyHomePage(),
        );
      },
    );
  }
}

Future<void> _updateAcrylicEffect(ThemeMode themeMode) async {
  if (themeMode == ThemeMode.dark) {
    await flutter_acrylic.Window.setEffect(
      effect: flutter_acrylic.WindowEffect.acrylic,
      dark: true,
      
    );
  } else {
    await flutter_acrylic.Window.setEffect(
      effect: flutter_acrylic.WindowEffect.acrylic,

      
    );
  }
}
  Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
