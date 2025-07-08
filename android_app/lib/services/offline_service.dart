import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class OfflineService {
  factory OfflineService() => _instance;
  OfflineService._internal();
  static const String _offlineDataBox = 'offline_data';
  static const String _syncQueueBox = 'sync_queue';

  late Box _offlineBox;
  late Box _syncBox;
  bool _isInitialized = false;

  // Singleton pattern
  static final OfflineService _instance = OfflineService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _offlineBox = await Hive.openBox(_offlineDataBox);
      _syncBox = await Hive.openBox(_syncQueueBox);
      _isInitialized = true;
      debugPrint('OfflineService inicializado com sucesso');
    } catch (e) {
      debugPrint('Erro ao inicializar OfflineService: $e');
    }
  }

  Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Erro ao verificar conectividade: $e');
      return false;
    }
  }

  Stream<ConnectivityResult> get connectivityStream =>
      Connectivity().onConnectivityChanged;

  // Salvar dados offline
  Future<void> saveOfflineData(String key, Map<String, dynamic> data) async {
    if (!_isInitialized) await initialize();

    try {
      final jsonData = json.encode(data);
      await _offlineBox.put(key, jsonData);
      debugPrint('Dados salvos offline: $key');
    } catch (e) {
      debugPrint('Erro ao salvar dados offline: $e');
    }
  }

  // Recuperar dados offline
  Map<String, dynamic>? getOfflineData(String key) {
    if (!_isInitialized) return null;

    try {
      final jsonData = _offlineBox.get(key);
      if (jsonData != null && jsonData is String) {
        return json.decode(jsonData) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Erro ao recuperar dados offline: $e');
    }
    return null;
  }

  // Adicionar à fila de sincronização
  Future<void> addToSyncQueue(String action, Map<String, dynamic> data) async {
    if (!_isInitialized) await initialize();

    try {
      final syncItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'action': action,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _syncBox.add(json.encode(syncItem));
      debugPrint('Item adicionado à fila de sincronização: $action');
    } catch (e) {
      debugPrint('Erro ao adicionar à fila de sincronização: $e');
    }
  }

  // Processar fila de sincronização
  Future<void> processSyncQueue() async {
    if (!_isInitialized) await initialize();

    final isOnline = await isConnected();
    if (!isOnline) {
      debugPrint('Sem conexão - sincronização adiada');
      return;
    }

    try {
      final keys = _syncBox.keys.toList();

      for (final key in keys) {
        final jsonData = _syncBox.get(key);
        if (jsonData != null && jsonData is String) {
          final syncItem = json.decode(jsonData) as Map<String, dynamic>;

          // Aqui você implementaria a lógica específica de sincronização
          // baseada no 'action' do item
          final success = await _processSyncItem(syncItem);

          if (success) {
            await _syncBox.delete(key);
            debugPrint(
                'Item sincronizado e removido da fila: ${syncItem['action']}');
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao processar fila de sincronização: $e');
    }
  }

  Future<bool> _processSyncItem(Map<String, dynamic> syncItem) async {
    try {
      final action = syncItem['action'] as String;
      final data = syncItem['data'] as Map<String, dynamic>;

      // Implementar lógica específica baseada na ação
      switch (action) {
        case 'save_emergency_data':
          return await _syncEmergencyData(data);
        case 'save_medical_data':
          return await _syncMedicalData(data);
        case 'save_education_data':
          return await _syncEducationData(data);
        case 'save_agriculture_data':
          return await _syncAgricultureData(data);
        default:
          debugPrint('Ação de sincronização desconhecida: $action');
          return false;
      }
    } catch (e) {
      debugPrint('Erro ao processar item de sincronização: $e');
      return false;
    }
  }

  Future<bool> _syncEmergencyData(Map<String, dynamic> data) async {
    // Implementar sincronização de dados de emergência
    debugPrint('Sincronizando dados de emergência: $data');
    return true; // Placeholder
  }

  Future<bool> _syncMedicalData(Map<String, dynamic> data) async {
    // Implementar sincronização de dados médicos
    debugPrint('Sincronizando dados médicos: $data');
    return true; // Placeholder
  }

  Future<bool> _syncEducationData(Map<String, dynamic> data) async {
    // Implementar sincronização de dados educacionais
    debugPrint('Sincronizando dados educacionais: $data');
    return true; // Placeholder
  }

  Future<bool> _syncAgricultureData(Map<String, dynamic> data) async {
    // Implementar sincronização de dados agrícolas
    debugPrint('Sincronizando dados agrícolas: $data');
    return true; // Placeholder
  }

  // Limpar dados offline antigos
  Future<void> clearOldOfflineData({int daysOld = 30}) async {
    if (!_isInitialized) await initialize();

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final keys = _offlineBox.keys.toList();

      for (final key in keys) {
        final data = getOfflineData(key.toString());
        if (data != null &&
            data['timestamp'] != null &&
            data['timestamp'] is String) {
          final timestamp = DateTime.parse(data['timestamp'] as String);
          if (timestamp.isBefore(cutoffDate)) {
            await _offlineBox.delete(key);
            debugPrint('Dados offline antigos removidos: $key');
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao limpar dados offline antigos: $e');
    }
  }

  // Obter estatísticas de armazenamento offline
  Map<String, int> getStorageStats() {
    if (!_isInitialized) return {'offline_items': 0, 'sync_queue_items': 0};

    return {
      'offline_items': _offlineBox.length,
      'sync_queue_items': _syncBox.length,
    };
  }

  // Limpar todos os dados offline
  Future<void> clearAllOfflineData() async {
    if (!_isInitialized) await initialize();

    try {
      await _offlineBox.clear();
      await _syncBox.clear();
      debugPrint('Todos os dados offline foram limpos');
    } catch (e) {
      debugPrint('Erro ao limpar dados offline: $e');
    }
  }
}
