/// Controller interface for custom story widgets
///
/// Provides communication channel between custom story widgets and the story viewer.
/// Custom widgets use this controller to:
/// - Signal when they're loading data
/// - Notify when they're ready
/// - Control progress bar pause/resume
/// - Handle errors
///
/// Implementation pattern:
/// ```dart
/// class MyCustomStory extends StatefulWidget {
///   const MyCustomStory({required this.controller});
///   final VCustomStoryController controller;
///
///   @override
///   State<MyCustomStory> createState() => _MyCustomStoryState();
/// }
///
/// class _MyCustomStoryState extends State<MyCustomStory> {
///   @override
///   void initState() {
///     super.initState();
///     widget.controller.startLoading();
///     _loadData();
///   }
///
///   Future<void> _loadData() async {
///     try {
///       final data = await fetchData();
///       widget.controller.finishLoading();
///     } catch (e) {
///       widget.controller.setError(e.toString());
///     }
///   }
///   // ...
/// }
/// ```
abstract class VCustomStoryController {
  /// Signal that custom content is starting to load
  ///
  /// Call this when your widget needs to load data asynchronously.
  /// The progress bar will be paused until [finishLoading] is called.
  void startLoading();

  /// Signal that custom content has finished loading
  ///
  /// Call this when your data is ready and widget is fully initialized.
  /// The progress bar will resume automatically.
  void finishLoading();

  /// Pause the progress bar
  ///
  /// Use when custom content needs user interaction or processing.
  /// Must be paired with [resumeProgress] to continue the story.
  void pauseProgress();

  /// Resume the progress bar
  ///
  /// Call to continue progress after [pauseProgress].
  void resumeProgress();

  /// Notify system of an error in custom content
  ///
  /// Parameters:
  /// - [message]: Error description to display
  void setError(String message);

  /// Check if custom content is currently loading
  bool get isLoading;

  /// Get current error message if any
  String? get errorMessage;
}
