import 'package:flutter/material.dart';

/// Locale configuration for story viewer
@immutable
class VLocaleConfig {
  const VLocaleConfig({
    this.locale = const Locale('en'),
    this.supportedLocales = const [Locale('en'), Locale('ar'), Locale('es')],
    this.fallbackLocale = const Locale('en'),
  });

  /// Current locale
  final Locale locale;

  /// List of supported locales
  final List<Locale> supportedLocales;

  /// Fallback locale when translation is missing
  final Locale fallbackLocale;

  /// Check if locale is RTL
  bool get isRTL => _rtlLanguages.contains(locale.languageCode);

  /// Get text direction based on locale
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;

  static const _rtlLanguages = ['ar', 'he', 'fa', 'ur'];

  VLocaleConfig copyWith({
    Locale? locale,
    List<Locale>? supportedLocales,
    Locale? fallbackLocale,
  }) {
    return VLocaleConfig(
      locale: locale ?? this.locale,
      supportedLocales: supportedLocales ?? this.supportedLocales,
      fallbackLocale: fallbackLocale ?? this.fallbackLocale,
    );
  }
}
