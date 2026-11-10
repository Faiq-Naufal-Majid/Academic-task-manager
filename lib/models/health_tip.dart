/// Model representasi data tips kesehatan yang diambil dari REST API.
class HealthTip {
  final int id;
  final String title;
  final String body;
  final List<String> tags;

  HealthTip({
    required this.id,
    required this.title,
    required this.body,
    this.tags = const [],
  });

  /// Factory method untuk parsing data JSON dari REST API.
  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'].map((t) => t.toString()))
          : <String>[],
    );
  }
}
