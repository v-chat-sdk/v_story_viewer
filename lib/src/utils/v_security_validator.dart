import 'package:flutter/foundation.dart';
import '../models/v_security_error.dart';
import 'v_error_logger.dart';

/// Security validator for story viewer
class VSecurityValidator {
  /// Private constructor
  VSecurityValidator._();
  
  /// Allowed image extensions
  static const List<String> _allowedImageExtensions = [
    '.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.heic', '.heif'
  ];
  
  /// Allowed video extensions
  static const List<String> _allowedVideoExtensions = [
    '.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v', '.3gp', '.flv'
  ];
  
  /// Allowed image MIME types
  static const List<String> _allowedImageMimeTypes = [
    'image/jpeg', 'image/png', 'image/gif', 'image/webp', 
    'image/bmp', 'image/heic', 'image/heif'
  ];
  
  /// Allowed video MIME types
  static const List<String> _allowedVideoMimeTypes = [
    'video/mp4', 'video/quicktime', 'video/x-msvideo',
    'video/x-matroska', 'video/webm', 'video/x-m4v',
    'video/3gpp', 'video/x-flv'
  ];
  
  /// Maximum file size for images (10MB)
  static const int _maxImageSizeBytes = 10 * 1024 * 1024;
  
  /// Maximum file size for videos (100MB)
  static const int _maxVideoSizeBytes = 100 * 1024 * 1024;
  
