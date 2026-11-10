import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_health.dart';

/// Provider menggunakan [InheritedWidget] untuk berbagi state kesehatan
/// ke seluruh widget tree tanpa perlu prop drilling (Materi Pertemuan 4).
class HealthProvider extends InheritedWidget {
  final UserHealth user;
  final int currentWaterIntake;
  final bool isDarkMode;
  final int visitCount;
  final List<String> favoriteTipIds;
  final Function(int) addWater;
  final VoidCallback resetWater;
  final VoidCallback toggleTheme;
  final Function(UserHealth) updateProfile;
  final Function(String) toggleFavorite;

  const HealthProvider({
    super.key,
    required this.user,
    required this.currentWaterIntake,
    required this.isDarkMode,
    required this.visitCount,
    required this.favoriteTipIds,
    required this.addWater,
    required this.resetWater,
    required this.toggleTheme,
    required this.updateProfile,
    required this.toggleFavorite,
    required super.child,
  });

  /// Getter helper untuk nama pengguna.
  String get userName => user.name.isNotEmpty ? user.name : 'Tamu Sehat';

  /// Getter helper untuk email pengguna.
  String get userEmail => user.email.isNotEmpty ? user.email : 'Belum diatur';

  /// Memeriksa apakah suatu tips kesehatan berstatus favorit.
  bool isFavorite(String tipId) => favoriteTipIds.contains(tipId);

  /// Method static untuk mendapatkan instance [HealthProvider] dari context.
  static HealthProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<HealthProvider>();
    assert(provider != null, 'HealthProvider tidak ditemukan di context');
    return provider!;
  }

  @override
  bool updateShouldNotify(HealthProvider oldWidget) {
    return oldWidget.user != user ||
        oldWidget.currentWaterIntake != currentWaterIntake ||
        oldWidget.isDarkMode != isDarkMode ||
        oldWidget.visitCount != visitCount ||
        oldWidget.favoriteTipIds != favoriteTipIds;
  }
}

/// StatefulWidget pembungkus [HealthProvider] yang memanajemen logika state
/// dan penyimpanan persisten via [SharedPreferences] (Materi Pertemuan 4).
class HealthProviderWrapper extends StatefulWidget {
  final Widget child;
  const HealthProviderWrapper({super.key, required this.child});

  @override
  State<HealthProviderWrapper> createState() => _HealthProviderWrapperState();
}

class _HealthProviderWrapperState extends State<HealthProviderWrapper> {
  UserHealth _user = UserHealth(
    name: 'Budi Santoso',
    email: 'budi@example.com',
    age: 22,
    weight: 65.0,
    gender: 'Laki-laki',
    birthDate: '2004-05-12',
    dailyWaterTargetMl: 2000,
  );

  int _currentWaterIntake = 0;
  bool _isDarkMode = false;
  int _visitCount = 1;
  List<String> _favoriteTipIds = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Memuat preferensi dan profil dari [SharedPreferences].
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('user_name') ?? _user.name;
    final email = prefs.getString('user_email') ?? _user.email;
    final age = prefs.getInt('user_age') ?? _user.age;
    final weight = prefs.getDouble('user_weight') ?? _user.weight;
    final gender = prefs.getString('user_gender') ?? _user.gender;
    final birthDate = prefs.getString('user_birth_date') ?? _user.birthDate;
    final waterTarget = prefs.getInt('daily_water_target') ?? _user.dailyWaterTargetMl;

    final waterIntake = prefs.getInt('water_intake') ?? 0;
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    final visitCount = (prefs.getInt('visit_count') ?? 0) + 1;
    final favorites = prefs.getStringList('favorite_tips') ?? [];

    // Update visit count secara persisten
    await prefs.setInt('visit_count', visitCount);

    setState(() {
      _user = UserHealth(
        name: name,
        email: email,
        age: age,
        weight: weight,
        gender: gender,
        birthDate: birthDate,
        dailyWaterTargetMl: waterTarget,
      );
      _currentWaterIntake = waterIntake;
      _isDarkMode = isDarkMode;
      _visitCount = visitCount;
      _favoriteTipIds = favorites;
    });
  }

  /// Menambah asupan air dan menyimpannya ke [SharedPreferences].
  Future<void> _addWater(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentWaterIntake += amount;
    });
    await prefs.setInt('water_intake', _currentWaterIntake);
  }

  /// Mereset asupan air kembali ke 0.
  Future<void> _resetWater() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentWaterIntake = 0;
    });
    await prefs.setInt('water_intake', 0);
  }

  /// Toggle tema Light/Dark Mode (Latihan 1 Pertemuan 4).
  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }

  /// Menyimpan dan memperbarui profil pengguna ke [SharedPreferences].
  Future<void> _updateProfile(UserHealth newUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setInt('user_age', newUser.age);
    await prefs.setDouble('user_weight', newUser.weight);
    await prefs.setString('user_gender', newUser.gender);
    await prefs.setString('user_birth_date', newUser.birthDate);
    await prefs.setInt('daily_water_target', newUser.dailyWaterTargetMl);

    setState(() {
      _user = newUser;
    });
  }

  /// Toggle item favorit tips kesehatan (Latihan 3 Pertemuan 4).
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
    return HealthProvider(
      user: _user,
      currentWaterIntake: _currentWaterIntake,
      isDarkMode: _isDarkMode,
      visitCount: _visitCount,
      favoriteTipIds: _favoriteTipIds,
      addWater: _addWater,
      resetWater: _resetWater,
      toggleTheme: _toggleTheme,
      updateProfile: _updateProfile,
      toggleFavorite: _toggleFavorite,
      child: widget.child,
    );
  }
}
