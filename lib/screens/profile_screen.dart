import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/preferences_helper.dart';
import '../db/database_helper.dart';
import '../models/item_belanja.dart';
import '../main.dart'; // Import untuk ThemeProvider
import 'login_screen.dart';
import 'package:intl/intl.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'help_screen.dart';
import '../utils/notification_helper.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  final bool isDarkMode;
  final Function(bool)? onThemeChanged;
  final VoidCallback onLogout;

  const ProfileScreen({
    required this.email,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLogout,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ItemBelanja> userItems = [];
  bool isLoadingStats = true;
  String userName = '';

  @override
  void initState() {
    super.initState();
    loadUserStats();
    loadUserName();
  }

  Future<void> loadUserStats() async {
    try {
      final data = await DatabaseHelper.instance.getAllItems();
      setState(() {
        userItems = data;
        isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        isLoadingStats = false;
      });
    }
  }

  Future<void> loadUserName() async {
    final name = await PreferencesHelper.getUserName();
    setState(() => userName = name);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final currentDarkMode = themeProvider.isDark;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Profil"),
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(Icons.edit_rounded),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(initialName: userName),
                    ),
                  );
                  if (result == true) loadUserName();
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: loadUserStats,
            color: theme.primaryColor,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: Column(
                children: [
                  // Profile Header dengan Gradient
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: isSmallScreen ? 40 : 48,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        // User Info
                        Text(
                          userName.isNotEmpty ? userName : widget.email,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                        ),
                        if (userName.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              widget.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                fontSize: isSmallScreen ? 12 : 13,
                              ),
                            ),
                          ),
                        SizedBox(height: 8),
                        
                        // Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                currentDarkMode ? Icons.dark_mode : Icons.light_mode,
                                size: isSmallScreen ? 14 : 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: isSmallScreen ? 4 : 6),
                              Text(
                                currentDarkMode ? "Dark Mode" : "Light Mode",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // User Statistics
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics_rounded,
                              color: theme.primaryColor,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "STATISTIK AKUN",
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.2,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        
                        if (isLoadingStats)
                          Center(
                            child: CircularProgressIndicator(
                              color: theme.primaryColor,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  context,
                                  icon: Icons.shopping_bag_rounded,
                                  title: "Total Item",
                                  value: "${userItems.length}",
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildStatItem(
                                  context,
                                  icon: Icons.check_circle_rounded,
                                  title: "Sudah Dibeli",
                                  value: "${userItems.where((item) => item.status == "Sudah Dibeli").length}",
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildStatItem(
                                  context,
                                  icon: Icons.pending_rounded,
                                  title: "Belum Dibeli",
                                  value: "${userItems.where((item) => item.status == "Belum Dibeli").length}",
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Settings Section
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings_rounded,
                              color: theme.primaryColor,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "PENGATURAN",
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.2,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        
                        _buildSettingItem(
                          context,
                          icon: Icons.dark_mode_rounded,
                          title: "Mode Gelap",
                          subtitle: "Ubah tampilan aplikasi",
                          trailing: Switch(
                            value: currentDarkMode,
                            onChanged: (value) async {
                              await themeProvider.toggleTheme(value);
                            },
                            activeColor: theme.primaryColor,
                          ),
                        ),
                        Divider(height: 24),
                        
                        _buildSettingItem(
                          context,
                          icon: Icons.notifications_rounded,
                          title: "Notifikasi",
                          subtitle: "Atur notifikasi aplikasi",
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              NotificationHelper.showInfoToast(context, "Fitur notifikasi akan segera hadir!");
                            },
                            activeColor: theme.primaryColor,
                          ),
                        ),
                        Divider(height: 24),
                        
                        _buildSettingItem(
                          context,
                          icon: Icons.security_rounded,
                          title: "Keamanan",
                          subtitle: "Pengaturan keamanan akun",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangePasswordScreen(email: widget.email),
                              ),
                            );
                          },
                        ),
                        Divider(height: 24),
                        
                        _buildSettingItem(
                          context,
                          icon: Icons.help_rounded,
                          title: "Bantuan",
                          subtitle: "Pusat bantuan dan FAQ",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HelpScreen(),
                              ),
                            );
                          },
                        ),
                        Divider(height: 24),
                        
                        _buildSettingItem(
                          context,
                          icon: Icons.info_rounded,
                          title: "Tentang Aplikasi",
                          subtitle: "Versi dan informasi aplikasi",
                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),
                        Divider(height: 24),
                        
                        _buildSettingItem(
                          context,
                          icon: Icons.logout_rounded,
                          title: "Keluar",
                          subtitle: "Keluar dari aplikasi",
                          isDestructive: true,
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),

                  // App Info
                  SizedBox(height: isSmallScreen ? 20 : 24),
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_rounded,
                          size: isSmallScreen ? 16 : 20,
                          color: theme.primaryColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "SmartBuy v1.0.0",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: color,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: isSmallScreen ? 10 : 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: isDestructive 
                  ? Colors.red.withOpacity(0.1)
                  : theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isSmallScreen ? 18 : 20,
                color: isDestructive 
                  ? Colors.red
                  : theme.primaryColor,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDestructive 
                        ? Colors.red
                        : isDark
                        ? Colors.white
                        : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: isSmallScreen ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.shopping_bag_rounded,
              color: theme.primaryColor,
            ),
            SizedBox(width: 8),
            Text(
              "Tentang SmartBuy",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SmartBuy adalah aplikasi untuk mengelola wishlist dan keuangan belanja Anda dengan bijak.",
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            _buildAboutItem("Versi", "1.0.0"),
            _buildAboutItem("Developer", "SmartBuy Team"),
            _buildAboutItem("Email", "support@smartbuy.com"),
            _buildAboutItem("Website", "www.smartbuy.com"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tutup",
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await PreferencesHelper.logout();
    NotificationHelper.showInfoToast(context, 'Berhasil logout.');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }
}
