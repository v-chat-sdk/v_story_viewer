import 'package:v_platform/v_platform.dart' as v_platform;
import 'v_file_utils.dart';

/// Validates files for security and compatibility.
/// 
/// This class provides validation methods to ensure files
/// are safe and compatible with the story viewer.
class VFileValidator {
  /// Maximum file size for images (10 MB)
  static const int maxImageSize = 10 * 1024 * 1024;
  
  /// Maximum file size for videos (100 MB)
  static const int maxVideoSize = 100 * 1024 * 1024;
  
  /// Allowed image MIME types
  static const List<String> allowedImageMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/bmp',
  ];
  
  /// Allowed video MIME types
  static const List<String> allowedVideoMimeTypes = [
    'video/mp4',
    'video/quicktime',
    'video/x-msvideo',
    'video/x-matroska',
    'video/webm',
    'video/3gpp',
  ];
  
  /// Private constructor to prevent instantiation
  VFileValidator._();
  
  /// Result of file validation
  static FileValidationResult validateFile(
    v_platform.VPlatformFile file, {
    required FileValidationType type,
  }) {
    // Check if file exists
    if (!_hasValidSource(file)) {
      return FileValidationResult(
        isValid: false,
        error: 'File has no valid source',
      );
    }
    
    // Validate based on type
    switch (type) {
      case FileValidationType.image:
        return _validateImageFile(file);
      case FileValidationType.video:
        return _validateVideoFile(file);
      case FileValidationType.any:
        return FileValidationResult(isValid: true);
    }
  }
  
  /// Validates an image file
  static FileValidationResult _validateImageFile(v_platform.VPlatformFile file) {
    // Check file extension
    if (!VFileUtils.isImageFile(file)) {
      return FileValidationResult(
        isValid: false,
        error: 'File is not a supported image format',
      );
    }
    
    // Check MIME type if available
    if (file.mimeType != null && !allowedImageMimeTypes.contains(file.mimeType)) {
      return FileValidationResult(
        isValid: false,
        error: 'Invalid image MIME type: ${file.mimeType}',
      );
    }
    
    // Check file size
    if (file.fileSize > maxImageSize) {
      return FileValidationResult(
        isValid: false,
        error: 'Image file size exceeds maximum of ${maxImageSize ~/ (1024 * 1024)} MB',
      );
    }
    
    return FileValidationResult(isValid: true);
  }
  
  /// Validates a video file
  static FileValidationResult _validateVideoFile(v_platform.VPlatformFile file) {
    // Check file extension
    if (!VFileUtils.isVideoFile(file)) {
      return FileValidationResult(
        isValid: false,
        error: 'File is not a supported video format',
      );
    }
    
    // Check MIME type if available
    if (file.mimeType != null && !allowedVideoMimeTypes.contains(file.mimeType)) {
      return FileValidationResult(
        isValid: false,
        error: 'Invalid video MIME type: ${file.mimeType}',
      );
    }
    
    // Check file size
    if (file.fileSize > maxVideoSize) {
      return FileValidationResult(
        isValid: false,
        error: 'Video file size exceeds maximum of ${maxVideoSize ~/ (1024 * 1024)} MB',
      );
    }
    
    return FileValidationResult(isValid: true);
  }
  
  /// Checks if file has a valid source
  static bool _hasValidSource(v_platform.VPlatformFile file) {
    return file.networkUrl != null ||
        file.fileLocalPath != null ||
        file.assetsPath != null ||
        file.bytes != null;
  }
  
  /// Validates a URL for security
  static FileValidationResult validateUrl(String url) {
    // Check if URL is valid
    if (!VFileUtils.isValidUrl(url)) {
      return FileValidationResult(
        isValid: false,
        error: 'Invalid URL format',
      );
    }
    
    // Parse URL for additional checks
    try {
      Uri.parse(url); // Just validate format, we don't use the parsed URI
      
      // Check for HTTPS in production (allow HTTP for development)
      // Uncomment for production:
      // if (uri.scheme != 'https') {
      //   return FileValidationResult(
      //     isValid: false,
      //     error: 'Only HTTPS URLs are allowed',
      //   );
      // }
      
      // Check for suspicious patterns
      if (_containsSuspiciousPatterns(url)) {
        return FileValidationResult(
          isValid: false,
          error: 'URL contains suspicious patterns',
        );
      }
      
      return FileValidationResult(isValid: true);
    } catch (e) {
      return FileValidationResult(
        isValid: false,
        error: 'Failed to parse URL: $e',
      );
    }
  }
  
  /// Checks for suspicious patterns in URLs
  static bool _containsSuspiciousPatterns(String url) {
    final suspiciousPatterns = [
      'javascript:',
      'data:text/html',
      'vbscript:',
      'file://',
      '<script',
      'onclick=',
      'onerror=',
    ];
    
    final lowerUrl = url.toLowerCase();
    for (final pattern in suspiciousPatterns) {
      if (lowerUrl.contains(pattern)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Validates a file path
  static FileValidationResult validatePath(String path) {
    if (!VFileUtils.isValidPath(path)) {
      return FileValidationResult(
        isValid: false,
        error: 'Invalid file path',
      );
    }
    
    // Check for path traversal attempts
    if (path.contains('../') || path.contains('..\\')) {
      return FileValidationResult(
        isValid: false,
        error: 'Path traversal detected',
      );
    }
    
    return FileValidationResult(isValid: true);
  }
}

/// Result of file validation
class FileValidationResult {
  /// Whether the file is valid
  final bool isValid;
  
  /// Error message if validation failed
  final String? error;
  
  /// Creates a validation result
  const FileValidationResult({
    required this.isValid,
    this.error,
  });
  
  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $error';
}

/// Types of file validation
enum FileValidationType {
  /// Validate as image file
  image,
  
  /// Validate as video file
  video,
  
  /// Accept any file type
  any,
}