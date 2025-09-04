import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cross-platform storage adapter for persisting story data.
/// 
/// This adapter provides a unified interface for storing and
/// retrieving data across different platforms (iOS, Android, Web).
abstract class VStorageAdapter {
  /// Store a string value
  Future<bool> setString(String key, String value);
  
  /// Retrieve a string value
  Future<String?> getString(String key);
  
  /// Store a list of strings
  Future<bool> setStringList(String key, List<String> value);
  
  /// Retrieve a list of strings
  Future<List<String>?> getStringList(String key);
  
  /// Store an integer value
  Future<bool> setInt(String key, int value);
  
  /// Retrieve an integer value
  Future<int?> getInt(String key);
  
  /// Store a double value
  Future<bool> setDouble(String key, double value);
  
  /// Retrieve a double value
  Future<double?> getDouble(String key);
  
  /// Store a boolean value
  Future<bool> setBool(String key, bool value);
  
  /// Retrieve a boolean value
  Future<bool?> getBool(String key);
  
  /// Store a JSON object
  Future<bool> setJson(String key, Map<String, dynamic> value);
  
  /// Retrieve a JSON object
  Future<Map<String, dynamic>?> getJson(String key);
  
  /// Remove a value
  Future<bool> remove(String key);
  
  /// Clear all stored values
  Future<bool> clear();
  
  /// Get all keys
  Future<Set<String>> getKeys();
  
  /// Check if a key exists
  Future<bool> containsKey(String key);
  
  /// Reload cached values
  Future<void> reload();
}

/// SharedPreferences implementation of storage adapter.
/// 
/// Uses SharedPreferences for cross-platform storage on
/// iOS, Android, and Web platforms.
class SharedPreferencesAdapter implements VStorageAdapter {
  /// SharedPreferences instance
  SharedPreferences? _prefs;
  
  /// Ensure initialized before operations
  Future<SharedPreferences> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  @override
  Future<bool> setString(String key, String value) async {
    final prefs = await _ensureInitialized();
    return prefs.setString(key, value);
  }
  
  @override
  Future<String?> getString(String key) async {
    final prefs = await _ensureInitialized();
    return prefs.getString(key);
  }
  
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _ensureInitialized();
    return prefs.setStringList(key, value);
  }
  
  @override
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _ensureInitialized();
    return prefs.getStringList(key);
  }
  
  @override
  Future<bool> setInt(String key, int value) async {
    final prefs = await _ensureInitialized();
    return prefs.setInt(key, value);
  }
  
  @override
  Future<int?> getInt(String key) async {
    final prefs = await _ensureInitialized();
    return prefs.getInt(key);
  }
  
  @override
  Future<bool> setDouble(String key, double value) async {
    final prefs = await _ensureInitialized();
    return prefs.setDouble(key, value);
  }
  
  @override
  Future<double?> getDouble(String key) async {
    final prefs = await _ensureInitialized();
    return prefs.getDouble(key);
  }
  
  @override
  Future<bool> setBool(String key, bool value) async {
    final prefs = await _ensureInitialized();
    return prefs.setBool(key, value);
  }
  
  @override
  Future<bool?> getBool(String key) async {
    final prefs = await _ensureInitialized();
    return prefs.getBool(key);
  }
  
  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    final prefs = await _ensureInitialized();
    try {
      final jsonString = jsonEncode(value);
      return prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('Error encoding JSON: $e');
      return false;
    }
  }
  
  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await _ensureInitialized();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error decoding JSON: $e');
      }
    }
    return null;
  }
  
  @override
  Future<bool> remove(String key) async {
    final prefs = await _ensureInitialized();
    return prefs.remove(key);
  }
  
  @override
  Future<bool> clear() async {
    final prefs = await _ensureInitialized();
    return prefs.clear();
  }
  
  @override
  Future<Set<String>> getKeys() async {
    final prefs = await _ensureInitialized();
    return prefs.getKeys();
  }
  
  @override
  Future<bool> containsKey(String key) async {
    final prefs = await _ensureInitialized();
    return prefs.containsKey(key);
  }
  
  @override
  Future<void> reload() async {
    final prefs = await _ensureInitialized();
    await prefs.reload();
  }
}

/// Memory-based storage adapter for testing.
/// 
/// Stores data in memory only, useful for testing
/// and development environments.
class MemoryStorageAdapter implements VStorageAdapter {
  /// In-memory storage
  final Map<String, dynamic> _storage = {};
  
  @override
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  Future<String?> getString(String key) async {
    final value = _storage[key];
    return value is String ? value : null;
  }
  
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = List<String>.from(value);
    return true;
  }
  
  @override
  Future<List<String>?> getStringList(String key) async {
    final value = _storage[key];
    if (value is List) {
      return List<String>.from(value);
    }
    return null;
  }
  
  @override
  Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  Future<int?> getInt(String key) async {
    final value = _storage[key];
    return value is int ? value : null;
  }
  
  @override
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  Future<double?> getDouble(String key) async {
    final value = _storage[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return null;
  }
  
  @override
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  Future<bool?> getBool(String key) async {
    final value = _storage[key];
    return value is bool ? value : null;
  }
  
  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _storage[key] = Map<String, dynamic>.from(value);
    return true;
  }
  
  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _storage[key];
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
  
  @override
  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }
  
  @override
  Future<bool> clear() async {
    _storage.clear();
    return true;
  }
  
  @override
  Future<Set<String>> getKeys() async {
    return _storage.keys.toSet();
  }
  
  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }
  
  @override
  Future<void> reload() async {
    // No-op for memory storage
  }
}

/// Factory for creating storage adapters.
class VStorageFactory {
  /// Create a storage adapter based on platform
  static VStorageAdapter create({bool useMemory = false}) {
    if (useMemory || kDebugMode && const bool.fromEnvironment('USE_MEMORY_STORAGE')) {
      return MemoryStorageAdapter();
    }
    return SharedPreferencesAdapter();
  }
}