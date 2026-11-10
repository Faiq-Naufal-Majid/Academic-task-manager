import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service untuk mengelola penyimpanan data sensitif akun mahasiswa (Auth Token & PIN).
///
/// Menggunakan enkripsi AES-256 via [FlutterSecureStorage] pada Android Keystore
/// dan Keychain Services pada iOS (Materi Pertemuan 5).
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _tokenKey = 'student_auth_token';
  static const String _pinKey = 'student_secure_pin';

  /// Menyimpan token autentikasi mahasiswa secara terenkripsi.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // Logging aman (Safe Logging): TIDAK mencetak token/plaintext rahasia
    print('Token sesi mahasiswa berhasil disimpan secara aman.');
  }

  /// Membaca token autentikasi mahasiswa.
  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    print(token != null ? 'Token sesi valid ditemukan.' : 'Token sesi tidak ditemukan.');
    return token;
  }

  /// Menghapus token (digunakan saat logout).
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    print('Token sesi mahasiswa berhasil dihapus dari secure storage.');
  }

  /// Memeriksa status keberadaan token autentikasi.
  Future<bool> hasToken() async {
    return await _storage.containsKey(key: _tokenKey);
  }

  /// Menyimpan PIN keamanan mahasiswa.
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    print('PIN keamanan akun berhasil diperbarui.');
  }

  /// Membaca PIN keamanan mahasiswa.
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  /// Menghapus semua data sensitif di secure storage.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
    print('Seluruh data aman berhasil dibersihkan.');
  }
}
