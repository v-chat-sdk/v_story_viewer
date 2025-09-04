import 'dart:math' as math;
import '../models/v_story_models.dart';

/// Configuration for duration calculation.
class VDurationConfig {
  /// Default duration for image stories (seconds)
  final int defaultImageDuration;
  
  /// Default duration for text stories (seconds)
  final int defaultTextDuration;
  
  /// Default duration for custom stories (seconds)
  final int defaultCustomDuration;
  
  /// Minimum duration for any story (seconds)
  final int minDuration;
  
  /// Maximum duration for any story (seconds)
  final int maxDuration;
  
  /// Words per minute for text reading speed
  final int wordsPerMinute;
  
  /// Whether to use video duration from model
  final bool useVideoDurationFromModel;
  
  /// Creates a duration configuration
  const VDurationConfig({
    this.defaultImageDuration = 5,
    this.defaultTextDuration = 3,
    this.defaultCustomDuration = 5,
    this.minDuration = 2,
    this.maxDuration = 30,
    this.wordsPerMinute = 200,
    this.useVideoDurationFromModel = true,
  });
  
  /// Creates a default configuration
  factory VDurationConfig.defaultConfig() => const VDurationConfig();
  
  /// Creates a fast-paced configuration
  factory VDurationConfig.fast() => const VDurationConfig(
    defaultImageDuration: 3,
    defaultTextDuration: 2,
    minDuration: 1,
    maxDuration: 15,
    wordsPerMinute: 250,
  );
  
  /// Creates a slow-paced configuration
  factory VDurationConfig.slow() => const VDurationConfig(
    defaultImageDuration: 8,
    defaultTextDuration: 5,
    minDuration: 3,
    maxDuration: 60,
    wordsPerMinute: 150,
  );
}

/// Calculates story durations based on content.
class VDurationCalculator {
  /// Duration configuration
  final VDurationConfig config;
  
  /// Creates a duration calculator
  const VDurationCalculator({
    this.config = const VDurationConfig(),
  });
  
  /// Calculates duration for a story
  Duration calculateDuration(VBaseStory story) {
    // Check if story has explicit duration override
    if (story.duration != Duration.zero) {
      return story.duration;
    }
    
    // Calculate based on story type
    final seconds = switch (story) {
      VImageStory() => _calculateImageDuration(story),
      VVideoStory() => _calculateVideoDuration(story),
      VTextStory() => _calculateTextDuration(story),
      VCustomStory() => _calculateCustomDuration(story),
      _ => config.defaultImageDuration, // fallback for any other type
    };
    
    // Apply bounds
    final boundedSeconds = _applyBounds(seconds);
    return Duration(seconds: boundedSeconds);
  }
  
  /// Calculates duration for image story
  int _calculateImageDuration(VImageStory story) {
    // Use explicit duration if provided
    if (story.duration != Duration.zero) {
      return story.duration.inSeconds;
    }
    
    // Use default image duration
    return config.defaultImageDuration;
  }
  
  /// Calculates duration for video story
  int _calculateVideoDuration(VVideoStory story) {
    // Use explicit duration if provided
    if (story.duration != Duration.zero) {
      return story.duration.inSeconds;
    }
    
    // Use max duration from model if available
    if (config.useVideoDurationFromModel && story.maxDuration != null) {
      return story.maxDuration!.inSeconds;
    }
    
    // Fallback to a reasonable default for videos
    return 15; // 15 seconds default for videos
  }
  
  /// Calculates duration for text story
  int _calculateTextDuration(VTextStory story) {
    // Use explicit duration if provided
    if (story.duration != Duration.zero) {
      return story.duration.inSeconds;
    }
    
    // Calculate based on text length
    final text = story.text;
    final wordCount = _countWords(text);
    
    // Calculate reading time based on WPM
    final readingTimeMinutes = wordCount / config.wordsPerMinute;
    final readingTimeSeconds = (readingTimeMinutes * 60).ceil();
    
    // Consider text complexity
    final complexityFactor = _calculateComplexityFactor(text);
    final adjustedSeconds = (readingTimeSeconds * complexityFactor).ceil();
    
    // Ensure minimum duration for very short text
    if (wordCount < 5) {
      return config.defaultTextDuration;
    }
    
    return adjustedSeconds;
  }
  
