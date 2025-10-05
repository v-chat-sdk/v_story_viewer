/// Utility class for calculating text reading duration based on WPM (Words Per Minute)
class VWpmCalculator {
  const VWpmCalculator._();

  /// Calculate reading duration for given text
  ///
  /// Uses configurable words per minute to estimate reading time.
  /// Applies min/max bounds to ensure reasonable durations.
  static Duration calculateReadingDuration({
    required String text,
    required int wordsPerMinute,
    required Duration minDuration,
    required Duration maxDuration,
  }) {
    final wordCount = _countWords(text);
    final seconds = (wordCount / wordsPerMinute * 60).ceil();
    final calculatedDuration = Duration(seconds: seconds);

    // Clamp to min/max bounds
    if (calculatedDuration < minDuration) {
      return minDuration;
    } else if (calculatedDuration > maxDuration) {
      return maxDuration;
    }

    return calculatedDuration;
  }

  /// Count words in text
  static int _countWords(String text) {
    if (text.trim().isEmpty) return 0;

    // Split by whitespace and filter empty strings
    final words = text.trim().split(RegExp(r'\s+'));
    return words.where((word) => word.isNotEmpty).length;
  }

  /// Calculate duration with default parameters
  static Duration calculate({
    required String text,
    int wordsPerMinute = 180,
    Duration minDuration = const Duration(seconds: 2),
    Duration maxDuration = const Duration(seconds: 10),
  }) {
    return calculateReadingDuration(
      text: text,
      wordsPerMinute: wordsPerMinute,
      minDuration: minDuration,
      maxDuration: maxDuration,
    );
  }
}
