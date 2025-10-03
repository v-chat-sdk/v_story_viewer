import 'package:flutter/material.dart';

/// Utility class for handling RTL layout
class VRtlHandler {
  /// Check if language code is RTL
  static bool isRTL(String languageCode) {
    return _rtlLanguages.contains(languageCode);
  }

  /// Get text direction from language code
  static TextDirection getTextDirection(String languageCode) {
    return isRTL(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get alignment based on RTL
  static Alignment getAlignment(String languageCode, {bool isStart = true}) {
    final isRtl = isRTL(languageCode);
    if (isStart) {
      return isRtl ? Alignment.centerRight : Alignment.centerLeft;
    } else {
      return isRtl ? Alignment.centerLeft : Alignment.centerRight;
    }
  }

  static const List<String> _rtlLanguages = ['ar', 'he', 'fa', 'ur'];
}
