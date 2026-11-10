/// Model data profil akademik mahasiswa.
///
/// Menyimpan data identitas mahasiswa (Nama, NIM, Program Studi, Semester, Target SKS)
/// yang disimpan secara persisten di SharedPreferences (Pertemuan 4).
class StudentProfile {
  final String name;
  final String nim;
  final String email;
  final String prodi;
  final int semester;
  final int targetSks;

  StudentProfile({
    required this.name,
    required this.nim,
    required this.email,
    required this.prodi,
    required this.semester,
    required this.targetSks,
  });

  /// Konversi data profil ke Map untuk disimpan di SharedPreferences.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nim': nim,
      'email': email,
      'prodi': prodi,
      'semester': semester,
      'targetSks': targetSks,
    };
  }

  /// Membuat instance [StudentProfile] dari data Map SharedPreferences.
  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      name: map['name'] ?? '',
      nim: map['nim'] ?? '',
      email: map['email'] ?? '',
      prodi: map['prodi'] ?? 'Informatika',
      semester: map['semester'] is int
          ? map['semester']
          : int.tryParse(map['semester']?.toString() ?? '4') ?? 4,
      targetSks: map['targetSks'] is int
          ? map['targetSks']
          : int.tryParse(map['targetSks']?.toString() ?? '20') ?? 20,
    );
  }

  /// Salinan objek untuk pembaruan profil sebagian.
  StudentProfile copyWith({
    String? name,
    String? nim,
    String? email,
    String? prodi,
    int? semester,
    int? targetSks,
  }) {
    return StudentProfile(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      email: email ?? this.email,
      prodi: prodi ?? this.prodi,
      semester: semester ?? this.semester,
      targetSks: targetSks ?? this.targetSks,
    );
  }
}
