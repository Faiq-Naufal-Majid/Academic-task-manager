import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/academic_task.dart';
import '../models/student_profile.dart';

/// Provider berbasis [InheritedWidget] untuk mendistribusikan state akademik
/// (daftar tugas kuliah, profil mahasiswa, tema, dan preferensi) ke seluruh widget tree
/// tanpa terkena kendala prop drilling (Materi Pertemuan 4).
class TaskProvider extends InheritedWidget {
  final StudentProfile profile;
  final List<AcademicTask> tasks;
  final bool isDarkMode;
  final int visitCount;
  final List<String> favoriteTipIds;

  final Function(AcademicTask) addTask;
  final Function(String) toggleTaskStatus;
  final Function(String) deleteTask;
  final Function(StudentProfile) updateProfile;
  final VoidCallback toggleTheme;
  final Function(String) toggleFavorite;

  const TaskProvider({
    super.key,
    required this.profile,
    required this.tasks,
    required this.isDarkMode,
    required this.visitCount,
    required this.favoriteTipIds,
    required this.addTask,
    required this.toggleTaskStatus,
    required this.deleteTask,
    required this.updateProfile,
    required this.toggleTheme,
    required this.toggleFavorite,
    required super.child,
  });

  /// Jumlah tugas yang telah diselesaikan.
  int get completedTaskCount => tasks.where((t) => t.isCompleted).length;

  /// Total tugas aktif.
  int get totalTaskCount => tasks.length;

  /// Rasio progres penyelesaian tugas (0.0 sampai 1.0).
  double get taskProgress => totalTaskCount > 0 ? completedTaskCount / totalTaskCount : 0.0;

  /// Memeriksa status favorit artikel tips.
  bool isFavorite(String tipId) => favoriteTipIds.contains(tipId);

  /// Method static untuk mengakses [TaskProvider] dari [BuildContext].
  static TaskProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<TaskProvider>();
    assert(provider != null, 'TaskProvider tidak ditemukan di context');
    return provider!;
  }

  @override
  bool updateShouldNotify(TaskProvider oldWidget) {
    return oldWidget.profile != profile ||
        oldWidget.tasks != tasks ||
        oldWidget.isDarkMode != isDarkMode ||
        oldWidget.visitCount != visitCount ||
        oldWidget.favoriteTipIds != favoriteTipIds;
  }
}

/// StatefulWidget pembungkus yang mengelola logika penyimpanan persisten via [SharedPreferences] (Pertemuan 4).
class TaskProviderWrapper extends StatefulWidget {
  final Widget child;
  const TaskProviderWrapper({super.key, required this.child});

  @override
  State<TaskProviderWrapper> createState() => _TaskProviderWrapperState();
}

class _TaskProviderWrapperState extends State<TaskProviderWrapper> {
  StudentProfile _profile = StudentProfile(
    name: 'Budi Raharjo',
    nim: '22.11.4820',
    email: 'budi.raharjo@students.amikom.ac.id',
    prodi: 'Informatika',
    semester: 4,
    targetSks: 22,
  );

  List<AcademicTask> _tasks = [
    AcademicTask(
      id: 'task_1',
      title: 'Laporan Praktikum Pemrograman Mobile Pertemuan 6',
      course: 'Pemrograman Mobile',
      deadline: '2026-11-15',
      priority: 'Tinggi',
      isCompleted: false,
    ),
    AcademicTask(
      id: 'task_2',
      title: 'Desain ERD Database Rumah Sakit',
      course: 'Basis Data Lanjut',
      deadline: '2026-11-18',
      priority: 'Sedang',
      isCompleted: true,
    ),
  ];

  bool _isDarkMode = false;
  int _visitCount = 1;
  List<String> _favoriteTipIds = [];

  @override
  void initState() {
    super.initState();
    _loadFromPreferences();
  }

