// lib/service/cache_manager.dart

class CacheManager {
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration cacheDuration;

  CacheManager({this.cacheDuration = const Duration(minutes: 10)});

  bool isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < cacheDuration;
  }

  void markCached(String key) {
    _cacheTimestamps[key] = DateTime.now();
  }

  void invalidate(String key) {
    _cacheTimestamps.remove(key);
  }

  void invalidateAll() {
    _cacheTimestamps.clear();
  }
}