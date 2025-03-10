import "package:fluent_ui/fluent_ui.dart";
import 'home_page.dart';
import 'servers_page.dart';
import 'settings_page.dart';

int currentIndex = 0;
List<Tab> tabs = [
   Tab(text: Text('Home'), body: HomePage()),
   Tab(text: Text('Settings'), body: SettingsPage()),
   Tab(text: Text('Servers'), body: ServersPage()),
];

/// Creates a tab for the given index
class TabbedPage extends StatefulWidget {
  @override
  _TabbedPageState createState() => _TabbedPageState();
}

class _TabbedPageState extends State<TabbedPage> {
  @override
  Widget build(BuildContext context) {
	return TabView(
    currentIndex: currentIndex, 
    tabs: tabs,
    onChanged:(index)=> setState(() => currentIndex = index) ,
    closeButtonVisibility: CloseButtonVisibilityMode.never,
    tabWidthBehavior: TabWidthBehavior.sizeToContent,

    );
  }
}