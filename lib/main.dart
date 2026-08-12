import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:product_tracker/database/app_database.dart';
import 'package:product_tracker/database/sample_data_seeder.dart';
import 'package:product_tracker/screens/dashboard_screen.dart';
import 'package:product_tracker/screens/production_list_screen.dart';
import 'package:product_tracker/screens/quality_check_screen.dart';
import 'package:product_tracker/screens/reports_screen.dart';
import 'package:product_tracker/screens/master_data_screen.dart';
import 'package:product_tracker/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  String? initError;
  try {
    final db = await AppDatabase.database;
    await SampleDataSeeder.seed(db);
    debugPrint('Database initialized and seeded successfully');
  } catch (e, stackTrace) {
    debugPrint('Database initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    initError = e.toString();
  }

  runApp(MyApp(initError: initError));
}

class MyApp extends StatefulWidget {
  final String? initError;
  const MyApp({super.key, this.initError});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.dark);

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (_, currentMode, _) {
        return MaterialApp(
          title: 'Production Tracker',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1),
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1),
              brightness: Brightness.dark,
            ),
          ),
          home: widget.initError != null
              ? _ErrorScreen(error: widget.initError!)
              : MainScreen(themeNotifier: _themeNotifier),
        );
      },
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initialization Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to initialize database',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const MainScreen({super.key, required this.themeNotifier});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductionListScreen(),
    const QualityCheckScreen(),
    const ReportsScreen(),
    const MasterDataScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen(themeNotifier: widget.themeNotifier)),
              );
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.factory), label: 'Production'),
          NavigationDestination(icon: Icon(Icons.verified), label: 'Quality'),
          NavigationDestination(icon: Icon(Icons.assessment), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.storage), label: 'Master Data'),
        ],
      ),
    );
  }
}
