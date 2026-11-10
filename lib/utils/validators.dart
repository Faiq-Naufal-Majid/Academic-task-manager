/// Utility kelas untuk validasi form dan sanitasi input (Pertemuan 3 & 6).
///
/// Mencegah input tidak valid serta melindungi dari potensi serangan XSS.
class Validators {
  /// Validasi format email menggunakan Regular Expression.
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email.trim());
  }

  /// Sanitasi input teks untuk mencegah injeksi script berbahaya (XSS).
  static String sanitize(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .trim();
  }

  /// Validasi field teks wajib diisi.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Validasi format email lengkap untuk TextFormField.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    if (!isValidEmail(value)) {
      return 'Format email tidak valid (contoh: user@mail.com)';
    }
    return null;
  }

  /// Validasi password sesuai modul: min 8 karakter, huruf kapital, dan angka.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf kapital';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  /// Validasi konfirmasi password apakah cocok.
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != originalPassword) {
      return 'Password konfirmasi tidak cocok';
    }
    return null;
  }

  /// Validasi nomor telepon (10-13 digit angka - Latihan 1 Pertemuan 3).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Nomor telepon harus 10-13 digit angka';
    }
    return null;
  }

  /// Validasi angka bulat atau desimal positif.
  static String? validateNumber(String? value, String fieldName, {bool isInteger = false}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    if (isInteger) {
      final parsed = int.tryParse(value.trim());
      if (parsed == null || parsed <= 0) {
        return '$fieldName harus berupa angka bulat positif';
      }
    } else {
      final parsed = double.tryParse(value.trim());
      if (parsed == null || parsed <= 0) {
        return '$fieldName harus berupa angka valid';
      }
    }
    return null;
  }

  /// Menghitung skor kekuatan password (Latihan 5 Pertemuan 3).
  ///
  /// Mengembalikan nilai skor 0.0 - 1.0 (Lemah, Sedang, Kuat).
  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 8) strength += 0.35;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength += 0.15;
    return strength.clamp(0.0, 1.0);
  }
}
