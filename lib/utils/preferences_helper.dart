import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class PreferencesHelper {
  static Future<void> saveLogin(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);
  }

  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Fungsi untuk register user baru
  static Future<bool> registerUser(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cek apakah email sudah terdaftar
      final registeredUsers = prefs.getStringList('registered_users') ?? [];
      if (registeredUsers.contains(email)) {
        return false; // Email sudah terdaftar
      }
      
      // Enkripsi password sederhana (dalam aplikasi nyata gunakan bcrypt)
      final hashedPassword = _hashPassword(password);
      
      // Simpan user baru
      registeredUsers.add(email);
      await prefs.setStringList('registered_users', registeredUsers);
      
      // Simpan password yang sudah di-hash
      await prefs.setString('password_$email', hashedPassword);
      
      return true; // Register berhasil
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  // Fungsi untuk validasi login
  static Future<bool> validateLogin(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cek apakah email terdaftar
      final registeredUsers = prefs.getStringList('registered_users') ?? [];
      if (!registeredUsers.contains(email)) {
        return false;
      }
      
      // Ambil password yang tersimpan
      final storedPassword = prefs.getString('password_$email');
      if (storedPassword == null) {
        return false;
      }
      
      // Validasi password
      final hashedPassword = _hashPassword(password);
      return storedPassword == hashedPassword;
    } catch (e) {
      print('Error validating login: $e');
      return false;
    }
  }

  // Fungsi untuk validasi email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Fungsi untuk validasi password strength
  static bool isStrongPassword(String password) {
    // Minimal 8 karakter, mengandung huruf besar, kecil, angka
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  // Fungsi hash password sederhana (dalam aplikasi nyata gunakan bcrypt)
  static String _hashPassword(String password) {
    // Ini hanya contoh sederhana, dalam aplikasi nyata gunakan bcrypt
    final bytes = utf8.encode(password + 'smartbuy_salt');
    final hash = base64.encode(bytes);
    return hash;
  }

  // Fungsi untuk mendapatkan daftar user terdaftar (untuk debugging)
  static Future<List<String>> getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('registered_users') ?? [];
  }

  // Fungsi untuk lupa password - cek apakah email terdaftar
  static Future<bool> isEmailRegistered(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final registeredUsers = prefs.getStringList('registered_users') ?? [];
      return registeredUsers.contains(email);
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // Fungsi untuk reset password
  static Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cek apakah email terdaftar
      final registeredUsers = prefs.getStringList('registered_users') ?? [];
      if (!registeredUsers.contains(email)) {
        return false; // Email tidak terdaftar
      }
      
      // Hash password baru
      final hashedPassword = _hashPassword(newPassword);
      
      // Update password
      await prefs.setString('password_$email', hashedPassword);
      
      return true; // Reset berhasil
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  // Fungsi untuk generate reset code (simulasi)
  static String generateResetCode() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Fungsi untuk menyimpan reset code sementara
  static Future<void> saveResetCode(String email, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reset_code_$email', code);
    // Set expiry time (5 menit)
    await prefs.setInt('reset_expiry_$email', DateTime.now().millisecondsSinceEpoch + (5 * 60 * 1000));
  }

  // Fungsi untuk validasi reset code
  static Future<bool> validateResetCode(String email, String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('reset_code_$email');
      final expiryTime = prefs.getInt('reset_expiry_$email') ?? 0;
      
      if (savedCode == null || savedCode != code) {
        return false;
      }
      
      // Cek apakah code sudah expired
      if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
        // Hapus expired code
        await prefs.remove('reset_code_$email');
        await prefs.remove('reset_expiry_$email');
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error validating reset code: $e');
      return false;
    }
  }

  // Fungsi untuk membersihkan reset code setelah digunakan
  static Future<void> clearResetCode(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reset_code_$email');
    await prefs.remove('reset_expiry_$email');
  }

  // Fungsi untuk menyimpan nama user
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  // Fungsi untuk mengambil nama user
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? '';
  }
}
