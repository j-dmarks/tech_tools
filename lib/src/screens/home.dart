import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../utils/window_buttons.dart';
import 'package:tech_tools/src/screens/index.dart';
import 'package:window_manager/window_manager.dart';
import 'package:updat/updat.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:updat/theme/chips/flat.dart';
import '../sip2/screens/tabview.dart';


const String currentVersion = "2.1.2";
const String appTitle = 'Tech Tools';
Future<void> _updateAcrylicEffect(ThemeMode themeMode) async {
  if (themeMode == ThemeMode.dark) {
    await flutter_acrylic.Window.setEffect(
      effect: flutter_acrylic.WindowEffect.transparent,
      
    );
  } else {
    await flutter_acrylic.Window.setEffect(
      effect: flutter_acrylic.WindowEffect.transparent,
      
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int topIndex = 0;
  PaneDisplayMode displayMode = PaneDisplayMode.open;
  List<NavigationPaneItem> items = [
    PaneItem(
      icon: const Icon(FluentIcons.password_field),
      title: const Text('Password Fetcher'),
      body: const PasswordFetcherScreen(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.folder),
      title: const Text('Calculate Mod10 Check Digit'),
      body: const Mod10CheckDigitScreen(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.server_enviroment),
      title: const Text('SIP2 Tester'),
      body:  TabbedPage(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.server_processes),
      title: const Text('NCIP Tester'),
      body: const SendPostXML(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.italic_l),
      title: const Text('License Generator'),
      body: const LicenseGen(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.s_q_l_server_logo),
      title: const Text('SQL Commands'),
      body: const CommandListPage(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.code),
      title: const Text("Librista Sites"),
      body: const LibCheckScreen()
    )
  ];

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return navView(themeProvider);
  }

  NavigationView navView(ThemeProvider themeProvider) {
    return NavigationView(
    appBar: NavigationAppBar(
      automaticallyImplyLeading: false,
      leading: UpdatWidget(
            currentVersion: "2.1.1",
            getLatestVersion: () async {
              final data = await http.get(Uri.parse("https://api.github.com/repos/j-dmarks/tech_tools/releases/latest"));
              return jsonDecode(data.body)['tag_name'];
            },
            getBinaryUrl: (latestVersion) async {
              return "https://github.com/j-dmarks/tech_tools/releases/latest/download/tech_tools_setup.exe";
            },
            getChangelog: (_, __) async {
   // That same latest endpoint gives us access to a markdown-flavored release body. Perfect!
            final data = await http.get(Uri.parse(
                "https://api.github.com/repos/j-dmarks/tech_tools/releases/latest",
            ));
            return jsonDecode(data.body)["body"];
          },  // This is the changelog
            appName: "tech_tools",
            updateChipBuilder: flatChip,
          ),
      title: const DragToMoveArea(
        child: Align(
          alignment: AlignmentDirectional.center,
          child: Text(appTitle),
        ),
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ToggleSwitch(
                checked: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                  _updateAcrylicEffect(themeProvider.themeMode);
                },
                content: Text(
                  themeProvider.themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
                ),
              ),
            ),
          ),
          const WindowButtons(),
        ],
      ),
    ),
    pane: NavigationPane(
      selected: topIndex,
      onChanged: (index) => setState(() => topIndex = index),
      displayMode: PaneDisplayMode.compact,
      items: items,
      footerItems: [
        PaneItem(
          icon: const Icon(FluentIcons.settings),
          title: const Text('Settings'),
          body: const SettingsScreen(),
        ),
         PaneItemSeparator(),
         PaneItemHeader(header: const Text('Version: $currentVersion')),
      ],
    ),
  );
  }

} 