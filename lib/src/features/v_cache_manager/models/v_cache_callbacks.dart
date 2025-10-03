import 'dart:io';

/// Callbacks for cache manager events
///
/// These callbacks enable the orchestrator (VStoryViewer) to respond to
/// cache-related events. Use the progressStream for real-time progress updates.
class VCacheCallbacks {
  /// Creates cache callbacks
  const VCacheCallbacks({
    this.onDownloadStart,
    this.onCacheHit,
    this.onComplete,
    this.onError,
  });

  /// Called when a download starts for a network URL
  ///
  /// Useful for showing initial loading state before progress updates arrive
  final void Function(String url)? onDownloadStart;

  /// Called when a file is retrieved from cache (fast path)
  ///
  /// This means the file was already downloaded and is still valid.
  /// The media can be displayed immediately without waiting.
  final void Function(String url, File file)? onCacheHit;

  /// Called when a download completes successfully
  ///
  /// The file is now cached and ready to use
  final void Function(String url, File file)? onComplete;

  /// Called when a download fails after all retry attempts
  ///
  /// The orchestrator can decide to skip to the next story or show an error
  final void Function(String url, String error)? onError;

  /// Creates an empty callbacks instance (for testing or default usage)
  static const empty = VCacheCallbacks();
}
