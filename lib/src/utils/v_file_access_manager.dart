import 'package:flutter/services.dart';
import 'package:v_platform/v_platform.dart' as v_platform;
import 'v_file_utils.dart';
import 'v_file_validator.dart';
import 'v_platform_handler.dart';

/// Manages file access operations across platforms.
///
/// This class provides a unified API for accessing files from
/// various sources (network, local, assets, bytes) using v_platform.
class VFileAccessManager {
  /// Private constructor to prevent instantiation
  VFileAccessManager._();

  /// Loads file data as bytes from a VPlatformFile
  static Future<Uint8List?> loadFileBytes(v_platform.VPlatformFile file) async {
    try {
      // If file already has bytes, return them
      if (file.bytes != null) {
        return Uint8List.fromList(file.bytes!);
      }

      // Handle based on source type
      final sourceType = VFileUtils.getSourceType(file);

      switch (sourceType) {
        case FileSourceType.network:
          // Network files would be handled by cache manager
          // This is a placeholder - actual implementation would use flutter_cache_manager
          return null;

        case FileSourceType.asset:
          return await _loadAssetBytes(file.assetsPath!);

        case FileSourceType.local:
          // Local files need platform-specific handling
          // v_platform should handle this internally
          if (VPlatformHandler.isWeb) {
            // Web can't directly access local files
            throw UnsupportedError(
              'Direct local file access is not supported on web',
            );
          }
          // This would need actual file reading implementation
          return null;

        case FileSourceType.bytes:
          return Uint8List.fromList(file.bytes!);

        case FileSourceType.unknown:
          throw ArgumentError('Unknown file source type');
      }
    } catch (e) {
      return null;
    }
  }

  /// Loads asset file as bytes
  static Future<Uint8List?> _loadAssetBytes(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Prepares a file for use (validation and adaptation)
  static Future<FileAccessResult> prepareFile(
    v_platform.VPlatformFile file, {
    required FileValidationType validationType,
  }) async {
    // Validate the file
    final validationResult = VFileValidator.validateFile(
      file,
      type: validationType,
    );

    if (!validationResult.isValid) {
      return FileAccessResult(success: false, error: validationResult.error);
    }

    // Adapt file for current platform
    final adaptedFile = VPlatformHandler.adaptFileForPlatform(file);

    // Additional platform-specific preparation
    if (VPlatformHandler.isWeb) {
      // Web-specific preparation
      if (file.fileLocalPath != null) {
        return FileAccessResult(
          success: false,
          error: 'Local file access is not supported on web platform',
        );
      }
    }

    return FileAccessResult(success: true, file: adaptedFile);
  }

  /// Creates a file from a data URL (base64 encoded)
  static v_platform.VPlatformFile? createFromDataUrl(
    String dataUrl, {
    String? fileName,
  }) {
    try {
      // Parse data URL: data:[<mediatype>][;base64],<data>
      final uri = Uri.parse(dataUrl);
      if (uri.scheme != 'data') {
        throw ArgumentError('Invalid data URL scheme');
      }

      final data = uri.data;
      if (data == null) {
        throw ArgumentError('Invalid data URL format');
      }

      final bytes = data.contentAsBytes();

      return v_platform.VPlatformFile.fromBytes(
        bytes: bytes,
        name: fileName ?? 'data_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      return null;
    }
  }

  /// Gets the best source URL for a file (for caching)
  static String? getBestSourceUrl(v_platform.VPlatformFile file) {
    // Prefer network URL for caching
    if (file.networkUrl != null) {
      return file.networkUrl;
    }

    // For assets, create a special URL scheme
    if (file.assetsPath != null) {
      return 'asset:///${file.assetsPath}';
    }

    // For local files on non-web platforms
    if (file.fileLocalPath != null && !VPlatformHandler.isWeb) {
      return 'file:///${file.fileLocalPath}';
    }

    // No cacheable URL available
    return null;
  }

  /// Checks if a file can be cached
  static bool canBeCached(v_platform.VPlatformFile file) {
    // Network files can be cached
    if (file.networkUrl != null) return true;

    // Assets don't need caching (already bundled)
    if (file.assetsPath != null) return false;

    // Local files don't need caching on mobile
    if (file.fileLocalPath != null && !VPlatformHandler.isWeb) return false;

    // Bytes data can be cached if needed
    if (file.bytes != null) return true;

    return false;
  }

  /// Gets cache key for a file
  static String getCacheKey(v_platform.VPlatformFile file) {
    return file.getCachedUrlKey;
  }
}

/// Result of file access operation
class FileAccessResult {
  /// Whether the operation was successful
  final bool success;

  /// The prepared file if successful
  final v_platform.VPlatformFile? file;

  /// Error message if operation failed
  final String? error;

  /// Creates a file access result
  const FileAccessResult({required this.success, this.file, this.error});
}

/// Debug utility for file information
class VFileDebugInfo {
  /// Gets debug information about a file
  static Map<String, dynamic> getDebugInfo(v_platform.VPlatformFile file) {
    return {
      'name': file.name,
      'size': file.fileSize,
      'sizeReadable': VFileUtils.getReadableFileSize(file),
      'mimeType': file.mimeType,
      'extension': VFileUtils.getFileExtension(file),
      'sourceType': VFileUtils.getSourceType(file).toString(),
      'isImage': VFileUtils.isImageFile(file),
      'isVideo': VFileUtils.isVideoFile(file),
      'hasNetwork': file.networkUrl != null,
      'hasLocal': file.fileLocalPath != null,
      'hasAsset': file.assetsPath != null,
      'hasBytes': file.bytes != null,
      'hash': file.fileHash,
      'platform': VPlatformHandler.platformName,
    };
  }

  /// Prints debug information about a file
  static void printDebugInfo(v_platform.VPlatformFile file) {
    final info = getDebugInfo(file);
    info.forEach((key, value) {
    });
  }
}