  /// Memuat profil, daftar tugas, dan preferensi dari SharedPreferences.
  Future<void> _loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('student_name') ?? _profile.name;
    final nim = prefs.getString('student_nim') ?? _profile.nim;
    final email = prefs.getString('student_email') ?? _profile.email;
    final prodi = prefs.getString('student_prodi') ?? _profile.prodi;
    final semester = prefs.getInt('student_semester') ?? _profile.semester;
    final targetSks = prefs.getInt('student_target_sks') ?? _profile.targetSks;

    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    final visitCount = (prefs.getInt('visit_count') ?? 0) + 1;
    final favorites = prefs.getStringList('favorite_tips') ?? [];

    // Muat daftar tugas tersimpan
    final tasksJson = prefs.getString('academic_tasks');
    List<AcademicTask> loadedTasks = _tasks;
    if (tasksJson != null && tasksJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(tasksJson);
        loadedTasks = decoded.map((item) => AcademicTask.fromMap(item)).toList();
      } catch (e) {
        print('Error decoding tasks: $e');
      }
    }

    await prefs.setInt('visit_count', visitCount);

    setState(() {
      _profile = StudentProfile(
        name: name,
        nim: nim,
        email: email,
        prodi: prodi,
        semester: semester,
        targetSks: targetSks,
      );
      _tasks = loadedTasks;
      _isDarkMode = isDarkMode;
      _visitCount = visitCount;
      _favoriteTipIds = favorites;
    });
  }

  /// Menyimpan daftar tugas ke SharedPreferences dalam format JSON String.
  Future<void> _saveTasksToPreferences(List<AcademicTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toMap()).toList());
    await prefs.setString('academic_tasks', jsonString);
  }

  /// Menambah tugas kuliah baru.
  Future<void> _addTask(AcademicTask newTask) async {
    final updatedList = List<AcademicTask>.from(_tasks)..insert(0, newTask);
    setState(() {
      _tasks = updatedList;
    });
    await _saveTasksToPreferences(updatedList);
  }

  /// Toggle checklist status selesai tugas.
  Future<void> _toggleTaskStatus(String taskId) async {
    final updatedList = _tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    setState(() {
      _tasks = updatedList;
    });
    await _saveTasksToPreferences(updatedList);
  }

  /// Menghapus tugas dari daftar.
  Future<void> _deleteTask(String taskId) async {
    final updatedList = _tasks.where((t) => t.id != taskId).toList();
    setState(() {
      _tasks = updatedList;
    });
    await _saveTasksToPreferences(updatedList);
  }

  /// Memperbarui data profil mahasiswa.
  Future<void> _updateProfile(StudentProfile newProfile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_name', newProfile.name);
    await prefs.setString('student_nim', newProfile.nim);
    await prefs.setString('student_email', newProfile.email);
    await prefs.setString('student_prodi', newProfile.prodi);
    await prefs.setInt('student_semester', newProfile.semester);
    await prefs.setInt('student_target_sks', newProfile.targetSks);

    setState(() {
      _profile = newProfile;
    });
  }

  /// Toggle tema Light/Dark Mode (Latihan 1 Pertemuan 4).
  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }

  /// Menyimpan artikel tips favorit (Latihan 3 Pertemuan 4).
  Future<void> _toggleFavorite(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedFavorites = List<String>.from(_favoriteTipIds);
    if (updatedFavorites.contains(tipId)) {
      updatedFavorites.remove(tipId);
    } else {
      updatedFavorites.add(tipId);
    }

    setState(() {
      _favoriteTipIds = updatedFavorites;
    });
    await prefs.setStringList('favorite_tips', updatedFavorites);
  }

  @override
  Widget build(BuildContext context) {
    return TaskProvider(
      profile: _profile,
      tasks: _tasks,
      isDarkMode: _isDarkMode,
      visitCount: _visitCount,
      favoriteTipIds: _favoriteTipIds,
      addTask: _addTask,
      toggleTaskStatus: _toggleTaskStatus,
      deleteTask: _deleteTask,
      updateProfile: _updateProfile,
      toggleTheme: _toggleTheme,
      toggleFavorite: _toggleFavorite,
      child: widget.child,
    );
  }
}
