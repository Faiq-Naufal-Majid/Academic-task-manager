import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_config.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/secure_storage_service.dart';

/// Entry point aplikasi Manajemen Tugas & Akademik Mahasiswa.
///
/// Menginisialisasi environment variable (.env) serta memeriksa kredensial awal (Pertemuan 6).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat file konfigurasi .env
  await dotenv.load(fileName: ".env");

  // Validasi konfigurasi sistem
  if (!AppConfig.isConfigured()) {
    print('Peringatan: Konfigurasi di file .env belum lengkap.');
  }

  // Cek token autentikasi mahasiswa dari Secure Storage (Pertemuan 5)
  final secureStorage = SecureStorageService();
  final bool isLoggedIn = await secureStorage.hasToken();

  runApp(
    TaskProviderWrapper(
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // Mengakses preferensi tema dari TaskProvider (Pertemuan 4)
    final provider = TaskProvider.of(context);

    return MaterialApp(
      title: 'Academic Task Manager',
      debugShowCheckedModeBanner: false,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
