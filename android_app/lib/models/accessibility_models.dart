class VoiceToTextResult {

  VoiceToTextResult({
    required this.success,
    required this.text,
    this.error,
    this.isListening,
  });

  factory VoiceToTextResult.fromJson(Map<String, dynamic> json) => VoiceToTextResult(
      success: json['success'] as bool? ?? false,
      text: json['text'] as String? ?? '',
      error: json['error'] as String?,
      isListening: json['isListening'] as bool?,
    );
  final bool success;
  final String text;
  final String? error;
  final bool? isListening;

  Map<String, dynamic> toJson() => {
      'success': success,
      'text': text,
      'error': error,
      'isListening': isListening,
    };
}

class TextToSpeechResult {

  TextToSpeechResult({
    required this.success,
    required this.text,
    this.error,
  });

  factory TextToSpeechResult.fromJson(Map<String, dynamic> json) => TextToSpeechResult(
      success: json['success'] as bool? ?? false,
      text: json['text'] as String? ?? '',
      error: json['error'] as String?,
    );
  final bool success;
  final String text;
  final String? error;

  Map<String, dynamic> toJson() => {
      'success': success,
      'text': text,
      'error': error,
    };
}

class VisualDescriptionResult {

  VisualDescriptionResult({
    required this.success,
    required this.description,
    this.error,
    this.confidence,
  });

  factory VisualDescriptionResult.fromJson(Map<String, dynamic> json) => VisualDescriptionResult(
      success: json['success'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      error: json['error'] as String?,
      confidence: json['confidence'] as double?,
    );
  final bool success;
  final String description;
  final String? error;
  final double? confidence;

  Map<String, dynamic> toJson() => {
      'success': success,
      'description': description,
      'error': error,
      'confidence': confidence,
    };
}

class AccessibilityIssue {

  AccessibilityIssue({
    required this.type,
    required this.severity,
    required this.description,
  });

  factory AccessibilityIssue.fromJson(Map<String, dynamic> json) => AccessibilityIssue(
      type: json['type'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  final String type;
  final String severity;
  final String description;

  Map<String, dynamic> toJson() => {
      'type': type,
      'severity': severity,
      'description': description,
    };
}

class AccessibilityAnalysisResult {

  AccessibilityAnalysisResult({required this.issues});

  factory AccessibilityAnalysisResult.fromJson(Map<String, dynamic> json) => AccessibilityAnalysisResult(
      issues: (json['issues'] as List<dynamic>?)
              ?.map(
                  (e) => AccessibilityIssue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  final List<AccessibilityIssue> issues;

  Map<String, dynamic> toJson() => {
      'issues': issues.map((e) => e.toJson()).toList(),
    };
}
