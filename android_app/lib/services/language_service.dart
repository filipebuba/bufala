import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String defaultLanguage = 'pt';
  
  // Idiomas suportados
  static const Map<String, String> supportedLanguages = {
    'pt': 'Português',
    'en': 'English',
    'fr': 'Français',
    'crioulo': 'Kriol (Crioulo)',
  };
  
  // Traduções básicas
  static const Map<String, Map<String, String>> translations = {
    'pt': {
      'app_title': 'Bu Fala',
      'home': 'Início',
      'emergency': 'Emergência',
      'medical': 'Médico',
      'education': 'Educação',
      'agriculture': 'Agricultura',
      'settings': 'Configurações',
      'offline_mode': 'Modo Offline',
      'language': 'Idioma',
      'dark_mode': 'Modo Escuro',
      'emergency_call': 'Chamada de Emergência',
      'first_aid': 'Primeiros Socorros',
      'medical_guide': 'Guia Médico',
      'pregnancy_care': 'Cuidados na Gravidez',
      'learning_materials': 'Materiais de Aprendizagem',
      'offline_content': 'Conteúdo Offline',
      'crop_protection': 'Proteção de Culturas',
      'farming_tips': 'Dicas de Agricultura',
      'weather_info': 'Informações do Tempo',
      'connecting': 'Conectando...',
      'offline': 'Offline',
      'online': 'Online',
    },
    'en': {
      'app_title': 'Bu Fala',
      'home': 'Home',
      'emergency': 'Emergency',
      'medical': 'Medical',
      'education': 'Education',
      'agriculture': 'Agriculture',
      'settings': 'Settings',
      'offline_mode': 'Offline Mode',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'emergency_call': 'Emergency Call',
      'first_aid': 'First Aid',
      'medical_guide': 'Medical Guide',
      'pregnancy_care': 'Pregnancy Care',
      'learning_materials': 'Learning Materials',
      'offline_content': 'Offline Content',
      'crop_protection': 'Crop Protection',
      'farming_tips': 'Farming Tips',
      'weather_info': 'Weather Information',
      'connecting': 'Connecting...',
      'offline': 'Offline',
      'online': 'Online',
    },
    'fr': {
      'app_title': 'Bu Fala',
      'home': 'Accueil',
      'emergency': 'Urgence',
      'medical': 'Médical',
      'education': 'Éducation',
      'agriculture': 'Agriculture',
      'settings': 'Paramètres',
      'offline_mode': 'Mode Hors Ligne',
      'language': 'Langue',
      'dark_mode': 'Mode Sombre',
      'emergency_call': 'Appel d\'Urgence',
      'first_aid': 'Premiers Secours',
      'medical_guide': 'Guide Médical',
      'pregnancy_care': 'Soins de Grossesse',
      'learning_materials': 'Matériel d\'Apprentissage',
      'offline_content': 'Contenu Hors Ligne',
      'crop_protection': 'Protection des Cultures',
      'farming_tips': 'Conseils Agricoles',
      'weather_info': 'Informations Météo',
      'connecting': 'Connexion...',
      'offline': 'Hors Ligne',
      'online': 'En Ligne',
    },
    'crioulo': {
      'app_title': 'Bu Fala',
      'home': 'Kasa',
      'emergency': 'Urgensia',
      'medical': 'Mediku',
      'education': 'Skola',
      'agriculture': 'Agricultura',
      'settings': 'Konfigurasaun',
      'offline_mode': 'Modu Offline',
      'language': 'Lingua',
      'dark_mode': 'Modu Skuru',
      'emergency_call': 'Chamada Urgensia',
      'first_aid': 'Primeiru Sokoru',
      'medical_guide': 'Guia Mediku',
      'pregnancy_care': 'Kuidadu Gravidez',
      'learning_materials': 'Material Aprendizajen',
      'offline_content': 'Konteúdu Offline',
      'crop_protection': 'Protesaun Kultura',
      'farming_tips': 'Dika Agricultura',
      'weather_info': 'Informasaun Tempu',
      'connecting': 'Konektandu...',
      'offline': 'Offline',
      'online': 'Online',
    },
  };
  
  Future<String> getCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? defaultLanguage;
    } catch (e) {
      debugPrint('Erro ao obter idioma atual: $e');
      return defaultLanguage;
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Erro ao salvar idioma: $e');
    }
  }
  
  String translate(String key, [String? languageCode]) {
    final language = languageCode ?? defaultLanguage;
    return translations[language]?[key] ?? translations[defaultLanguage]?[key] ?? key;
  }
  
  Map<String, String> getTranslations(String languageCode) => translations[languageCode] ?? translations[defaultLanguage]!;
  
  bool isLanguageSupported(String languageCode) => supportedLanguages.containsKey(languageCode);
  
  List<String> getSupportedLanguageCodes() => supportedLanguages.keys.toList();
  
  String getLanguageName(String languageCode) => supportedLanguages[languageCode] ?? languageCode;
}

