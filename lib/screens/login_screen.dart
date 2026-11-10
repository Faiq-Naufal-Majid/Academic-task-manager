import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';

/// Halaman Login & Registrasi aplikasi kesehatan (Materi Pertemuan 3 & 5).
///
/// Menerapkan form handling dengan validasi real-time, kalkulasi kekuatan password,
/// checkbox persetujuan syarat & ketentuan, serta penyimpanan token terenkripsi.
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
  bool _agreeToTerms = false;
  bool _showTermsError = false;
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
      _showTermsError = !_agreeToTerms;
    });

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda wajib menyetujui syarat & ketentuan kesehatan!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulasi autentikasi API
      await Future.delayed(const Duration(seconds: 1));

      // Simpan dummy auth token ke Secure Storage (Terenkripsi AES)
      final dummyToken = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
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
              Icon(Icons.check_circle, color: Colors.teal),
              SizedBox(width: 8),
              Text('Login Berhasil'),
            ],
          ),
          content: Text(
            'Selamat datang kembali!\nEmail: ${_emailController.text.trim()}\n'
            'Token autentikasi aman tersimpan.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('Masuk ke Beranda'),
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
      _agreeToTerms = false;
      _showTermsError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masuk Akun Kesehatan'),
        backgroundColor: Colors.teal,
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
                  Icons.health_and_safety,
                  size: 72,
                  color: Colors.teal,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Health & Hydration Portal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelola data kesehatan dan hidrasi harian Anda secara aman',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Field Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Pengguna',
                  hint: 'contoh: budi@kesehatan.id',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                // Field Password dengan Toggle Visibility & Kekuatan Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: _onPasswordChanged,
                    validator: Validators.validatePassword,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
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

                // Checkbox S&K (Latihan 4 Pertemuan 3)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _agreeToTerms,
                  title: const Text(
                    'Saya menyetujui syarat & ketentuan pelacakan data kesehatan',
                    style: TextStyle(fontSize: 13),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) {
                    setState(() {
                      _agreeToTerms = val ?? false;
                      if (_agreeToTerms) _showTermsError = false;
                    });
                  },
                ),
                if (_showTermsError)
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Text(
                      '* Wajib dicentang sebelum melanjutkan',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 16),

                // Tombol Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
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
                          'Masuk',
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
