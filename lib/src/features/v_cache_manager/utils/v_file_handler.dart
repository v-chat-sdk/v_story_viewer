import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Utility class for handling file operations (assets, bytes, temp files)
///
/// Extracted from VCacheController to maintain single responsibility principle.
/// Handles conversion of various file sources to File objects.
/// Note: File operations are only supported on mobile/desktop platforms, not web.
class VFileHandler {
  VFileHandler._();

  /// Load file from assets with hash-based naming to prevent collisions
  ///
  /// Uses SHA-256 hash of full asset path to ensure unique filenames,
  /// preventing collisions between assets like "images/logo.png" and "icons/logo.png"
  ///
  /// Throws UnsupportedError on web platforms.
  static Future<File> loadFromAssets(String assetPath) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'File operations are not supported on web. Use VPlatformFile.assetsPath directly.',
      );
    }
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final hashedName = _hashPath(assetPath);
    final extension = _getFileExtension(assetPath);
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/v_asset_${hashedName}$extension');
    if (!await file.exists()) {
      await file.writeAsBytes(bytes);
    }
    return file;
  }

  /// Save bytes to temp file with hash-based naming
  ///
  /// Uses timestamp + content hash for unique naming to prevent collisions
  ///
  /// Throws UnsupportedError on web platforms.
  static Future<File> saveBytesToFile(Uint8List bytes) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'File operations are not supported on web. Use VPlatformFile.bytes directly.',
      );
    }
    final contentHash = _hashBytes(bytes);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/v_bytes_${timestamp}_$contentHash');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Convert List<int> to Uint8List safely
  static Uint8List toUint8List(List<int> bytes) {
    return bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  }

  /// Get file extension from path
  static String _getFileExtension(String path) {
    final parts = path.split('.');
    if (parts.length > 1) {
      return '.${parts.last}';
    }
    return '';
  }

  /// Generate hash from string path (first 16 chars of SHA-256)
  static String _hashPath(String path) {
    final bytes = utf8.encode(path);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  /// Generate hash from bytes content (first 16 chars of SHA-256)
  static String _hashBytes(List<int> bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
}