  /// Calculates duration for custom story
  int _calculateCustomDuration(VCustomStory story) {
    // Use explicit duration if provided
    if (story.duration != Duration.zero) {
      return story.duration.inSeconds;
    }
    
    // Use default custom duration
    return config.defaultCustomDuration;
  }
  
  /// Counts words in text
  int _countWords(String text) {
    // Remove extra whitespace and split by word boundaries
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    
    // Split by whitespace and filter empty strings
    final words = trimmed.split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    
    return words.length;
  }
  
  /// Calculates text complexity factor
  double _calculateComplexityFactor(String text) {
    // Base factor
    double factor = 1.0;
    
    // Check for long words (technical content)
    final words = text.split(RegExp(r'\s+'));
    final avgWordLength = words.isEmpty ? 0 : 
        words.map((w) => w.length).reduce((a, b) => a + b) / words.length;
    
    if (avgWordLength > 6) {
      factor += 0.2; // 20% more time for complex words
    }
    
    // Check for numbers and special characters
    if (RegExp(r'[0-9]').hasMatch(text)) {
      factor += 0.1; // 10% more time for numbers
    }
    
    // Check for punctuation density (complex sentences)
    final punctuationCount = RegExp(r'[.,;:!?]').allMatches(text).length;
    final punctuationDensity = words.isEmpty ? 0 : punctuationCount / words.length;
    
    if (punctuationDensity > 0.2) {
      factor += 0.15; // 15% more time for complex sentences
    }
    
    // Check for line breaks (formatted text)
    if (text.contains('\n')) {
      factor += 0.1; // 10% more time for formatted text
    }
    
    return factor;
  }
  
  /// Applies minimum and maximum bounds
  int _applyBounds(int seconds) {
    return math.max(
      config.minDuration,
      math.min(config.maxDuration, seconds),
    );
  }
  
  /// Gets all story durations for a group
  List<Duration> getGroupDurations(VStoryGroup group) {
    return group.stories.map((story) => calculateDuration(story)).toList();
  }
  
  /// Gets total duration for a group
  Duration getTotalGroupDuration(VStoryGroup group) {
    final durations = getGroupDurations(group);
    return durations.fold(
      Duration.zero,
      (total, duration) => total + duration,
    );
  }
  
  /// Creates a duration override map for stories
  Map<String, int> createDurationOverrides(Map<String, int> overrides) {
    // Apply bounds to all overrides
    return overrides.map((key, value) => 
      MapEntry(key, _applyBounds(value)),
    );
  }
  
  /// Estimates reading difficulty level
  ReadingDifficulty estimateReadingDifficulty(String text) {
    final avgWordLength = _calculateAverageWordLength(text);
    final sentenceComplexity = _calculateSentenceComplexity(text);
    
    if (avgWordLength < 4 && sentenceComplexity < 0.3) {
      return ReadingDifficulty.easy;
    } else if (avgWordLength < 6 && sentenceComplexity < 0.5) {
      return ReadingDifficulty.medium;
    } else {
      return ReadingDifficulty.hard;
    }
  }
  
  /// Calculates average word length
  double _calculateAverageWordLength(String text) {
    final words = text.split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    
    if (words.isEmpty) return 0;
    
    final totalLength = words.map((w) => w.length).reduce((a, b) => a + b);
    return totalLength / words.length;
  }
  
  /// Calculates sentence complexity
  double _calculateSentenceComplexity(String text) {
    final sentences = text.split(RegExp(r'[.!?]'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    
    if (sentences.isEmpty) return 0;
    
    // Calculate average words per sentence
    final totalWords = sentences
        .map((s) => _countWords(s))
        .reduce((a, b) => a + b);
    
    final avgWordsPerSentence = totalWords / sentences.length;
    
    // Normalize to 0-1 scale (assuming 20+ words is complex)
    return math.min(1.0, avgWordsPerSentence / 20);
  }
}

/// Reading difficulty levels
enum ReadingDifficulty {
  easy,
  medium,
  hard,
}

/// Extension for duration formatting
extension DurationFormatting on Duration {
  /// Formats duration as MM:SS
  String toMinuteSeconds() {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  /// Formats duration as human-readable string
  String toHumanReadable() {
    if (inSeconds < 60) {
      return '${inSeconds}s';
    } else if (inMinutes < 60) {
      return '${inMinutes}m ${inSeconds.remainder(60)}s';
    } else {
      return '${inHours}h ${inMinutes.remainder(60)}m';
    }
  }
}