import 'dart:async';

abstract class IStorageService {
  Future<void> save(String key, dynamic value);
  Future<dynamic> load(String key);
}

class StorageService implements IStorageService {

  factory StorageService() => _instance;

  StorageService._internal();
  static final StorageService _instance = StorageService._internal();

  final Map<String, dynamic> _storage = {};

  @override
  Future<void> save(String key, dynamic value) async {
    _storage[key] = value;
  }

  @override
  Future<dynamic> load(String key) async => _storage[key];
  
  Future<Map<String, dynamic>> getStorageInfo() async {
    // Simula informações de armazenamento
    return {
      'totalSpace': 1024 * 1024 * 1024, // 1GB
      'usedSpace': _storage.length * 1024, // Aproximação
      'freeSpace': (1024 * 1024 * 1024) - (_storage.length * 1024),
      'itemCount': _storage.length,
    };
  }
}