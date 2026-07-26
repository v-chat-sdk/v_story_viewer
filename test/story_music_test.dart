import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/src/controllers/story_duration_resolver.dart';
import 'package:v_story_viewer/src/controllers/story_music_controller.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  group('VStoryMusic', () {
    test('is retained by story copyWith', () {
      final music = VStoryMusic(
        source: VPlatformFile.fromUrl(
          networkUrl: 'https://example.com/music.mp3',
        ),
      );
      final story = VImageStory(
        url: 'https://example.com/image.jpg',
        music: music,
        createdAt: DateTime.now(),
        isSeen: false,
      );

      expect(story.copyWith(isSeen: true).music, same(music));
    });

    test('validates clip bounds and volume', () {
      final source = VPlatformFile.fromUrl(
        networkUrl: 'https://example.com/music.mp3',
      );

      expect(
        () => VStoryMusic(
          source: source,
          clipStart: const Duration(seconds: 2),
          clipEnd: const Duration(seconds: 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => VStoryMusic(source: source, volume: 1.1),
        throwsArgumentError,
      );
    });
  });

  group('StoryDurationResolver', () {
    final source = VPlatformFile.fromUrl(
      networkUrl: 'https://example.com/music.mp3',
    );

    VImageStory storyWith(VStoryMusicDurationPolicy policy) => VImageStory(
          url: 'https://example.com/image.jpg',
          duration: const Duration(seconds: 12),
          music: VStoryMusic(
            source: source,
            clipStart: const Duration(seconds: 2),
            clipEnd: const Duration(seconds: 10),
            durationPolicy: policy,
          ),
          createdAt: DateTime.now(),
          isSeen: false,
        );

    test('keeps explicit story duration when requested', () {
      final duration = StoryDurationResolver.resolve(
        story: storyWith(VStoryMusicDurationPolicy.keepStoryDuration),
        fallbackDuration: const Duration(seconds: 5),
        contentDuration: const Duration(seconds: 30),
        musicSourceDuration: const Duration(seconds: 20),
      );

      expect(duration, const Duration(seconds: 12));
    });

    test('matches the selected music clip', () {
      final duration = StoryDurationResolver.resolve(
        story: storyWith(VStoryMusicDurationPolicy.matchMusicClip),
        fallbackDuration: const Duration(seconds: 5),
        contentDuration: const Duration(seconds: 30),
        musicSourceDuration: const Duration(seconds: 20),
      );

      expect(duration, const Duration(seconds: 8));
    });

    test('uses the shorter content or music duration', () {
      final duration = StoryDurationResolver.resolve(
        story: storyWith(VStoryMusicDurationPolicy.shortest),
        fallbackDuration: const Duration(seconds: 5),
        contentDuration: const Duration(seconds: 30),
        musicSourceDuration: const Duration(seconds: 20),
      );

      expect(duration, const Duration(seconds: 8));
    });
  });

  group('StoryMusicSourceAdapter', () {
    test('supports URL sources and preserves MIME type', () async {
      final source = await StoryMusicSourceAdapter.resolve(
        VPlatformFile.fromUrl(
          networkUrl: 'https://example.com/music.mp3',
        ),
        enableCaching: false,
      );

      expect(source, isA<UrlSource>());
      expect((source as UrlSource).url, 'https://example.com/music.mp3');
      expect(source.mimeType, 'audio/mpeg');
    });

    test('supports bytes and asset sources', () async {
      final bytesSource = await StoryMusicSourceAdapter.resolve(
        VPlatformFile.fromBytes(name: 'music.mp3', bytes: [1, 2, 3]),
        enableCaching: false,
      );
      final assetSource = await StoryMusicSourceAdapter.resolve(
        VPlatformFile.fromAssets(assetsPath: 'assets/audio/music.mp3'),
        enableCaching: false,
      );

      expect(bytesSource, isA<BytesSource>());
      expect((bytesSource as BytesSource).bytes, [1, 2, 3]);
      expect(assetSource, isA<AssetSource>());
      expect((assetSource as AssetSource).path, 'audio/music.mp3');
    });

    test('supports a local device file', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'v_story_music_test_',
      );
      addTearDown(() => tempDirectory.delete(recursive: true));
      final file = File('${tempDirectory.path}/music.mp3');
      await file.writeAsBytes([1, 2, 3]);

      final source = await StoryMusicSourceAdapter.resolve(
        VPlatformFile.fromPath(fileLocalPath: file.path),
        enableCaching: false,
      );

      expect(source, isA<DeviceFileSource>());
      expect((source as DeviceFileSource).path, file.path);
    });

    test('rejects a known non-audio file', () {
      expect(
        StoryMusicSourceAdapter.resolve(
          VPlatformFile.fromUrl(
            networkUrl: 'https://example.com/image.jpg',
          ),
          enableCaching: false,
        ),
        throwsArgumentError,
      );
    });
  });

  group('StoryMusicController', () {
    test('aligns resume, drift correction, pause, and looping', () async {
      final player = _FakeStoryMusicAudioPlayer(
        duration: const Duration(seconds: 10),
      );
      final controller = StoryMusicController(player: player);
      final music = VStoryMusic(
        source: VPlatformFile.fromBytes(
          name: 'music.mp3',
          bytes: [1, 2, 3],
        ),
        clipStart: const Duration(seconds: 2),
        clipEnd: const Duration(seconds: 6),
        loop: true,
      );

      final preparation = await controller.prepare(
        music,
        enableCaching: false,
        volume: 0.4,
      );
      expect(preparation.sourceDuration, const Duration(seconds: 10));
      expect(player.volume, 0.4);
      expect(player.seeks.last, const Duration(seconds: 2));

      await controller.resumeAt(const Duration(seconds: 9));
      expect(player.seeks.last, const Duration(seconds: 3));
      expect(player.resumeCount, 1);

      final seekCount = player.seeks.length;
      player.position = const Duration(milliseconds: 3100);
      await controller.synchronize(const Duration(seconds: 9));
      expect(player.seeks.length, seekCount);

      player.position = const Duration(seconds: 5);
      await controller.synchronize(const Duration(seconds: 9));
      expect(player.seeks.last, const Duration(seconds: 3));

      await controller.pause();
      expect(player.pauseCount, 1);

      await controller.resumeAt(const Duration(seconds: 2));
      player.complete.add(null);
      await Future<void>.delayed(Duration.zero);
      await controller.setVolume(0.5);
      expect(player.seeks.last, const Duration(seconds: 2));
      expect(player.resumeCount, 3);

      await controller.dispose();
      expect(player.isDisposed, isTrue);
    });

    test('does not replay past the end of a non-looping clip', () async {
      final player = _FakeStoryMusicAudioPlayer(
        duration: const Duration(seconds: 10),
      );
      final controller = StoryMusicController(player: player);
      await controller.prepare(
        VStoryMusic(
          source: VPlatformFile.fromBytes(
            name: 'music.mp3',
            bytes: [1, 2, 3],
          ),
          clipStart: const Duration(seconds: 2),
          clipEnd: const Duration(seconds: 6),
          loop: false,
        ),
        enableCaching: false,
        volume: 0.4,
      );

      await controller.resumeAt(const Duration(seconds: 3));
      expect(player.resumeCount, 1);

      await controller.synchronize(const Duration(seconds: 4));
      expect(player.pauseCount, 1);
      expect(player.resumeCount, 1);

      await controller.dispose();
    });

    test('reports loop restart failures without throwing from the stream',
        () async {
      final player = _FakeStoryMusicAudioPlayer(
        duration: const Duration(seconds: 10),
      );
      Object? reportedError;
      final controller = StoryMusicController(
        player: player,
        onError: (error, _) => reportedError = error,
      );
      await controller.prepare(
        VStoryMusic(
          source: VPlatformFile.fromBytes(
            name: 'music.mp3',
            bytes: [1, 2, 3],
          ),
        ),
        enableCaching: false,
        volume: 0.4,
      );
      await controller.resumeAt(Duration.zero);

      player.throwOnSeek = true;
      player.complete.add(null);
      await Future<void>.delayed(Duration.zero);
      await controller.setVolume(0.5);

      expect(reportedError, isA<StateError>());
      await controller.dispose();
    });

    test('waits briefly for delayed source duration metadata', () async {
      final player = _FakeStoryMusicAudioPlayer();
      final controller = StoryMusicController(player: player);
      Timer(const Duration(milliseconds: 10), () {
        player.durationChanges.add(const Duration(seconds: 7));
      });

      final preparation = await controller.prepare(
        VStoryMusic(
          source: VPlatformFile.fromBytes(
            name: 'music.mp3',
            bytes: [1, 2, 3],
          ),
        ),
        enableCaching: false,
        volume: 0.4,
      );

      expect(preparation.sourceDuration, const Duration(seconds: 7));
      await controller.dispose();
    });
  });
}

