import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:v_platform/v_platform.dart';

import '../models/v_story_music.dart';
import '../utils/story_cache_manager.dart';

/// Result of preparing a background-music source.
@immutable
class StoryMusicPreparation {
  final Duration? sourceDuration;

  const StoryMusicPreparation({required this.sourceDuration});
}

/// Audio operations used by [StoryMusicController].
///
/// This boundary keeps timeline behavior testable without platform audio.
abstract interface class StoryMusicAudioPlayer {
  Stream<void> get onComplete;

  Stream<Duration> get onDurationChanged;

  Future<void> setReleaseMode(ReleaseMode releaseMode);

  Future<void> setSource(Source source);

  Future<Duration?> getDuration();

  Future<Duration?> getCurrentPosition();

  Future<void> setVolume(double volume);

  Future<void> seek(Duration position);

  Future<void> resume();

  Future<void> pause();

  Future<void> stop();

  Future<void> dispose();
}

final class AudioplayersStoryMusicAudioPlayer implements StoryMusicAudioPlayer {
  final AudioPlayer _player;

  AudioplayersStoryMusicAudioPlayer([AudioPlayer? player])
      : _player = player ?? AudioPlayer();

  @override
  Stream<void> get onComplete => _player.onPlayerComplete;

  @override
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  @override
  Future<Duration?> getCurrentPosition() => _player.getCurrentPosition();

  @override
  Future<Duration?> getDuration() => _player.getDuration();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setReleaseMode(ReleaseMode releaseMode) =>
      _player.setReleaseMode(releaseMode);

  @override
  Future<void> setSource(Source source) => _player.setSource(source);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}

/// Converts a [VPlatformFile] into an audioplayers [Source].
class StoryMusicSourceAdapter {
  const StoryMusicSourceAdapter._();

  static Future<Source> resolve(
    VPlatformFile file, {
    required bool enableCaching,
  }) async {
    final sourceCount = <bool>[
      file.isFromUrl,
      file.isFromPath,
      file.isFromBytes,
      file.isFromAssets,
    ].where((isPresent) => isPresent).length;
    if (sourceCount != 1) {
      throw ArgumentError(
        'Background music must contain exactly one VPlatformFile source.',
      );
    }

    final mimeType = file.mimeType ?? file.getMimeType;
    if (mimeType != null && !mimeType.toLowerCase().startsWith('audio/')) {
      throw ArgumentError.value(
        mimeType,
        'source.mimeType',
        'Background music must use an audio MIME type.',
      );
    }

    if (file.isFromPath) {
      if (kIsWeb) {
        throw UnsupportedError(
          'Local-path background music is not supported on web.',
        );
      }
      return DeviceFileSource(file.fileLocalPath!, mimeType: mimeType);
    }

    if (file.isFromBytes) {
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw ArgumentError('Background music bytes cannot be empty.');
      }
      return BytesSource(Uint8List.fromList(bytes), mimeType: mimeType);
    }

    if (file.isFromAssets) {
      final assetPath = file.assetsPath!;
      final normalizedPath = assetPath.startsWith('assets/')
          ? assetPath.substring('assets/'.length)
          : assetPath;
      if (normalizedPath.isEmpty) {
        throw ArgumentError('Background music asset path cannot be empty.');
      }
      return AssetSource(normalizedPath, mimeType: mimeType);
    }

    final url = file.fullNetworkUrl;
    if (url == null || url.isEmpty) {
      throw ArgumentError('Background music URL cannot be empty.');
    }
    if (enableCaching && StoryCacheManager.isCachingSupported) {
      final cached = await StoryCacheManager.instance.getCachedFile(
        file.getCachedUrlKey,
      );
      if (cached != null) {
        return DeviceFileSource(cached.path, mimeType: mimeType);
      }
    }
    return UrlSource(url, mimeType: mimeType);
  }
}

/// Keeps one background-music player aligned to the story progress timeline.
class StoryMusicController {
  static const syncInterval = Duration(milliseconds: 500);
  static const driftTolerance = Duration(milliseconds: 200);

  final StoryMusicAudioPlayer _player;
  final void Function(Object error, StackTrace stackTrace)? onError;
  late final StreamSubscription<void> _completionSubscription;
  Future<void> _operationQueue = Future<void>.value();

  VStoryMusic? _music;
  Duration? _sourceDuration;
  int _generation = 0;
  bool _shouldPlay = false;
  bool _syncPending = false;
  bool _disposed = false;

  StoryMusicController({
    StoryMusicAudioPlayer? player,
    this.onError,
  }) : _player = player ?? AudioplayersStoryMusicAudioPlayer() {
    _completionSubscription = _player.onComplete.listen((_) {
      unawaited(_handleCompletionSafely());
    });
  }

  VStoryMusic? get music => _music;

  Duration? get sourceDuration => _sourceDuration;