  /// Dangerous URL patterns
  static final List<RegExp> _dangerousUrlPatterns = [
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'data:text/html', caseSensitive: false),
    RegExp(r'vbscript:', caseSensitive: false),
    RegExp(r'file://', caseSensitive: false),
    RegExp(r'about:', caseSensitive: false),
  ];
  
  /// Validate URL safety
  static ValidationResult validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return ValidationResult.invalid('URL is empty');
    }
    
    // Check for dangerous patterns
    for (final pattern in _dangerousUrlPatterns) {
      if (pattern.hasMatch(url)) {
        VErrorLogger.logWarning(
          'Dangerous URL pattern detected',
          extra: {'url': url, 'pattern': pattern.pattern},
        );
        return ValidationResult.invalid('URL contains dangerous pattern');
      }
    }
    
    // Validate URL format
    try {
      final uri = Uri.parse(url);
      
      // Check for valid scheme
      if (!['http', 'https'].contains(uri.scheme.toLowerCase())) {
        return ValidationResult.invalid('Invalid URL scheme: ${uri.scheme}');
      }
      
      // Check for localhost in production
      if (!kDebugMode && 
          (uri.host == 'localhost' || 
           uri.host == '127.0.0.1' || 
           uri.host.startsWith('192.168.') || 
           uri.host.startsWith('10.'))) {
        VErrorLogger.logWarning(
          'Local URL detected in production',
          extra: {'url': url},
        );
        // Allow but warn
      }
      
      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid('Invalid URL format: $e');
    }
  }
  
  /// Validate file path safety
  static ValidationResult validateFilePath(String? path) {
    if (path == null || path.isEmpty) {
      return ValidationResult.invalid('File path is empty');
    }
    
    // Check for path traversal attacks
    if (path.contains('..') || path.contains('~')) {
      VErrorLogger.logWarning(
        'Potential path traversal detected',
        extra: {'path': path},
      );
      return ValidationResult.invalid('Path contains dangerous characters');
    }
    
    // Check for absolute paths that access system directories
    final dangerousPaths = [
      '/etc/', '/sys/', '/proc/', '/dev/',
      'C:\\Windows\\', 'C:\\System',
    ];
    
    for (final dangerous in dangerousPaths) {
      if (path.startsWith(dangerous)) {
        VErrorLogger.logWarning(
          'Access to system directory attempted',
          extra: {'path': path},
        );
        return ValidationResult.invalid('Access to system directory denied');
      }
    }
    
    return ValidationResult.valid();
  }
  
  /// Validate image file
  static ValidationResult validateImageFile({
    required String? path,
    String? mimeType,
    int? sizeBytes,
  }) {
    // Validate path
    if (path != null) {
      final pathResult = validateFilePath(path);
      if (!pathResult.isValid) {
        return pathResult;
      }
      
      // Check extension
      final extension = _getFileExtension(path);
      if (!_allowedImageExtensions.contains(extension.toLowerCase())) {
        return ValidationResult.invalid(
          'Invalid image extension: $extension',
        );
      }
    }
    
    // Validate MIME type
    if (mimeType != null && 
        !_allowedImageMimeTypes.contains(mimeType.toLowerCase())) {
      return ValidationResult.invalid(
        'Invalid image MIME type: $mimeType',
      );
    }
    
    // Validate size
    if (sizeBytes != null && sizeBytes > _maxImageSizeBytes) {
      return ValidationResult.invalid(
        'Image size exceeds limit: ${sizeBytes ~/ 1024 ~/ 1024}MB > ${_maxImageSizeBytes ~/ 1024 ~/ 1024}MB',
      );
    }
    
    return ValidationResult.valid();
  }
  
  /// Validate video file
  static ValidationResult validateVideoFile({
    required String? path,
    String? mimeType,
    int? sizeBytes,
  }) {
    // Validate path
    if (path != null) {
      final pathResult = validateFilePath(path);
      if (!pathResult.isValid) {
        return pathResult;
      }
      
      // Check extension
      final extension = _getFileExtension(path);
      if (!_allowedVideoExtensions.contains(extension.toLowerCase())) {
        return ValidationResult.invalid(
          'Invalid video extension: $extension',
        );
      }
    }
    
    // Validate MIME type
    if (mimeType != null && 
        !_allowedVideoMimeTypes.contains(mimeType.toLowerCase())) {
      return ValidationResult.invalid(
        'Invalid video MIME type: $mimeType',
      );
    }
    
    // Validate size
    if (sizeBytes != null && sizeBytes > _maxVideoSizeBytes) {
      return ValidationResult.invalid(
        'Video size exceeds limit: ${sizeBytes ~/ 1024 ~/ 1024}MB > ${_maxVideoSizeBytes ~/ 1024 ~/ 1024}MB',
      );
    }
    
    return ValidationResult.valid();
  }
  
  /// Validate asset path
  static ValidationResult validateAssetPath(String? path) {
    if (path == null || path.isEmpty) {
      return ValidationResult.invalid('Asset path is empty');
    }
    
    // Assets should start with 'assets/' or 'packages/'
    if (!path.startsWith('assets/') && !path.startsWith('packages/')) {
      return ValidationResult.invalid(
        'Invalid asset path: must start with assets/ or packages/',
      );
    }
    
    // Check for path traversal
    if (path.contains('..')) {
      return ValidationResult.invalid('Asset path contains dangerous characters');
    }
    
    return ValidationResult.valid();
  }
  
  /// Validate bytes data
  static ValidationResult validateBytes({
    required List<int>? bytes,
    required bool isImage,
  }) {
    if (bytes == null || bytes.isEmpty) {
      return ValidationResult.invalid('Bytes data is empty');
    }
    
    // Check size
    final maxSize = isImage ? _maxImageSizeBytes : _maxVideoSizeBytes;
    if (bytes.length > maxSize) {
      return ValidationResult.invalid(
        'Data size exceeds limit: ${bytes.length ~/ 1024 ~/ 1024}MB',
      );
    }
    
    // Validate file signature (magic numbers)
    if (isImage) {
      if (!_hasValidImageSignature(bytes)) {
        return ValidationResult.invalid('Invalid image data signature');
      }
    } else {
      if (!_hasValidVideoSignature(bytes)) {
        return ValidationResult.invalid('Invalid video data signature');
      }
    }
    
    return ValidationResult.valid();
  }
  
  /// Check for valid image signature
  static bool _hasValidImageSignature(List<int> bytes) {
    if (bytes.length < 4) return false;
    
    // JPEG
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return true;
    }
    
    // PNG
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && 
        bytes[2] == 0x4E && bytes[3] == 0x47) {
      return true;
    }
    
    // GIF
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return true;
    }
    
    // WebP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 && bytes[1] == 0x49 &&
        bytes[2] == 0x46 && bytes[3] == 0x46 &&
        bytes[8] == 0x57 && bytes[9] == 0x45 &&
        bytes[10] == 0x42 && bytes[11] == 0x50) {
      return true;
    }
    
    return false;
  }
  
  /// Check for valid video signature
  static bool _hasValidVideoSignature(List<int> bytes) {
    if (bytes.length < 12) return false;
    
    // MP4/M4V
    if (bytes.length >= 8 &&
        bytes[4] == 0x66 && bytes[5] == 0x74 &&
        bytes[6] == 0x79 && bytes[7] == 0x70) {
      return true;
    }
    
    // AVI
    if (bytes[0] == 0x52 && bytes[1] == 0x49 &&
        bytes[2] == 0x46 && bytes[3] == 0x46 &&
        bytes[8] == 0x41 && bytes[9] == 0x56 &&
        bytes[10] == 0x49) {
      return true;
    }
    
    // WebM
    if (bytes[0] == 0x1A && bytes[1] == 0x45 &&
        bytes[2] == 0xDF && bytes[3] == 0xA3) {
      return true;
    }
    
    return false;
  }
  
  /// Get file extension from path
  static String _getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1 || lastDot == path.length - 1) {
      return '';
    }
    return path.substring(lastDot);
  }
  
  /// Sanitize user input
  static String sanitizeUserInput(String input) {
    // Remove control characters
    final sanitized = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    
    // Limit length
    const maxLength = 5000;
    if (sanitized.length > maxLength) {
      return sanitized.substring(0, maxLength);
    }
    
    return sanitized;
  }
  
  /// Validate callback URL for replies
  static ValidationResult validateCallbackUrl(String? url) {
    if (url == null || url.isEmpty) {
      return ValidationResult.valid(); // Callback is optional
    }
    
    final urlResult = validateUrl(url);
    if (!urlResult.isValid) {
      return urlResult;
    }
    
    // Additional checks for callback URLs
    try {
      final uri = Uri.parse(url);
      
      // Callback should use HTTPS in production
      if (!kDebugMode && uri.scheme != 'https') {
        return ValidationResult.invalid(
          'Callback URL must use HTTPS in production',
        );
      }
      
      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid('Invalid callback URL: $e');
    }
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  const ValidationResult._({
    required this.isValid,
    this.errorMessage,
  });
  
  factory ValidationResult.valid() => const ValidationResult._(
    isValid: true,
  );
  
  factory ValidationResult.invalid(String message) => ValidationResult._(
    isValid: false,
    errorMessage: message,
  );
  
  /// Throw exception if invalid
  void throwIfInvalid() {
    if (!isValid) {
      throw VSecurityError(errorMessage ?? 'Validation failed');
    }
  }
}

