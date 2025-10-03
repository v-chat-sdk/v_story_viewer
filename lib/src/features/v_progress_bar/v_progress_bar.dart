/// Progress bar feature for story viewer
///
/// Provides segmented progress indicators using Flutter's LinearProgressIndicator
/// with WhatsApp-style behavior:
/// - ID-based story tracking
/// - Previous stories: 1.0 (full)
/// - Current story: animating (0.0-1.0)
/// - Future stories: 0.0 (empty)
library;

export 'controllers/v_progress_controller.dart';
export 'models/v_progress_callbacks.dart';
export 'models/v_progress_style.dart';
export 'widgets/v_segmented_progress.dart';
