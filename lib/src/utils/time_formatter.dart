import 'package:timeago/timeago.dart' as timeago;

/// Utility for formatting [DateTime] to human-readable relative strings.
///
/// Uses the [timeago](https://pub.dev/packages/timeago) package for formatting.
/// Supports multiple locales for internationalization.
///
/// ## Basic Usage
/// ```dart
/// final posted = DateTime.now().subtract(Duration(hours: 2));
/// final text = TimeFormatter.formatRelativeTime(posted);
/// print(text); // "2 hours ago"
/// ```
///
/// ## Localization Setup
/// Add locale support at app initialization:
/// ```dart
/// void main() {
///   // Add Arabic locale
///   TimeFormatter.setLocale('ar', timeago.ArMessages());
///
///   // Set default locale
///   TimeFormatter.setDefaultLocale('ar');
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Per-Call Locale Override
/// ```dart
/// // Use specific locale for one call
/// final text = TimeFormatter.formatRelativeTime(posted, locale: 'de');
/// ```
///
/// ## Supported Locales
/// See [timeago package](https://pub.dev/packages/timeago) for full list.
/// Common locales: en, es, fr, de, ar, zh, ja, ko, pt, ru
///
/// ## Output Examples
/// | Time Difference | Output |
/// |-----------------|--------|
/// | < 1 minute | "just now" |
/// | 5 minutes | "5 minutes ago" |
/// | 1 hour | "an hour ago" |
/// | 2 hours | "2 hours ago" |
/// | 1 day | "a day ago" |
/// | 2 days | "2 days ago" |
/// | 1 week | "a week ago" |
class TimeFormatter {
  /// Format [DateTime] to relative time string.
  ///
  /// Returns strings like "2 hours ago", "just now", "yesterday".
  ///
  /// Parameters:
  /// - [dateTime]: The timestamp to format
  /// - [locale]: Optional locale override (uses default if null)
  ///
  /// Example:
  /// ```dart
  /// final text = TimeFormatter.formatRelativeTime(story.createdAt);
  /// // Returns: "2h ago" or "yesterday" etc.
  /// ```
  static String formatRelativeTime(DateTime dateTime, {String? locale}) {
    return timeago.format(dateTime, locale: locale);
  }

  /// Register custom locale messages.
  ///
  /// Call once at app initialization before using [formatRelativeTime].
  ///
  /// Example:
  /// ```dart
  /// TimeFormatter.setLocale('ar', timeago.ArMessages());
  /// TimeFormatter.setLocale('custom', MyCustomMessages());
  /// ```
  static void setLocale(String locale, timeago.LookupMessages messages) {
    timeago.setLocaleMessages(locale, messages);
  }

  /// Set the default locale for all formatting calls.
  ///
  /// Affects all subsequent calls to [formatRelativeTime] that don't
  /// specify a locale parameter.
  ///
  /// Example:
  /// ```dart
  /// TimeFormatter.setDefaultLocale('es'); // Spanish
  /// ```
  static void setDefaultLocale(String locale) {
    timeago.setDefaultLocale(locale);
  }
}
