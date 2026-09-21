class LeetCodeQuestionModel {
  final String id;
  final String title;
  final String difficulty;
  final String link;
  final double frequency;
  final String acceptanceRate;
  final List<String> topics;
  final String company;

  LeetCodeQuestionModel({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.link,
    required this.frequency,
    required this.acceptanceRate,
    required this.topics,
    required this.company,
  });

  factory LeetCodeQuestionModel.fromJson(Map<String, dynamic> json) {
    return LeetCodeQuestionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      difficulty: json['difficulty'] ?? 'MEDIUM',
      link: json['link'] ?? '',
      frequency: (json['frequency'] as num?)?.toDouble() ?? 0.0,
      acceptanceRate: json['acceptance_rate'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      company: json['company'] ?? '',
    );
  }
}
