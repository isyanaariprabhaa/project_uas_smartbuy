import 'package:flutter/material.dart';
import '../utils/preferences_helper.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  const ChangePasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;
  String? _errorMsg;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMsg = null; });
    final isValid = await PreferencesHelper.validateLogin(widget.email, _oldPassController.text);
    if (!isValid) {
      setState(() { _isLoading = false; _errorMsg = 'Password lama salah!'; });
      return;
    }
    if (_newPassController.text != _confirmPassController.text) {
      setState(() { _isLoading = false; _errorMsg = 'Konfirmasi password tidak cocok!'; });
      return;
    }
    if (!PreferencesHelper.isStrongPassword(_newPassController.text)) {
      setState(() { _isLoading = false; _errorMsg = 'Password baru terlalu lemah!'; });
      return;
    }
    final result = await PreferencesHelper.resetPassword(widget.email, _newPassController.text);
    setState(() => _isLoading = false);
    if (result && mounted) {
      Navigator.pop(context, true);
    } else {
      setState(() { _errorMsg = 'Gagal mengganti password!'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Ganti Password'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(_errorMsg!, style: TextStyle(color: Colors.red)),
                ),
              Text('Password Lama', style: theme.textTheme.bodyMedium),
              SizedBox(height: 8),
              TextFormField(
                controller: _oldPassController,
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.lock, color: theme.primaryColor),
                ),
              ),
              SizedBox(height: 16),
              Text('Password Baru', style: theme.textTheme.bodyMedium),
              SizedBox(height: 8),
              TextFormField(
                controller: _newPassController,
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor),
                ),
              ),
              SizedBox(height: 16),
              Text('Konfirmasi Password Baru', style: theme.textTheme.bodyMedium),
              SizedBox(height: 8),
              TextFormField(
                controller: _confirmPassController,
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('GANTI PASSWORD', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 