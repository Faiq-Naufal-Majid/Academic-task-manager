import 'package:flutter/material.dart';
import '../models/health_tip.dart';
import '../providers/health_provider.dart';
import '../repositories/health_repository.dart';
import '../repositories/health_repository_impl.dart';
import '../services/secure_storage_service.dart';
import '../widgets/health_tip_card.dart';
import 'login_screen.dart';
import 'profile_form_screen.dart';

/// Halaman utama (Dashboard) aplikasi kesehatan dan pemantauan hidrasi.
///
/// Mengintegrasikan:
/// - State Management via [HealthProvider] (Pertemuan 4)
/// - Persistensi preferensi & hidrasi via SharedPreferences (Pertemuan 4)
/// - REST API dengan Repository Pattern & 3-state UI (Pertemuan 5 & 6)
/// - Pencarian tips kesehatan secara real-time (Latihan Modul 5)
/// - Penyimpanan tips favorit (Latihan Modul 4)
/// - Manajemen sesi dan token aman via Secure Storage (Pertemuan 5)
class HomeScreen extends StatefulWidget {
  final HealthRepository? repository;
  const HomeScreen({super.key, this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HealthRepository _repository;
  final SecureStorageService _storageService = SecureStorageService();

  List<HealthTip> _allTips = [];
  List<HealthTip> _filteredTips = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? HealthRepositoryImpl();
    _fetchTips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Memuat daftar tips kesehatan dari REST API melalui Repository.
  Future<void> _fetchTips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tips = await _repository.fetchHealthTips();
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

  /// Memfilter data tips berdasarkan query pencarian dan tab favorit.
  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    final provider = HealthProvider.of(context);

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
          'Apakah Anda yakin ingin keluar? Token autentikasi di secure storage akan dihapus.',
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

  /// Menampilkan detail tips kesehatan di modal bottom sheet (Materi Pertemuan 5).
  void _showTipDetail(HealthTip tip) {
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
                  const Icon(Icons.health_and_safety, color: Colors.teal, size: 28),
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
                'Deskripsi & Saran Medis:',
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
                            backgroundColor: Colors.teal.shade50,
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
                    backgroundColor: Colors.teal,
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
    final provider = HealthProvider.of(context);

    // Hitung persentase target hidrasi air
    final target = provider.user.dailyWaterTargetMl;
    final double hydrationProgress =
        target > 0 ? (provider.currentWaterIntake / target).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${provider.userName}', style: const TextStyle(fontSize: 18)),
            Text(
              'Target: $target ml/hari • Buka: ke-${provider.visitCount}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Ganti Tema',
            onPressed: provider.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profil Kesehatan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileFormScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTips,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Card Pelacak Hidrasi Air Harian (Materi Pertemuan 4)
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
                            Icon(Icons.water_drop, color: Colors.blueAccent, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Pelacak Hidrasi Air',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          '${(hydrationProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: hydrationProgress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${provider.currentWaterIntake} ml / $target ml tercapai',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => provider.addWater(250),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('+ 250 ml'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => provider.addWater(500),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('+ 500 ml'),
                        ),
                        OutlinedButton(
                          onPressed: provider.resetWater,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Header Bagian REST API & Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tips Kesehatan Terkini (REST API)',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Input Pencarian Real-time (Latihan Modul 5)
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilter(),
                    decoration: InputDecoration(
                      hintText: 'Cari tips kesehatan...',
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

  Widget _buildTipsSection(HealthProvider provider) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Memuat tips kesehatan dari API...'),
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
              const Text('Tidak ada tips kesehatan yang cocok.'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _filteredTips.map((tip) {
        final tipIdStr = tip.id.toString();
        final isFav = provider.isFavorite(tipIdStr);

        return HealthTipCard(
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
