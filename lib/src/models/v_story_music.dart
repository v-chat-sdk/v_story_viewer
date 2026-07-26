import 'package:flutter/foundation.dart';
import 'package:v_platform/v_platform.dart';

/// Controls how a story duration is resolved when background music is present.
enum VStoryMusicDurationPolicy {
  /// Keep the story's explicit or content-derived duration.
  keepStoryDuration,

  /// Use the selected music clip duration.
  matchMusicClip,

  /// End when either the story content or selected music clip ends.
  shortest,
}

/// Controls how background music is mixed with a story's original audio.
enum VStoryMusicMixPolicy {
  /// Play the original audio and background music at their configured volumes.
  mix,

  /// Lower the original audio while background music is playing.
  duckOriginal,

  /// Mute the original audio and play only the background music.
  replaceOriginal,
}

/// Optional background music attached to a story.
///
/// [source] accepts URL, local path, bytes, and Flutter asset sources through
/// [VPlatformFile]. The viewer owns playback and keeps it synchronized with the
/// story timeline across pause, resume, and navigation.
@immutable
class VStoryMusic {
  /// Music file to play.
  final VPlatformFile source;

  /// First position in the music source to play.
  final Duration clipStart;

  /// Optional exclusive end position in the music source.
  ///
  /// When omitted, the detected source duration is used.
  final Duration? clipEnd;

  /// How music affects the story's effective duration.
  final VStoryMusicDurationPolicy durationPolicy;

  /// How music is mixed with video, voice, or custom story audio.
  final VStoryMusicMixPolicy mixPolicy;

  /// Background music volume from 0 (silent) to 1 (maximum).
  final double volume;

  /// Original content volume used by [VStoryMusicMixPolicy.duckOriginal].
  final double originalAudioVolume;

  /// Whether the selected clip repeats until the story ends.
  final bool loop;

  VStoryMusic({
    required this.source,
    this.clipStart = Duration.zero,
    this.clipEnd,
    this.durationPolicy = VStoryMusicDurationPolicy.keepStoryDuration,
    this.mixPolicy = VStoryMusicMixPolicy.duckOriginal,
    this.volume = 0.35,
    this.originalAudioVolume = 0.2,
    this.loop = true,
  }) {
    if (clipStart.isNegative) {
      throw ArgumentError.value(
        clipStart,
        'clipStart',
        'Cannot be negative.',
      );
    }
    if (clipEnd != null && clipEnd! <= clipStart) {
      throw ArgumentError.value(
        clipEnd,
        'clipEnd',
        'Must be later than clipStart.',
      );
    }
    if (volume < 0 || volume > 1) {
      throw ArgumentError.value(volume, 'volume', 'Must be between 0 and 1.');
    }
    if (originalAudioVolume < 0 || originalAudioVolume > 1) {
      throw ArgumentError.value(
        originalAudioVolume,
        'originalAudioVolume',
        'Must be between 0 and 1.',
      );
    }
  }

  /// Resolves the playable clip length from the configured bounds and detected
  /// source duration.
  Duration? resolveClipDuration(Duration? sourceDuration) {
    var resolvedEnd = clipEnd ?? sourceDuration;
    if (sourceDuration != null &&
        resolvedEnd != null &&
        resolvedEnd > sourceDuration) {
      resolvedEnd = sourceDuration;
    }
    if (resolvedEnd == null || resolvedEnd <= clipStart) return null;
    return resolvedEnd - clipStart;
  }
}
