import 'package:flutter/material.dart';
import '../models/study_tip.dart';
import '../providers/task_provider.dart';
import '../repositories/article_repository.dart';
import '../repositories/article_repository_impl.dart';
import '../services/secure_storage_service.dart';
import '../widgets/study_tip_card.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

/// Halaman Dashboard utama aplikasi Manajemen Tugas & Akademik Mahasiswa.
///
/// Mengintegrasikan:
/// - State Management via [TaskProvider] (Pertemuan 4)
/// - Persistensi profil & daftar tugas via [SharedPreferences] (Pertemuan 4)
/// - REST API dengan Repository Pattern & 3-state UI (Pertemuan 5 & 6)
/// - Pencarian tips belajar secara real-time (Latihan Modul 5)
/// - Bookmark artikel favorit (Latihan Modul 4)
/// - Manajemen sesi dan token aman via Secure Storage (Pertemuan 5)
class HomeScreen extends StatefulWidget {
  final ArticleRepository? repository;
  const HomeScreen({super.key, this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ArticleRepository _repository;
  final SecureStorageService _storageService = SecureStorageService();

  List<StudyTip> _allTips = [];
  List<StudyTip> _filteredTips = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyFavorites = false;
  String _taskFilter = 'Semua'; // 'Semua', 'Belum', 'Selesai'

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ArticleRepositoryImpl();
    _fetchTips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Memuat artikel tips belajar dari REST API melalui Repository (Pertemuan 5 & 6).
  Future<void> _fetchTips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tips = await _repository.fetchStudyTips();
      setState(() {
        _allTips = tips;
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Memfilter data tips berdasarkan kata kunci pencarian dan tab favorit.
  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    final provider = TaskProvider.of(context);

    setState(() {
      _filteredTips = _allTips.where((tip) {
        final matchesQuery =
            tip.title.toLowerCase().contains(query) || tip.body.toLowerCase().contains(query);
        final matchesFavorite = !_showOnlyFavorites || provider.isFavorite(tip.id.toString());
        return matchesQuery && matchesFavorite;
      }).toList();
    });
  }

  /// Dialog konfirmasi logout dan pembersihan token dari Secure Storage (Modul 5).
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text(
          'Apakah Anda yakin ingin keluar? Token sesi di secure storage akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _storageService.deleteToken();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Menampilkan detail lengkap tips belajar di modal bottom sheet (Materi Pertemuan 5).
  void _showTipDetail(StudyTip tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.school, color: Colors.indigo, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Ringkasan Materi & Tips:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                tip.body,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              if (tip.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Topik Terkait:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: tip.tags
                      .map((tag) => Chip(
                            label: Text('#$tag'),
                            backgroundColor: Colors.indigo.shade50,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = TaskProvider.of(context);

    // Filter daftar tugas sesuai tab
    final displayedTasks = provider.tasks.where((t) {
      if (_taskFilter == 'Selesai') return t.isCompleted;
      if (_taskFilter == 'Belum') return !t.isCompleted;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${provider.profile.name}', style: const TextStyle(fontSize: 17)),
            Text(
              'NIM: ${provider.profile.nim} • Semester ${provider.profile.semester} • Buka: ke-${provider.visitCount}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Ganti Tema',
            onPressed: provider.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profil Mahasiswa',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTaskScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTips,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // Card Progres Tugas Semester Ini (Materi Pertemuan 4)
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assignment_turned_in, color: Colors.indigo, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Progres Tugas Kuliah',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          '${(provider.taskProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: provider.taskProgress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${provider.completedTaskCount} dari ${provider.totalTaskCount} tugas selesai',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Target: ${provider.profile.targetSks} SKS',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Section Daftar Tugas Mahasiswa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Tugas Kuliah',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Baru'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips Tugas (Semua, Belum, Selesai)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('Semua (${provider.totalTaskCount})'),
                    selected: _taskFilter == 'Semua',
                    onSelected: (val) {
                      if (val) setState(() => _taskFilter = 'Semua');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Belum (${provider.totalTaskCount - provider.completedTaskCount})'),
                    selected: _taskFilter == 'Belum',
                    onSelected: (val) {
                      if (val) setState(() => _taskFilter = 'Belum');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Selesai (${provider.completedTaskCount})'),
                    selected: _taskFilter == 'Selesai',
                    onSelected: (val) {
                      if (val) setState(() => _taskFilter = 'Selesai');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Render Daftar Tugas
            if (displayedTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.task_alt, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        _taskFilter == 'Semua'
                            ? 'Belum ada tugas kuliah. Klik "Tambah Tugas" untuk membuat baru!'
                            : 'Tidak ada tugas berstatus "$_taskFilter".',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...displayedTasks.map((task) {
                return TaskCard(
                  task: task,
                  onToggleStatus: () => provider.toggleTaskStatus(task.id),
                  onDelete: () => provider.deleteTask(task.id),
                );
              }),

            const Divider(height: 36, thickness: 1),

            // Header Bagian REST API Tips Belajar & Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tips Belajar & Produktivitas (REST API)',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Input Pencarian Real-time (Latihan Modul 5)
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilter(),
                    decoration: InputDecoration(
                      hintText: 'Cari tips belajar & manajemen waktu...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilter();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Filter Chips Semua vs Favorit (Latihan Modul 4)
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Semua Tips'),
                        selected: !_showOnlyFavorites,
                        onSelected: (val) {
                          setState(() {
                            _showOnlyFavorites = false;
                          });
                          _applyFilter();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text('Favorit (${provider.favoriteTipIds.length})'),
                        selected: _showOnlyFavorites,
                        onSelected: (val) {
                          setState(() {
                            _showOnlyFavorites = true;
                          });
                          _applyFilter();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 3-State REST API UI: Loading, Error, Success
            _buildTipsSection(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(TaskProvider provider) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Memuat tips belajar dari REST API...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.cloud_off, size: 54, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _fetchTips,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredTips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              const Text('Tidak ada artikel tips yang cocok.'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _filteredTips.map((tip) {
        final tipIdStr = tip.id.toString();
        final isFav = provider.isFavorite(tipIdStr);

        return StudyTipCard(
          tip: tip,
          isFavorite: isFav,
          onFavoriteToggle: () {
            provider.toggleFavorite(tipIdStr);
            if (_showOnlyFavorites) {
              _applyFilter();
            }
          },
          onTap: () => _showTipDetail(tip),
        );
      }).toList(),
    );
  }
}