  Future<StoryMusicPreparation> prepare(
    VStoryMusic music, {
    required bool enableCaching,
    required double volume,
  }) {
    final generation = ++_generation;
    _shouldPlay = false;
    _music = null;
    _sourceDuration = null;
    return _enqueue(() async {
      await _player.stop();
      if (!_isCurrent(generation)) {
        return const StoryMusicPreparation(sourceDuration: null);
      }

      final source = await StoryMusicSourceAdapter.resolve(
        music.source,
        enableCaching: enableCaching,
      );
      if (!_isCurrent(generation)) {
        return const StoryMusicPreparation(sourceDuration: null);
      }

      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setSource(source);
      await _player.setVolume(volume.clamp(0.0, 1.0).toDouble());
      var duration = await _player.getDuration();
      if (duration == null) {
        try {
          duration = await _player.onDurationChanged.first.timeout(
            const Duration(seconds: 1),
          );
        } on TimeoutException {
          // Duration is optional unless the selected policy needs it.
        }
      }
      if (!_isCurrent(generation)) {
        return const StoryMusicPreparation(sourceDuration: null);
      }
      if (duration != null && music.resolveClipDuration(duration) == null) {
        throw ArgumentError(
          'Background music clipStart must be earlier than the source end.',
        );
      }

      _music = music;
      _sourceDuration = duration;
      await _player.seek(music.clipStart);
      return StoryMusicPreparation(sourceDuration: duration);
    });
  }

  Future<void> resumeAt(Duration storyElapsed) {
    final generation = _generation;
    _shouldPlay = true;
    return _enqueue(() async {
      final music = _music;
      if (!_isCurrent(generation) || music == null) return;
      final expected = expectedPosition(storyElapsed);
      await _player.seek(expected);
      if (_isAfterNonLoopClip(storyElapsed, music)) {
        _shouldPlay = false;
        return;
      }
      if (!_isCurrent(generation) || !_shouldPlay) return;
      await _player.resume();
    });
  }

  Future<void> pause() {
    final generation = _generation;
    _shouldPlay = false;
    return _enqueue(() async {
      if (!_isCurrent(generation) || _music == null) return;
      await _player.pause();
    });
  }

  Future<void> setVolume(double volume) {
    final generation = _generation;
    return _enqueue(() async {
      if (!_isCurrent(generation) || _music == null) return;
      await _player.setVolume(volume.clamp(0.0, 1.0).toDouble());
    });
  }

  Future<void> synchronize(Duration storyElapsed) {
    if (_syncPending || !_shouldPlay || _music == null || _disposed) {
      return Future<void>.value();
    }
    _syncPending = true;
    final generation = _generation;
    return _enqueue(() async {
      try {
        final music = _music;
        if (!_isCurrent(generation) || music == null || !_shouldPlay) return;
        if (_isAfterNonLoopClip(storyElapsed, music)) {
          _shouldPlay = false;
          await _player.pause();
          return;
        }
        final actual = await _player.getCurrentPosition();
        if (actual == null || !_isCurrent(generation)) return;
        final expected = expectedPosition(storyElapsed);
        final drift = (actual - expected).abs();
        if (drift > driftTolerance) {
          await _player.seek(expected);
        }
      } finally {
        _syncPending = false;
      }
    });
  }

  @visibleForTesting
  Duration expectedPosition(Duration storyElapsed) {
    final music = _music;
    if (music == null) return Duration.zero;
    final clipDuration = music.resolveClipDuration(_sourceDuration);
    if (clipDuration == null || clipDuration <= Duration.zero) {
      return music.clipStart + storyElapsed;
    }
    if (!music.loop && storyElapsed >= clipDuration) {
      return music.clipStart + clipDuration;
    }
    final elapsed = music.loop
        ? Duration(
            microseconds:
                storyElapsed.inMicroseconds % clipDuration.inMicroseconds,
          )
        : storyElapsed;
    return music.clipStart + elapsed;
  }

  Future<void> stop() {
    ++_generation;
    _shouldPlay = false;
    _music = null;
    _sourceDuration = null;
    return _enqueue(_player.stop);
  }

  Future<void> _handleCompletion() {
    final generation = _generation;
    return _enqueue(() async {
      final music = _music;
      if (!_isCurrent(generation) || music == null || !_shouldPlay) {
        return;
      }
      if (!music.loop) {
        _shouldPlay = false;
        return;
      }
      await _player.seek(music.clipStart);
      if (_isCurrent(generation) && _shouldPlay) {
        await _player.resume();
      }
    });
  }

  Future<void> _handleCompletionSafely() async {
    final generation = _generation;
    try {
      await _handleCompletion();
    } catch (error, stackTrace) {
      if (!_isCurrent(generation)) return;
      _shouldPlay = false;
      onError?.call(error, stackTrace);
    }
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  bool _isAfterNonLoopClip(Duration storyElapsed, VStoryMusic music) {
    if (music.loop) return false;
    final clipDuration = music.resolveClipDuration(_sourceDuration);
    return clipDuration != null && storyElapsed >= clipDuration;
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _operationQueue = _operationQueue.then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    ++_generation;
    _shouldPlay = false;
    await _completionSubscription.cancel();
    await _enqueue(_player.dispose);
  }
}
