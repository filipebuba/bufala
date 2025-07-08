/// Modelos para conteúdo de aprendizado offline
class OfflineLearningContent {

  OfflineLearningContent({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.subject,
    required this.languages,
    required this.level,
    required this.type,
    required this.metadata,
    required this.createdAt,
  });

  factory OfflineLearningContent.fromJson(Map<String, dynamic> json) => OfflineLearningContent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      description: json['description'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      level: json['level'] as String? ?? 'beginner',
      type: json['type'] as String? ?? 'text',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  final String id;
  final String title;
  final String content;
  final String description;
  final String subject;
  final List<String> languages;
  final String level;
  final String type;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
      'id': id,
      'title': title,
      'content': content,
      'description': description,
      'subject': subject,
      'languages': languages,
      'level': level,
      'type': type,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
}
