// // lib/service/cache_manager.dart

// class CacheManager {
//   final Map<String, DateTime> _cacheTimestamps = {};
//   final Duration cacheDuration;

//   CacheManager({this.cacheDuration = const Duration(minutes: 10)});

//   bool isCacheValid(String key) {
//     final timestamp = _cacheTimestamps[key];
//     if (timestamp == null) return false;
//     return DateTime.now().difference(timestamp) < cacheDuration;
//   }

//   void markCached(String key) {
//     _cacheTimestamps[key] = DateTime.now();
//   }

//   void invalidate(String key) {
//     _cacheTimestamps.remove(key);
//   }

//   void invalidateAll() {
//     _cacheTimestamps.clear();
//   }
// }


// lib/services/cacheManager.dart

import 'package:flutter/foundation.dart';

/// Singleton cache manager shared across the ENTIRE app.
/// Every provider / page uses CacheManager() and gets the SAME instance,
/// so invalidateAll() actually clears data everywhere — no more manual
/// per-page cleanup.
class CacheManager extends ChangeNotifier {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager({Duration? cacheDuration}) {
    if (cacheDuration != null) {
      _instance.cacheDuration = cacheDuration;
    }
    return _instance;
  }
  CacheManager._internal();

  Duration cacheDuration = const Duration(minutes: 10);

  final Map<String, DateTime> _timestamps = {};
  final Map<String, dynamic> _data = {};

  /// Is this key cached AND still within cacheDuration?
  bool isCacheValid(String key) {
    final ts = _timestamps[key];
    if (ts == null) return false;
    return DateTime.now().difference(ts) < cacheDuration;
  }

  /// Returns cached value if valid, otherwise null (and auto-cleans stale entry).
  T? get<T>(String key) {
    if (!isCacheValid(key)) {
      _data.remove(key);
      _timestamps.remove(key);
      return null;
    }
    return _data[key] as T?;
  }

  /// Store data under [key] and mark it as freshly cached.
  void set(String key, dynamic value) {
    _data[key] = value;
    _timestamps[key] = DateTime.now();
  }

  /// Old API kept for backward compatibility with existing call sites
  /// that only call markCached() without storing data via set().
  void markCached(String key) {
    _timestamps[key] = DateTime.now();
  }

  bool containsKey(String key) => _data.containsKey(key) && isCacheValid(key);

  /// Invalidate a single key, OR all keys starting with [prefix] if exact
  /// match isn't found (handy for paginated/search keys like "certificates-1-").
  void invalidate(String key) {
    _timestamps.remove(key);
    _data.remove(key);
    _timestamps.removeWhere((k, _) => k.startsWith(key));
    _data.removeWhere((k, _) => k.startsWith(key));
    notifyListeners();
  }

  void invalidateAll() {
    _timestamps.clear();
    _data.clear();
    notifyListeners();
  }
}