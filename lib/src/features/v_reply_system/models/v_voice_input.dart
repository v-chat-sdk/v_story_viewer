import 'package:flutter/foundation.dart';

/// Configuration for voice input feature
@immutable
class VVoiceInputConfig {
  const VVoiceInputConfig({
    this.enableVoiceInput = true,
    this.language = 'en_US',
    this.listeningDuration = const Duration(seconds: 30),
    this.pauseDuration = const Duration(seconds: 3),
    this.showConfidenceScore = true,
    this.minConfidenceScore = 0.5,
  });

  /// Enable/disable voice input feature
  final bool enableVoiceInput;

  /// Language code for speech recognition
  final String language;

  /// Maximum listening duration before auto-stop
  final Duration listeningDuration;

  /// Pause duration after speech ends before stopping
  final Duration pauseDuration;

  /// Show confidence score of recognized text
  final bool showConfidenceScore;

  /// Minimum confidence threshold (0.0 - 1.0)
  final double minConfidenceScore;

  VVoiceInputConfig copyWith({
    bool? enableVoiceInput,
    String? language,
    Duration? listeningDuration,
    Duration? pauseDuration,
    bool? showConfidenceScore,
    double? minConfidenceScore,
  }) {
    return VVoiceInputConfig(
      enableVoiceInput: enableVoiceInput ?? this.enableVoiceInput,
      language: language ?? this.language,
      listeningDuration: listeningDuration ?? this.listeningDuration,
      pauseDuration: pauseDuration ?? this.pauseDuration,
      showConfidenceScore: showConfidenceScore ?? this.showConfidenceScore,
      minConfidenceScore: minConfidenceScore ?? this.minConfidenceScore,
    );
  }
}

/// Enum for voice input state
enum VVoiceInputState {
  idle,
  initializing,
  listening,
  processing,
  recognized,
  error,
}

/// Data class for voice recognition result
@immutable
class VVoiceRecognitionResult {
  const VVoiceRecognitionResult({
    required this.text,
    required this.confidenceScore,
    required this.isFinal,
    this.error,
    this.errorDescription,
  });

  /// Recognized text
  final String text;

  /// Confidence score (0.0 - 1.0)
  final double confidenceScore;

  /// Whether this is a final result
  final bool isFinal;

  /// Error type if recognition failed
  final String? error;

  /// Detailed error description
  final String? errorDescription;

  bool get hasError => error != null;
}

/// Voice input state notifier
class VVoiceInputStateNotifier extends ChangeNotifier {
  VVoiceInputState _state = VVoiceInputState.idle;
  VVoiceRecognitionResult? _lastResult;
  final List<VVoiceRecognitionResult> _recognitionHistory = [];

  VVoiceInputState get state => _state;

  VVoiceRecognitionResult? get lastResult => _lastResult;

  List<VVoiceRecognitionResult> get recognitionHistory =>
      List.unmodifiable(_recognitionHistory);

  bool get isListening => _state == VVoiceInputState.listening;

  bool get isProcessing => _state == VVoiceInputState.processing;

  /// Update state
  void updateState(VVoiceInputState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Record a recognition result
  void recordResult(VVoiceRecognitionResult result) {
    _lastResult = result;
    if (result.isFinal) {
      _recognitionHistory.insert(0, result);
      if (_recognitionHistory.length > 10) {
        _recognitionHistory.removeLast();
      }
    }
    notifyListeners();
  }

  /// Clear history
  void clearHistory() {
    _recognitionHistory.clear();
    _lastResult = null;
    notifyListeners();
  }

  /// Reset to idle state
  void reset() {
    _state = VVoiceInputState.idle;
    _lastResult = null;
    notifyListeners();
  }
}

/// Permissions required for voice input
@immutable
class VVoiceInputPermissions {
  const VVoiceInputPermissions({this.microphone = false, this.audio = false});

  /// Microphone permission granted
  final bool microphone;

  /// Audio recording permission granted
  final bool audio;

  bool get allGranted => microphone && audio;

  VVoiceInputPermissions copyWith({bool? microphone, bool? audio}) {
    return VVoiceInputPermissions(
      microphone: microphone ?? this.microphone,
      audio: audio ?? this.audio,
    );
  }
}

/// Common error types for voice input
enum VVoiceInputErrorType {
  microphoneNotAvailable,
  permissionDenied,
  noSpeechDetected,
  audioError,
  networkError,
  timeout,
  unknown,
}

/// Extension for error type messages
extension VVoiceInputErrorTypeExt on VVoiceInputErrorType {
  /// Get user-friendly error message
  String get message {
    return switch (this) {
      VVoiceInputErrorType.microphoneNotAvailable =>
        'Microphone is not available',
      VVoiceInputErrorType.permissionDenied => 'Microphone permission denied',
      VVoiceInputErrorType.noSpeechDetected => 'No speech was detected',
      VVoiceInputErrorType.audioError => 'Audio error occurred',
      VVoiceInputErrorType.networkError => 'Network error occurred',
      VVoiceInputErrorType.timeout => 'Speech recognition timed out',
      VVoiceInputErrorType.unknown => 'Unknown error occurred',
    };
  }
}
