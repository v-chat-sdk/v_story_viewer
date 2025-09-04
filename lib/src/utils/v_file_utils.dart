import 'dart:typed_data';
import 'package:v_platform/v_platform.dart' as v_platform;

/// Utility class for cross-platform file handling operations.
/// 
/// This class provides helper methods for working with files
/// across iOS, Android, and web platforms using v_platform.
class VFileUtils {
  /// Private constructor to prevent instantiation
  VFileUtils._();
  
  /// Creates a VPlatformFile from various sources
  static v_platform.VPlatformFile createFile({
    String? networkUrl,
    String? localPath,
    String? assetPath,
    Uint8List? bytes,
    String? fileName,
  }) {
    // Validate that at least one source is provided
    assert(
      networkUrl != null || localPath != null || assetPath != null || bytes != null,
      'At least one file source must be provided',
    );
    
    if (networkUrl != null) {
      return v_platform.VPlatformFile.fromUrl(
        networkUrl: networkUrl,
      );
    } else if (localPath != null) {
      return v_platform.VPlatformFile.fromPath(
        fileLocalPath: localPath,
      );
    } else if (assetPath != null) {
      return v_platform.VPlatformFile.fromAssets(
        assetsPath: assetPath,
      );
    } else if (bytes != null) {
      return v_platform.VPlatformFile.fromBytes(
        bytes: bytes,
        name: fileName ?? 'file_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    
    throw ArgumentError('No valid file source provided');
  }
  
  /// Validates if a file is a supported image format
  static bool isImageFile(v_platform.VPlatformFile file) {
    final supportedFormats = [
      'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'
    ];
    
    final extension = getFileExtension(file).toLowerCase();
    return supportedFormats.contains(extension);
  }
  
  /// Validates if a file is a supported video format
  static bool isVideoFile(v_platform.VPlatformFile file) {
    final supportedFormats = [
      'mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v', '3gp'
    ];
    
    final extension = getFileExtension(file).toLowerCase();
    return supportedFormats.contains(extension);
  }
  
  /// Gets the file extension from a VPlatformFile
  static String getFileExtension(v_platform.VPlatformFile file) {
    final name = file.name;
    final lastDot = name.lastIndexOf('.');
    if (lastDot != -1 && lastDot < name.length - 1) {
      return name.substring(lastDot + 1);
    }
    
    // Try to get from MIME type
    if (file.mimeType != null) {
      final parts = file.mimeType!.split('/');
      if (parts.length == 2) {
        return parts[1];
      }
    }
    
    return '';
  }
  
  /// Gets a human-readable file size
  static String getReadableFileSize(v_platform.VPlatformFile file) {
    final bytes = file.fileSize;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Checks if the file is from a network source
  static bool isNetworkFile(v_platform.VPlatformFile file) {
    return file.networkUrl != null && file.networkUrl!.isNotEmpty;
  }
  
  /// Checks if the file is from local storage
  static bool isLocalFile(v_platform.VPlatformFile file) {
    return file.fileLocalPath != null && file.fileLocalPath!.isNotEmpty;
  }
  
  /// Checks if the file is from assets
  static bool isAssetFile(v_platform.VPlatformFile file) {
    return file.assetsPath != null && file.assetsPath!.isNotEmpty;
  }
  
  /// Checks if the file is from bytes
  static bool isBytesFile(v_platform.VPlatformFile file) {
    return file.bytes != null && file.bytes!.isNotEmpty;
  }
  
  /// Gets the source type of the file
  static FileSourceType getSourceType(v_platform.VPlatformFile file) {
    if (isNetworkFile(file)) return FileSourceType.network;
    if (isLocalFile(file)) return FileSourceType.local;
    if (isAssetFile(file)) return FileSourceType.asset;
    if (isBytesFile(file)) return FileSourceType.bytes;
    return FileSourceType.unknown;
  }
  
  /// Validates if a URL is valid
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  /// Validates if a file path is valid (basic validation)
  static bool isValidPath(String path) {
    // Basic validation - check if path is not empty and doesn't contain invalid characters
    if (path.isEmpty) return false;
    
    // Check for common invalid characters
    final invalidChars = ['<', '>', ':', '"', '|', '?', '*', '\x00'];
    for (final char in invalidChars) {
      if (path.contains(char)) return false;
    }
    
    return true;
  }
}

/// Enum representing different file source types
enum FileSourceType {
  /// File from network URL
  network,
  
  /// File from local storage
  local,
  
  /// File from app assets
  asset,
  
  /// File from bytes data
  bytes,
  
  /// Unknown source type
  unknown,
}