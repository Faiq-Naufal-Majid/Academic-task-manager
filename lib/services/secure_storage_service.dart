import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service untuk mengelola penyimpanan data sensitif (token otentikasi & PIN kesehatan).
///
/// Menggunakan enkripsi AES-256 via [FlutterSecureStorage] pada Android (EncryptedSharedPreferences)
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

  static const String _tokenKey = 'auth_token';
  static const String _pinKey = 'user_pin';

  /// Menyimpan token otentikasi secara terenkripsi.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // Logging aman (Safe Logging): TIDAK mencetak isi token
    print('Token autentikasi berhasil disimpan ke secure storage.');
  }

  /// Membaca token otentikasi dari secure storage.
  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    // Logging aman: hanya status keberadaan token
    print(token != null ? 'Token ditemukan' : 'Token tidak ditemukan');
    return token;
  }

  /// Menghapus token (digunakan saat logout).
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    print('Token berhasil dihapus dari secure storage.');
  }

  /// Memeriksa apakah token otentikasi sudah tersimpan.
  Future<bool> hasToken() async {
    return await _storage.containsKey(key: _tokenKey);
  }

  /// Menyimpan PIN keamanan pengguna.
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    print('PIN keamanan berhasil disimpan.');
  }

  /// Membaca PIN keamanan pengguna.
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  /// Menghapus seluruh data di secure storage.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
    print('Semua data aman berhasil dibersihkan.');
  }
}
