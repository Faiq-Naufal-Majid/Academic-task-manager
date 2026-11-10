import 'package:flutter/material.dart';
import '../models/academic_task.dart';
import '../providers/task_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

/// Halaman form tambah tugas kuliah baru (Materi Pertemuan 3 & 4).
///
/// Menyediakan field input judul tugas (dengan sanitasi XSS),
/// Dropdown pemilihan mata kuliah dan prioritas, DatePicker deadline,
/// serta tombol simpan ke state management lokal.
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _deadlineController = TextEditingController();

  String _selectedCourse = 'Pemrograman Mobile';
  String _selectedPriority = 'Sedang';
  bool _enableReminder = true;

  final List<String> _courseOptions = [
    'Pemrograman Mobile',
    'Basis Data Lanjut',
    'Kecerdasan Buatan',
    'Rekayasa Perangkat Lunak',
    'Jaringan Komputer',
    'Sistem Terdistribusi',
    'Etika Profesi',
  ];

  final List<String> _priorityOptions = ['Tinggi', 'Sedang', 'Rendah'];

  @override
  void dispose() {
    _titleController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  /// Memilih tanggal tenggat waktu (deadline) menggunakan showDatePicker (Latihan 2 Pertemuan 3).
  Future<void> _selectDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _deadlineController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      final provider = TaskProvider.of(context);

      // Sanitasi input teks terhadap XSS (Pertemuan 6)
      final sanitizedTitle = Validators.sanitize(_titleController.text);

      final newTask = AcademicTask(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: sanitizedTitle,
        course: _selectedCourse,
        deadline: _deadlineController.text.trim(),
        priority: _selectedPriority,
        isCompleted: false,
      );

      provider.addTask(newTask);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tugas "$sanitizedTitle" berhasil ditambahkan!'),
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
        title: const Text('Tambah Tugas Kuliah'),
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
              // Field Judul Tugas
              CustomTextField(
                controller: _titleController,
                label: 'Judul Tugas / Proyek',
                hint: 'misal: Laporan Praktikum Modul 6',
                prefixIcon: Icons.assignment_outlined,
                validator: (val) => Validators.validateRequired(val, 'Judul Tugas'),
              ),

              // Dropdown Mata Kuliah (Latihan 3 Pertemuan 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedCourse,
                  decoration: const InputDecoration(
                    labelText: 'Mata Kuliah',
                    prefixIcon: Icon(Icons.class_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _courseOptions
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCourse = val;
                      });
                    }
                  },
                ),
              ),

              // Field Tanggal Deadline (Latihan 2 Pertemuan 3)
              CustomTextField(
                controller: _deadlineController,
                label: 'Tenggat Waktu (Deadline)',
                hint: 'Pilih tanggal pengumpulan',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _selectDeadline,
                validator: (val) => Validators.validateRequired(val, 'Deadline'),
              ),

              // Dropdown Prioritas
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Tingkat Prioritas',
                    prefixIcon: Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _priorityOptions
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPriority = val;
                      });
                    }
                  },
                ),
              ),

              // Checkbox Pengingat (Latihan 4 Pertemuan 3)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _enableReminder,
                title: const Text('Aktifkan pengingat notifikasi H-1 deadline'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) {
                  setState(() {
                    _enableReminder = val ?? true;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _submitTask,
                icon: const Icon(Icons.add_task),
                label: const Text('Simpan Tugas Baru'),
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
