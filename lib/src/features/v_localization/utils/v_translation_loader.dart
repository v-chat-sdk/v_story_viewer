import 'package:flutter/material.dart';

import '../translations/ar.dart';
import '../translations/en.dart';
import '../translations/es.dart';

/// Translation loader for getting localized strings
class VTranslationLoader {
  /// Get translation for key and locale
  static String translate(
    String key,
    Locale locale, {
    Map<String, dynamic>? params,
  }) {
    final translations = _getTranslations(locale.languageCode);
    var text = translations[key] ?? key;

    // Replace parameters if provided
    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value.toString());
      });
    }

    return text;
  }

  /// Get translations map for language code
  static Map<String, String> _getTranslations(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return arTranslations;
      case 'es':
        return esTranslations;
      case 'en':
      default:
        return enTranslations;
    }
  }

  /// Get supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('es'),
  ];
}
