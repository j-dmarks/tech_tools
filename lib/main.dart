import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:msix/msix.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'password_provider.dart';// Import the PassWord page
import 'package:updat/updat_window_manager.dart';
import 'theme_provider.dart';// Import the ThemeProvider class
import 'checksum.dart';
import 'pass_word.dart'; 
import 'global_hotkey_manager.dart';
import 'sip2.dart';
import 'ncip.dart';
import 'license_gen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PasswordProvider()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Tech Support Tools',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(color: Colors.lightBlue),
        
      ),
      
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 44, 43, 43),
        appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 22, 22, 22)),
      ),
      themeMode: themeProvider.themeMode,
      home: const HomePage(),
      builder: (context, child) {
        GlobalHotkeyManager().registerHotkeys(() {
          Provider.of<PasswordProvider>(context, listen: false)
              .copyToClipboard(context);
          
        });
        return child ?? const SizedBox.shrink();
      }
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _appVersion = '';
  int _selectedPageIndex = 0;

  final List<Widget> _pages = [
      const PasswordFetcherScreen(),
      const Mod10CheckDigitScreen(),
      const SIP2TestPage(),
      const SendPostXML(),
      const LicenseGen(),
           
  ];

  final List<String> _pageTitles = [
        "Password Fetcher",
        "Mod 10 Checksum",
        "Sip2 Tester",
        "NCIP Tester",
        "License Generator",
        
        
      ];
  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer after selecting a page
  }

  @override
  Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  return Scaffold(
    key: _scaffoldKey,
    appBar: AppBar(
      title: const Text('Tech Support Tools'),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [        
        IconButton(
          icon: Icon(themeProvider.themeMode == ThemeMode.light
              ? Icons.dark_mode
              : Icons.light_mode),
          onPressed: () => themeProvider.toggleTheme(),
        ),
      ],
    ),
    drawer: Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _pageTitles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_pageTitles[index]),
                  onTap: () => _selectPage(index),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Version: $_appVersion'),
          ),
        ],
      ),
    ),
    body: _pages[_selectedPageIndex],
  );
}
}