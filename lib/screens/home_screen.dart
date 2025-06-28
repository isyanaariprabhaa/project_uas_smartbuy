import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wishlist_screen.dart';
import 'statistik_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'riwayat_screen.dart';
import 'tips_screen.dart';
import '../utils/preferences_helper.dart';
import '../main.dart'; // Import untuk ThemeProvider
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final bool isDarkMode;

  const HomeScreen({Key? key, this.onThemeChanged, this.isDarkMode = false})
    : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String email = '';
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      WishlistScreen(),
      StatistikScreen(),
      RiwayatScreen(),
      TipsScreen(),
      const Center(child: CircularProgressIndicator()),
    ];
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('email') ?? 'user@example.com';

    if (mounted) {
      setState(() {
        email = userEmail;
        _pages[4] = ProfileScreen(
          key: ValueKey('profile'),
          onLogout: _logout,
          email: email,
          onThemeChanged: widget.onThemeChanged,
          isDarkMode: widget.isDarkMode,
        );
      });
    }
  }

  void _logout() async {
    await PreferencesHelper.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;
        
        return Scaffold(
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: isSmallScreen ? BottomNavigationBarType.fixed : BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: TextStyle(fontSize: isSmallScreen ? 10 : 12),
            unselectedLabelStyle: TextStyle(fontSize: isSmallScreen ? 10 : 12),
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.list, size: isSmallScreen ? 20 : 24),
                label: 'Wishlist',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart, size: isSmallScreen ? 20 : 24),
                label: 'Statistik',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history, size: isSmallScreen ? 20 : 24),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb, size: isSmallScreen ? 20 : 24),
                label: 'Tips',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: isSmallScreen ? 20 : 24),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
