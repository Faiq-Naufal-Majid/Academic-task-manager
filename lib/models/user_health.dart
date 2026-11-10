/// Model entitas profil kesehatan pengguna.
///
/// Menyimpan informasi data kesehatan seperti berat badan, target asupan air,
/// serta preferensi pribadi dengan dukungan serialisasi Map untuk SharedPreferences.
class UserHealth {
  final String name;
  final String email;
  final int age;
  final double weight;
  final String gender;
  final String birthDate;
  final int dailyWaterTargetMl;

  UserHealth({
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.gender,
    required this.birthDate,
    this.dailyWaterTargetMl = 2000,
  });

  /// Mengonversi objek [UserHealth] ke bentuk Map untuk disimpan di SharedPreferences.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'weight': weight,
      'gender': gender,
      'birthDate': birthDate,
      'dailyWaterTargetMl': dailyWaterTargetMl,
    };
  }

  /// Membuat instance [UserHealth] dari data Map.
  factory UserHealth.fromMap(Map<String, dynamic> map) {
    return UserHealth(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] is int ? map['age'] : int.tryParse(map['age']?.toString() ?? '0') ?? 0,
      weight: map['weight'] is double
          ? map['weight']
          : double.tryParse(map['weight']?.toString() ?? '0.0') ?? 0.0,
      gender: map['gender'] ?? 'Laki-laki',
      birthDate: map['birthDate'] ?? '',
      dailyWaterTargetMl: map['dailyWaterTargetMl'] is int
          ? map['dailyWaterTargetMl']
          : int.tryParse(map['dailyWaterTargetMl']?.toString() ?? '2000') ?? 2000,
    );
  }

  /// Membuat salinan objek dengan sebagian data yang diperbarui.
  UserHealth copyWith({
    String? name,
    String? email,
    int? age,
    double? weight,
    String? gender,
    String? birthDate,
    int? dailyWaterTargetMl,
  }) {
    return UserHealth(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      dailyWaterTargetMl: dailyWaterTargetMl ?? this.dailyWaterTargetMl,
    );
  }
}
