import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/preferences_helper.dart';
import 'package:intl/date_symbol_data_local.dart';

// Theme Provider untuk state management yang lebih baik
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDark = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  // Load data secara parallel untuk mempercepat loading
  final futures = await Future.wait([
    PreferencesHelper.getLoginStatus(),
    SharedPreferences.getInstance(),
  ]);
  
  final isLoggedIn = futures[0] as bool;
  final prefs = futures[1] as SharedPreferences;
  final isDark = prefs.getBool('isDarkMode') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn, initialDarkMode: isDark));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool initialDarkMode;

  const MyApp({required this.isLoggedIn, required this.initialDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeProvider _themeProvider;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    // Set initial theme dan hilangkan loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _themeProvider._isDark = widget.initialDarkMode;
      _themeProvider.notifyListeners();
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.teal,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 24),
                Text(
                  "SmartBuy",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => _themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SmartBuy',
            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: false,
              brightness: Brightness.light,
              primarySwatch: Colors.teal,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: Colors.grey[100],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: false,
              brightness: Brightness.dark,
              primarySwatch: Colors.teal,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: Colors.grey[900],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            home: widget.isLoggedIn
                ? HomeScreen(
                    isDarkMode: themeProvider.isDark,
                    onThemeChanged: themeProvider.toggleTheme,
                  )
                : LoginScreen(),
          );
        },
      ),
    );
  }
}
