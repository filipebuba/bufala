import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  
  AppProvider() {
    _loadPreferences();
  }
  String _currentLanguage = 'pt';
  bool _isOfflineMode = false;
  bool _isDarkMode = false;
  bool _autoSync = true;
  
  String get currentLanguage => _currentLanguage;
  bool get isOfflineMode => _isOfflineMode;
  bool get isDarkMode => _isDarkMode;
  bool get autoSync => _autoSync;
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('language') ?? 'pt';
      _isOfflineMode = prefs.getBool('offline_mode') ?? false;
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _autoSync = prefs.getBool('auto_sync') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar preferências: $e');
    }
  }
  
  Future<void> setLanguage(String language) async {
    try {
      _currentLanguage = language;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar idioma: $e');
    }
  }
  
  Future<void> setOfflineMode(bool isOffline) async {
    try {
      _isOfflineMode = isOffline;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('offline_mode', isOffline);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar modo offline: $e');
    }
  }
  
  Future<void> setDarkMode(bool isDark) async {
    try {
      _isDarkMode = isDark;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', isDark);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar modo escuro: $e');
    }
  }
  
  Future<void> setAutoSync(bool autoSync) async {
    try {
      _autoSync = autoSync;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_sync', autoSync);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar sincronização automática: $e');
    }
  }
  
  void toggleOfflineMode() {
    setOfflineMode(!_isOfflineMode);
  }
  
  void toggleDarkMode() {
    setDarkMode(!_isDarkMode);
  }
  
  void toggleAutoSync() {
    setAutoSync(!_autoSync);
  }
}

