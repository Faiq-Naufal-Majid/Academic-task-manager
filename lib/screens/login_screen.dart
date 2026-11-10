import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';

/// Halaman Login Mahasiswa ke Portal Manajemen Tugas (Materi Pertemuan 3 & 5).
///
/// Menerapkan form handling dengan validasi regex email, kriteria password,
/// toggle visibility (obscureText), indikator kekuatan password,
/// checkbox tata tertib akademik, serta penyimpanan token sesi terenkripsi AES-256.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secureStorage = SecureStorageService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _agreeToRules = false;
  bool _showRulesError = false;
  double _passwordStrength = 0.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordStrength = Validators.calculatePasswordStrength(value);
    });
  }

  String _getPasswordStrengthLabel() {
    if (_passwordStrength < 0.4) return 'Lemah';
    if (_passwordStrength < 0.8) return 'Sedang';
    return 'Kuat';
  }

  Color _getPasswordStrengthColor() {
    if (_passwordStrength < 0.4) return Colors.red;
    if (_passwordStrength < 0.8) return Colors.orange;
    return Colors.green;
  }

  Future<void> _submitLogin() async {
    setState(() {
      _showRulesError = !_agreeToRules;
    });

    if (!_agreeToRules) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda wajib menyetujui tata tertib akademik portal!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulasi request login ke server akademik
      await Future.delayed(const Duration(seconds: 1));

      // Simpan token sesi autentikasi ke Secure Storage (Terenkripsi AES-256)
      final dummyToken = 'mhs_jwt_${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.saveToken(dummyToken);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.indigo),
              SizedBox(width: 8),
              Text('Autentikasi Berhasil'),
            ],
          ),
          content: Text(
            'Selamat datang di Portal Tugas Mahasiswa!\nEmail: ${_emailController.text.trim()}\n'
            'Token sesi aman telah disimpan.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('Buka Dashboard'),
            ),
          ],
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _passwordStrength = 0.0;
      _agreeToRules = false;
      _showRulesError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Tugas & Akademik'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.school,
                  size: 72,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Academic Task Manager',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelola tugas kuliah, deadline, dan tips belajar secara terorganisir',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Field Email Mahasiswa
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Mahasiswa',
                  hint: 'contoh: nama@students.amikom.ac.id',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                // Field Password dengan Toggle Visibility & Indikator Kekuatan
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: _onPasswordChanged,
                    validator: Validators.validatePassword,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Portal',
                      hintText: 'Minimal 8 karakter, huruf kapital & angka',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                // Indikator Kekuatan Password (Latihan 5 Pertemuan 3)
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _passwordStrength,
                            backgroundColor: Colors.grey.shade300,
                            color: _getPasswordStrengthColor(),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _getPasswordStrengthLabel(),
                        style: TextStyle(
                          color: _getPasswordStrengthColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Checkbox S&K Akademik (Latihan 4 Pertemuan 3)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _agreeToRules,
                  title: const Text(
                    'Saya menyetujui integritas akademik dan tata tertib manajemen tugas',
                    style: TextStyle(fontSize: 13),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) {
                    setState(() {
                      _agreeToRules = val ?? false;
                      if (_agreeToRules) _showRulesError = false;
                    });
                  },
                ),
                if (_showRulesError)
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Text(
                      '* Wajib disetujui sebelum masuk',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 16),

                // Tombol Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Masuk ke Akun Mahasiswa',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 8),

                // Tombol Reset Form
                OutlinedButton(
                  onPressed: _isLoading ? null : _resetForm,
                  child: const Text('Reset Form'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
