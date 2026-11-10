import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_config.dart';
import 'providers/health_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/secure_storage_service.dart';

/// Entry point aplikasi Health & Hydration Tracker.
///
/// Menginisialisasi environment variable (.env) serta mengecek konfigurasi sebelum aplikasi berjalan (Pertemuan 6).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat file konfigurasi .env
  await dotenv.load(fileName: ".env");

  // Validasi konfigurasi sistem
  if (!AppConfig.isConfigured()) {
    print('Peringatan: Konfigurasi di file .env belum lengkap.');
  }

  // Cek keberadaan token otentikasi di Secure Storage (Pertemuan 5)
  final secureStorage = SecureStorageService();
  final bool isLoggedIn = await secureStorage.hasToken();

  runApp(
    HealthProviderWrapper(
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // Mengakses state tema dari HealthProvider (Pertemuan 4)
    final provider = HealthProvider.of(context);

    return MaterialApp(
      title: 'Health & Hydration Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
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
          seedColor: Colors.teal,
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
