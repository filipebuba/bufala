import 'package:flutter/foundation.dart';

/// Modelo para respostas do sistema AI Edge para detecção de doenças de plantas
class PlantDiseaseResult {
  PlantDiseaseResult({
    required this.success,
    required this.plantType, required this.diseaseDetected, required this.diseaseName, required this.confidence, required this.severity, required this.treatment, required this.prevention, required this.localName, required this.affectedAreas, required this.recommendations, this.error,
    this.metadata,
  });

  factory PlantDiseaseResult.fromJson(Map<String, dynamic> json) => PlantDiseaseResult(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      plantType: json['plantType'] as String? ?? '',
      diseaseDetected: json['diseaseDetected'] as bool? ?? false,
      diseaseName: json['diseaseName'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      severity: json['severity'] as String? ?? '',
      treatment: json['treatment'] as String? ?? '',
      prevention: json['prevention'] as String? ?? '',
      localName: json['localName'] as String? ?? '',
      affectedAreas: List<Map<String, dynamic>>.from(
          (json['affectedAreas'] as List?)
                  ?.map((x) => Map<String, dynamic>.from(x as Map)) ??
              []),
      recommendations: List<String>.from(
          (json['recommendations'] as List?)?.map((x) => x.toString()) ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

  final bool success;
  final String? error;
  final String plantType;
  final bool diseaseDetected;
  final String diseaseName;
  final double confidence;
  final String severity;
  final String treatment;
  final String prevention;
  final String localName;
  final List<Map<String, dynamic>> affectedAreas;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
      'success': success,
      'error': error,
      'plantType': plantType,
      'diseaseDetected': diseaseDetected,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'treatment': treatment,
      'prevention': prevention,
      'localName': localName,
      'affectedAreas': affectedAreas,
      'recommendations': recommendations,
      'metadata': metadata,
    };
}

/// Modelo para informações de espécies identificadas
class SpeciesInfo {
  SpeciesInfo({
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.conservationStatus,
    required this.localName,
    required this.description,
    required this.uses,
    this.additionalInfo,
  });

  factory SpeciesInfo.fromJson(Map<String, dynamic> json) => SpeciesInfo(
      name: json['name'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      conservationStatus: json['conservationStatus'] as String? ?? '',
      localName: json['localName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      uses: List<String>.from(
          (json['uses'] as List?)?.map((x) => x.toString()) ?? []),
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );

  final String name;
  final String scientificName;
  final double confidence;
  final String conservationStatus;
  final String localName;
  final String description;
  final List<String> uses;
  final Map<String, dynamic>? additionalInfo;

  Map<String, dynamic> toJson() => {
      'name': name,
      'scientificName': scientificName,
      'confidence': confidence,
      'conservationStatus': conservationStatus,
      'localName': localName,
      'description': description,
      'uses': uses,
      'additionalInfo': additionalInfo,
    };
}

/// Modelo para detecção de solo
class SoilAnalysis {
  SoilAnalysis({
    required this.success,
    required this.soilType, required this.ph, required this.nutrients, required this.moisture, required this.recommendations, this.error,
    this.metadata,
  });

  factory SoilAnalysis.fromJson(Map<String, dynamic> json) => SoilAnalysis(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      soilType: json['soilType'] as String? ?? '',
      ph: (json['ph'] as num?)?.toDouble() ?? 0.0,
      nutrients: Map<String, dynamic>.from(json['nutrients'] as Map? ?? {}),
      moisture: (json['moisture'] as num?)?.toDouble() ?? 0.0,
      recommendations: List<String>.from(
          (json['recommendations'] as List?)?.map((x) => x.toString()) ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

  final bool success;
  final String? error;
  final String soilType;
  final double ph;
  final Map<String, dynamic> nutrients;
  final double moisture;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
      'success': success,
      'error': error,
      'soilType': soilType,
      'ph': ph,
      'nutrients': nutrients,
      'moisture': moisture,
      'recommendations': recommendations,
      'metadata': metadata,
    };
}

/// Modelo para análise de culturas
class CropAnalysis {
  CropAnalysis({
    required this.success,
    required this.cropType, required this.growthStage, required this.health, required this.yield, required this.recommendations, required this.language, this.error,
    this.metadata,
  });

  factory CropAnalysis.fromJson(Map<String, dynamic> json) => CropAnalysis(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      cropType: json['cropType'] as String? ?? '',
      growthStage: json['growthStage'] as String? ?? '',
      health: (json['health'] as num?)?.toDouble() ?? 0.0,
      yield: (json['yield'] as num?)?.toDouble() ?? 0.0,
      recommendations: List<String>.from(
          (json['recommendations'] as List?)?.map((x) => x.toString()) ?? []),
      language: json['language'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

  final bool success;
  final String? error;
  final String cropType;
  final String growthStage;
  final double health;
  final double yield;
  final List<String> recommendations;
  final String language;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
      'success': success,
      'error': error,
      'cropType': cropType,
      'growthStage': growthStage,
      'health': health,
      'yield': yield,
      'recommendations': recommendations,
      'language': language,
      'metadata': metadata,
    };
}

/// Modelo para análise de pragas
class PestAnalysis {
  PestAnalysis({
    required this.success,
    required this.pestDetected, required this.pestType, required this.confidence, required this.severity, required this.treatment, required this.prevention, required this.localName, required this.recommendations, this.error,
    this.metadata,
  });

  factory PestAnalysis.fromJson(Map<String, dynamic> json) => PestAnalysis(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      pestDetected: json['pestDetected'] as bool? ?? false,
      pestType: json['pestType'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      severity: json['severity'] as String? ?? '',
      treatment: json['treatment'] as String? ?? '',
      prevention: json['prevention'] as String? ?? '',
      localName: json['localName'] as String? ?? '',
      recommendations: List<String>.from(
          (json['recommendations'] as List?)?.map((x) => x.toString()) ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

  final bool success;
  final String? error;
  final bool pestDetected;
  final String pestType;
  final double confidence;
  final String severity;
  final String treatment;
  final String prevention;
  final String localName;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
      'success': success,
      'error': error,
      'pestDetected': pestDetected,
      'pestType': pestType,
      'confidence': confidence,
      'severity': severity,
      'treatment': treatment,
      'prevention': prevention,
      'localName': localName,
      'recommendations': recommendations,
      'metadata': metadata,
    };
}

/// Modelo para análise multimodal
class MultiModalAnalysis {
  MultiModalAnalysis({
    required this.success,
    required this.analysisType, required this.results, required this.confidence, required this.recommendations, required this.language, this.error,
    this.metadata,
  });

  factory MultiModalAnalysis.fromJson(Map<String, dynamic> json) => MultiModalAnalysis(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      analysisType: json['analysisType'] as String? ?? '',
      results: Map<String, dynamic>.from(json['results'] as Map? ?? {}),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      recommendations: List<String>.from(
          (json['recommendations'] as List?)?.map((x) => x.toString()) ?? []),
      language: json['language'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

  final bool success;
  final String? error;
  final String analysisType;
  final Map<String, dynamic> results;
  final double confidence;
  final List<String> recommendations;
  final String language;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
      'success': success,
      'error': error,
      'analysisType': analysisType,
      'results': results,
      'confidence': confidence,
      'recommendations': recommendations,
      'language': language,
      'metadata': metadata,
    };
}

/// Configuração do modelo AI Edge
class AIEdgeConfiguration {
  AIEdgeConfiguration({
    required this.modelName,
    required this.version,
    required this.language,
    required this.offlineMode,
    required this.cacheEnabled,
    required this.qualityThreshold,
    required this.maxProcessingTime,
    required this.supportedLanguages,
    this.customSettings,
  });

  factory AIEdgeConfiguration.fromJson(Map<String, dynamic> json) => AIEdgeConfiguration(
      modelName: json['modelName'] as String? ?? '',
      version: json['version'] as String? ?? '',
      language: json['language'] as String? ?? '',
      offlineMode: json['offlineMode'] as bool? ?? false,
      cacheEnabled: json['cacheEnabled'] as bool? ?? false,
      qualityThreshold: (json['qualityThreshold'] as num?)?.toDouble() ?? 0.0,
      maxProcessingTime: json['maxProcessingTime'] as int? ?? 0,
      supportedLanguages: List<String>.from(
          (json['supportedLanguages'] as List?)?.map((x) => x.toString()) ??
              []),
      customSettings: json['customSettings'] as Map<String, dynamic>?,
    );

  final String modelName;
  final String version;
  final String language;
  final bool offlineMode;
  final bool cacheEnabled;
  final double qualityThreshold;
  final int maxProcessingTime;
  final List<String> supportedLanguages;
  final Map<String, dynamic>? customSettings;

  Map<String, dynamic> toJson() => {
      'modelName': modelName,
      'version': version,
      'language': language,
      'offlineMode': offlineMode,
      'cacheEnabled': cacheEnabled,
      'qualityThreshold': qualityThreshold,
      'maxProcessingTime': maxProcessingTime,
      'supportedLanguages': supportedLanguages,
      'customSettings': customSettings,
    };
}

/// Modelo base para respostas de AI Edge
abstract class AIEdgeResponse {
  const AIEdgeResponse({
    required this.success,
    this.error,
    this.metadata,
  });

  final bool success;
  final String? error;
  final Map<String, dynamic>? metadata;
}

/// Status e configuração do modelo
class ModelStatus {
  const ModelStatus({
    required this.isLoaded,
    required this.version,
    required this.lastUpdated,
    required this.performance,
    required this.supportedFeatures,
  });

  final bool isLoaded;
  final String version;
  final DateTime lastUpdated;
  final Map<String, double> performance;
  final List<String> supportedFeatures;
}

/// Configuração para cache offline
class OfflineCacheConfig {
  const OfflineCacheConfig({
    required this.enabled,
    required this.maxSize,
    required this.ttl,
    required this.compressionEnabled,
  });

  final bool enabled;
  final int maxSize;
  final Duration ttl;
  final bool compressionEnabled;
}

/// Interface para modelos personalizados
abstract class CustomModel {
  String get name;
  String get version;
  Future<Map<String, dynamic>> processImage(Uint8List imageData);
  Future<Map<String, dynamic>> processText(String text);
}