final class _FakeStoryMusicAudioPlayer implements StoryMusicAudioPlayer {
  final StreamController<void> complete = StreamController<void>.broadcast();
  final StreamController<Duration> durationChanges =
      StreamController<Duration>.broadcast();
  final Duration? duration;
  final List<Duration> seeks = [];

  Source? source;
  Duration? position = Duration.zero;
  double volume = 1;
  int pauseCount = 0;
  int resumeCount = 0;
  int stopCount = 0;
  bool isDisposed = false;
  bool throwOnSeek = false;

  _FakeStoryMusicAudioPlayer({this.duration});

  @override
  Stream<void> get onComplete => complete.stream;

  @override
  Stream<Duration> get onDurationChanged => durationChanges.stream;

  @override
  Future<Duration?> getCurrentPosition() async => position;

  @override
  Future<Duration?> getDuration() async => duration;

  @override
  Future<void> pause() async {
    pauseCount++;
  }

  @override
  Future<void> resume() async {
    resumeCount++;
  }

  @override
  Future<void> seek(Duration position) async {
    if (throwOnSeek) throw StateError('seek failed');
    seeks.add(position);
    this.position = position;
  }

  @override
  Future<void> setReleaseMode(ReleaseMode releaseMode) async {}

  @override
  Future<void> setSource(Source source) async {
    this.source = source;
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume = volume;
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  Future<void> dispose() async {
    isDisposed = true;
    await complete.close();
    await durationChanges.close();
  }
}
