import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Web-safe cache configuration for flutter_cache_manager.
/// 
/// This configuration handles the web platform where path_provider
/// is not available, using a web-compatible file store instead.
class VWebCacheConfig {
  /// Creates a web-safe cache manager configuration
  static Config createConfig() {
    if (kIsWeb) {
      // For web, use the default cache manager which handles web automatically
      // flutter_cache_manager will use its internal web implementation
      return Config(
        'v_story_viewer_cache',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 200,
      );
    } else {
      // For mobile platforms, use the standard configuration
      return Config(
        'v_story_viewer_cache',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 200,
        repo: JsonCacheInfoRepository(databaseName: 'v_story_viewer_cache'),
        fileService: HttpFileService(),
      );
    }
  }
}