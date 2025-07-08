/// Modelos para resposta a crises
class CrisisResponseData {

  CrisisResponseData({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.instructions = const [],
    this.metadata = const {},
    DateTime? timestamp,
    this.emergencyType = '',
    this.location,
    this.immediateActions = const [],
    this.resources = const [],
    this.contacts,
    this.descriptionCreole,
    this.immediateActionsCreole,
    this.resourcesCreole,
    this.titleCreole,
    this.warnings,
    this.warningsCreole,
    this.estimatedTime,
    this.aiAnalysis,
  }) : timestamp = timestamp ?? DateTime.now();

  factory CrisisResponseData.fromJson(Map<String, dynamic> json) => CrisisResponseData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'low',
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      emergencyType: json['emergencyType'] as String? ?? '',
      location: json['location'] as String?,
      immediateActions: (json['immediateActions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      resources: (json['resources'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      contacts: (json['contacts'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value.toString())),
      descriptionCreole: json['descriptionCreole'] as String?,
      immediateActionsCreole: (json['immediateActionsCreole'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      resourcesCreole: (json['resourcesCreole'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      titleCreole: json['titleCreole'] as String?,
      warnings: (json['warnings'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      warningsCreole: (json['warningsCreole'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      estimatedTime: json['estimatedTime'] as String?,
      aiAnalysis: json['aiAnalysis'] as Map<String, dynamic>?,
    );
  final String id;
  final String title;
  final String description;
  final String severity;
  final List<String> instructions;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  // Campos específicos para emergências
  final String emergencyType;
  final String? location;
  final List<String> immediateActions;
  final List<String> resources;
  final Map<String, String>? contacts;
  final String? descriptionCreole;
  final List<String>? immediateActionsCreole;
  final List<String>? resourcesCreole;

  // Campos adicionais usados nas telas
  final String? titleCreole;
  final List<String>? warnings;
  final List<String>? warningsCreole;
  final String? estimatedTime;
  final Map<String, dynamic>? aiAnalysis;

  Map<String, dynamic> toJson() => {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity,
      'instructions': instructions,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'emergencyType': emergencyType,
      if (location != null) 'location': location,
      'immediateActions': immediateActions,
      'resources': resources,
      if (contacts != null) 'contacts': contacts,
      if (descriptionCreole != null) 'descriptionCreole': descriptionCreole,
      if (immediateActionsCreole != null)
        'immediateActionsCreole': immediateActionsCreole,
      if (resourcesCreole != null) 'resourcesCreole': resourcesCreole,
      if (titleCreole != null) 'titleCreole': titleCreole,
      if (warnings != null) 'warnings': warnings,
      if (warningsCreole != null) 'warningsCreole': warningsCreole,
      if (estimatedTime != null) 'estimatedTime': estimatedTime,
      if (aiAnalysis != null) 'aiAnalysis': aiAnalysis,
    };
}
