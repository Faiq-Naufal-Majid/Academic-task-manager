import 'package:flutter/material.dart';
import '../models/user_health.dart';
import '../providers/health_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

/// Halaman form pengisian dan pembaruan profil data kesehatan (Materi Pertemuan 3 & 4).
///
/// Menyediakan input form komprehensif: Nama, Email, Usia, Berat Badan,
/// Dropdown Jenis Kelamin, DatePicker Tanggal Lahir, serta Target Air Harian.
/// Data disanitasi terhadap XSS dan disimpan ke SharedPreferences via HealthProvider.
class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _birthDateController;
  late TextEditingController _waterTargetController;

  String _gender = 'Laki-laki';
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final provider = HealthProvider.of(context);
      _nameController = TextEditingController(text: provider.user.name);
      _emailController = TextEditingController(text: provider.user.email);
      _ageController = TextEditingController(text: provider.user.age.toString());
      _weightController = TextEditingController(text: provider.user.weight.toString());
      _birthDateController = TextEditingController(text: provider.user.birthDate);
      _waterTargetController =
          TextEditingController(text: provider.user.dailyWaterTargetMl.toString());
      _gender = provider.user.gender.isNotEmpty ? provider.user.gender : 'Laki-laki';
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _birthDateController.dispose();
    _waterTargetController.dispose();
    super.dispose();
  }

  /// Memilih tanggal lahir menggunakan dialog showDatePicker (Latihan 2 Pertemuan 3).
  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  /// Menyimpan form data kesehatan setelah validasi & sanitasi input (Pertemuan 4 & 6).
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final provider = HealthProvider.of(context);

      // Sanitasi input teks terhadap karakter berbahaya (XSS Protection)
      final sanitizedName = Validators.sanitize(_nameController.text);
      final sanitizedEmail = Validators.sanitize(_emailController.text);

      final updatedUser = provider.user.copyWith(
        name: sanitizedName,
        email: sanitizedEmail,
        age: int.tryParse(_ageController.text.trim()) ?? provider.user.age,
        weight: double.tryParse(_weightController.text.trim()) ?? provider.user.weight,
        gender: _gender,
        birthDate: _birthDateController.text.trim(),
        dailyWaterTargetMl:
            int.tryParse(_waterTargetController.text.trim()) ?? provider.user.dailyWaterTargetMl,
      );

      // Simpan perubahan ke SharedPreferences via HealthProvider
      provider.updateProfile(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil $sanitizedName berhasil disimpan!'),
          backgroundColor: Colors.teal,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Target Kesehatan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(
                        Icons.person,
                        size: 52,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Field Nama Lengkap
              CustomTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama Anda',
                prefixIcon: Icons.badge_outlined,
                validator: (val) => Validators.validateRequired(val, 'Nama Lengkap'),
              ),

              // Field Email
              CustomTextField(
                controller: _emailController,
                label: 'Alamat Email',
                hint: 'contoh@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),

              // Dropdown Jenis Kelamin (Latihan 3 Pertemuan 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Kelamin',
                    prefixIcon: Icon(Icons.wc),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _gender = val;
                      });
                    }
                  },
                ),
              ),

              // Field Tanggal Lahir (Latihan 2 Pertemuan 3)
              CustomTextField(
                controller: _birthDateController,
                label: 'Tanggal Lahir',
                hint: 'Pilih tanggal lahir',
                prefixIcon: Icons.calendar_today,
                readOnly: true,
                onTap: _selectBirthDate,
                validator: (val) => Validators.validateRequired(val, 'Tanggal Lahir'),
              ),

              Row(
                children: [
                  // Field Usia
                  Expanded(
                    child: CustomTextField(
                      controller: _ageController,
                      label: 'Usia (Tahun)',
                      prefixIcon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) => Validators.validateNumber(val, 'Usia', isInteger: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Field Berat Badan
                  Expanded(
                    child: CustomTextField(
                      controller: _weightController,
                      label: 'Berat Badan (kg)',
                      prefixIcon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) => Validators.validateNumber(val, 'Berat Badan'),
                    ),
                  ),
                ],
              ),

              // Field Target Air Harian
              CustomTextField(
                controller: _waterTargetController,
                label: 'Target Minum Harian (ml)',
                hint: 'Rekomendasi: 2000 ml',
                prefixIcon: Icons.water_drop_outlined,
                keyboardType: TextInputType.number,
                validator: (val) => Validators.validateNumber(val, 'Target Air', isInteger: true),
              ),

              const SizedBox(height: 20),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Data Kesehatan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
