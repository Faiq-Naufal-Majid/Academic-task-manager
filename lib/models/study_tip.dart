/// Model representasi data artikel tips belajar & produktivitas dari REST API.
class StudyTip {
  final int id;
  final String title;
  final String body;
  final List<String> tags;

  StudyTip({
    required this.id,
    required this.title,
    required this.body,
    this.tags = const [],
  });

  /// Factory constructor untuk parsing JSON dari response REST API.
  factory StudyTip.fromJson(Map<String, dynamic> json) {
    return StudyTip(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'].map((t) => t.toString()))
          : <String>[],
    );
  }
}
