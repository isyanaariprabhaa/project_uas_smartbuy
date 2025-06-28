import 'package:flutter/material.dart';
import '../utils/preferences_helper.dart';
import 'login_screen.dart';
import '../utils/notification_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool codeSent = false;
  bool codeVerified = false;
  String? resetCode;
  int timeLeft = 300; // 5 menit dalam detik
  bool isResendEnabled = true;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && codeSent && timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
        startTimer();
      } else if (mounted && timeLeft <= 0) {
        setState(() {
          isResendEnabled = true;
        });
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (isLoading) return;

    setState(() => isLoading = true);

    final email = emailController.text.trim();

    try {
      // Cek apakah email terdaftar
      final isRegistered = await PreferencesHelper.isEmailRegistered(email);
      
      if (!isRegistered) {
        showSnackBar("Email tidak terdaftar dalam sistem");
        setState(() => isLoading = false);
        return;
      }

      // Generate dan simpan reset code
      resetCode = PreferencesHelper.generateResetCode();
      await PreferencesHelper.saveResetCode(email, resetCode!);

      setState(() {
        codeSent = true;
        timeLeft = 300;
        isResendEnabled = false;
        isLoading = false;
      });

      showSnackBar("Kode reset telah dikirim ke email Anda: $resetCode");
    } catch (e) {
      showSnackBar("Gagal mengirim kode reset: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> verifyCode() async {
    if (codeController.text.isEmpty) {
      showSnackBar("Masukkan kode reset");
      return;
    }

    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final code = codeController.text.trim();

    try {
      final isValid = await PreferencesHelper.validateResetCode(email, code);
      
      if (isValid) {
        setState(() {
          codeVerified = true;
          isLoading = false;
        });
        showSnackBar("Kode valid! Silakan masukkan password baru");
      } else {
        showSnackBar("Kode tidak valid atau sudah expired");
        setState(() => isLoading = false);
      }
    } catch (e) {
      showSnackBar("Gagal memverifikasi kode: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (isLoading) return;

    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      showSnackBar("Password dan konfirmasi password tidak sama");
      setState(() => isLoading = false);
      return;
    }

    if (!PreferencesHelper.isStrongPassword(newPassword)) {
      showSnackBar("Password harus minimal 8 karakter, mengandung huruf besar, kecil, dan angka");
      setState(() => isLoading = false);
      return;
    }

    try {
      final success = await PreferencesHelper.resetPassword(email, newPassword);
      
      if (success) {
        await PreferencesHelper.clearResetCode(email);
        showSnackBar("Password berhasil direset! Silakan login");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      } else {
        showSnackBar("Gagal mereset password");
      }
    } catch (e) {
      showSnackBar("Gagal mereset password: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnackBar(String message) {
    NotificationHelper.showErrorToast(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lupa Password"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 40),
                // Icon
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    size: 50,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 24),
                // Title
                Text(
                  "Reset Password",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                // Subtitle
                Text(
                  "Masukkan email Anda untuk reset password",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),

                // Form Card
                Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: theme.primaryColor.withOpacity(0.2),
                  color: isDark ? Colors.grey[800] : Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: emailController,
                          enabled: !codeSent,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!PreferencesHelper.isValidEmail(value)) {
                              return 'Email tidak valid';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(
                              Icons.email,
                              color: theme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Send Code Button
                        if (!codeSent)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : sendResetCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text("Kirim Kode Reset"),
                            ),
                          ),

                        // Code Section
                        if (codeSent && !codeVerified) ...[
                          SizedBox(height: 20),
                          Text(
                            "Masukkan kode 6 digit yang telah dikirim",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: codeController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  decoration: InputDecoration(
                                    labelText: "Kode Reset",
                                    counterText: "",
                                    prefixIcon: Icon(
                                      Icons.security,
                                      color: theme.primaryColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: isLoading ? null : verifyCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text("Verifikasi"),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Kode berlaku: ${formatTime(timeLeft)}",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: timeLeft < 60 ? Colors.red : Colors.grey,
                                ),
                              ),
                              TextButton(
                                onPressed: isResendEnabled ? sendResetCode : null,
                                child: Text(
                                  "Kirim Ulang",
                                  style: TextStyle(
                                    color: isResendEnabled ? theme.primaryColor : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // New Password Section
                        if (codeVerified) ...[
                          SizedBox(height: 20),
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: !isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              if (!PreferencesHelper.isStrongPassword(value)) {
                                return 'Password minimal 8 karakter, mengandung huruf besar, kecil, dan angka';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Password Baru",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: theme.primaryColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                  color: theme.primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: !isConfirmPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password wajib diisi';
                              }
                              if (value != newPasswordController.text) {
                                return 'Password tidak sama';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Konfirmasi Password Baru",
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: theme.primaryColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                  color: theme.primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isConfirmPasswordVisible = !isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text("Reset Password"),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Kembali ke Login",
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 