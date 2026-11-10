import 'package:flutter/material.dart';
import '../models/student_profile.dart';
import '../providers/task_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

/// Halaman form profil data akademik mahasiswa (Materi Pertemuan 3 & 4).
///
/// Menyimpan data identitas mahasiswa (Nama, NIM, Email, Prodi, Semester, Target SKS)
/// secara persisten ke SharedPreferences melalui TaskProvider.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _nimController;
  late TextEditingController _emailController;
  late TextEditingController _semesterController;
  late TextEditingController _targetSksController;

  String _prodi = 'Informatika';
  bool _isInit = false;

  final List<String> _prodiOptions = [
    'Informatika',
    'Sistem Informasi',
    'Teknologi Informasi',
    'Teknik Komputer',
    'Manajemen Informatika',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final provider = TaskProvider.of(context);
      _nameController = TextEditingController(text: provider.profile.name);
      _nimController = TextEditingController(text: provider.profile.nim);
      _emailController = TextEditingController(text: provider.profile.email);
      _semesterController =
          TextEditingController(text: provider.profile.semester.toString());
      _targetSksController =
          TextEditingController(text: provider.profile.targetSks.toString());
      _prodi = _prodiOptions.contains(provider.profile.prodi)
          ? provider.profile.prodi
          : 'Informatika';
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _semesterController.dispose();
    _targetSksController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final provider = TaskProvider.of(context);

      // Sanitasi input teks (Pertemuan 6)
      final sanitizedName = Validators.sanitize(_nameController.text);
      final sanitizedNim = Validators.sanitize(_nimController.text);
      final sanitizedEmail = Validators.sanitize(_emailController.text);

      final updatedProfile = provider.profile.copyWith(
        name: sanitizedName,
        nim: sanitizedNim,
        email: sanitizedEmail,
        prodi: _prodi,
        semester: int.tryParse(_semesterController.text.trim()) ?? provider.profile.semester,
        targetSks: int.tryParse(_targetSksController.text.trim()) ?? provider.profile.targetSks,
      );

      provider.updateProfile(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil $sanitizedName berhasil diperbarui!'),
          backgroundColor: Colors.indigo,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Akademik Mahasiswa'),
        backgroundColor: Colors.indigo,
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
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.indigo.shade100,
                  child: const Icon(
                    Icons.school,
                    size: 52,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Field Nama
              CustomTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama mahasiswa',
                prefixIcon: Icons.badge_outlined,
                validator: (val) => Validators.validateRequired(val, 'Nama'),
              ),

              // Field NIM
              CustomTextField(
                controller: _nimController,
                label: 'Nomor Induk Mahasiswa (NIM)',
                hint: 'misal: 22.11.4820',
                prefixIcon: Icons.pin_outlined,
                validator: Validators.validateNim,
              ),

              // Field Email
              CustomTextField(
                controller: _emailController,
                label: 'Email Kampus',
                hint: 'nama@students.amikom.ac.id',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),

              // Dropdown Program Studi
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: _prodi,
                  decoration: const InputDecoration(
                    labelText: 'Program Studi',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _prodiOptions
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _prodi = val;
                      });
                    }
                  },
                ),
              ),

              Row(
                children: [
                  // Field Semester
                  Expanded(
                    child: CustomTextField(
                      controller: _semesterController,
                      label: 'Semester',
                      prefixIcon: Icons.timelapse,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          Validators.validateNumber(val, 'Semester', isInteger: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Field Target SKS
                  Expanded(
                    child: CustomTextField(
                      controller: _targetSksController,
                      label: 'Target SKS',
                      prefixIcon: Icons.menu_book,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          Validators.validateNumber(val, 'Target SKS', isInteger: true),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Tombol Simpan Profil
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
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
