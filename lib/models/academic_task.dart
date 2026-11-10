/// Model entitas tugas kuliah mahasiswa.
///
/// Menyimpan informasi tugas, mata kuliah, tenggat waktu (deadline),
/// tingkat prioritas, dan status penyelesaian dengan dukungan serialisasi Map.
class AcademicTask {
  final String id;
  final String title;
  final String course;
  final String deadline;
  final String priority;
  final bool isCompleted;

  AcademicTask({
    required this.id,
    required this.title,
    required this.course,
    required this.deadline,
    this.priority = 'Sedang',
    this.isCompleted = false,
  });

  /// Konversi objek ke Map untuk penyimpanan lokal (SharedPreferences).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'course': course,
      'deadline': deadline,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  /// Membuat instance [AcademicTask] dari Map.
  factory AcademicTask.fromMap(Map<String, dynamic> map) {
    return AcademicTask(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      course: map['course'] ?? '',
      deadline: map['deadline'] ?? '',
      priority: map['priority'] ?? 'Sedang',
      isCompleted: map['isCompleted'] == true,
    );
  }

  /// Salinan objek dengan atribut yang diperbarui.
  AcademicTask copyWith({
    String? id,
    String? title,
    String? course,
    String? deadline,
    String? priority,
    bool? isCompleted,
  }) {
    return AcademicTask(
      id: id ?? this.id,
      title: title ?? this.title,
      course: course ?? this.course,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
