import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

const _musicUrl =
    'https://mdn.github.io/webaudio-examples/audio-basics/outfoxing.mp3';
const _voiceUrl = 'https://media.w3.org/2010/07/bunny/04-Death_Becomes_Fur.mp3';
const _videoUrl = 'https://media.w3.org/2010/05/sintel/trailer.mp4';

List<VStoryGroup> createMusicStories() {
  final now = DateTime.now();

  return [
    VStoryGroup(
      user: const VStoryUser(
        id: 'music_timing',
        name: 'Music Timing',
        imageUrl: 'https://i.pravatar.cc/150?u=music-timing',
      ),
      stories: [
        VTextStory(
          text: 'KEEP STORY DURATION\n\n'
              'This story lasts 10 seconds.\n'
              'The 4-second music clip loops.\n\n'
              'Press and hold to test synchronized pause and resume.',
          backgroundColor: const Color(0xFF4C1D95),
          duration: const Duration(seconds: 10),
          createdAt: now.subtract(const Duration(minutes: 6)),
          isSeen: false,
          music: VStoryMusic(
            source: VPlatformFile.fromUrl(networkUrl: _musicUrl),
            clipStart: const Duration(seconds: 10),
            clipEnd: const Duration(seconds: 14),
            durationPolicy: VStoryMusicDurationPolicy.keepStoryDuration,
            volume: 0.35,
            loop: true,
          ),
        ),
        VImageStory(
          url: 'https://picsum.photos/seed/music-duration/1080/1920',
          caption:
              'MATCH MUSIC: this story ends with its six-second music clip.',
          duration: const Duration(seconds: 20),
          createdAt: now.subtract(const Duration(minutes: 5)),
          isSeen: false,
          music: VStoryMusic(
            source: VPlatformFile.fromUrl(networkUrl: _musicUrl),
            clipStart: const Duration(seconds: 20),
            clipEnd: const Duration(seconds: 26),
            durationPolicy: VStoryMusicDurationPolicy.matchMusicClip,
            volume: 0.35,
            loop: false,
          ),
        ),
        VTextStory(
          text: 'SHORTEST DURATION\n\n'
              'The story requests 10 seconds.\n'
              'The selected music clip is 5 seconds.\n\n'
              'The story should advance after 5 seconds.',
          backgroundColor: const Color(0xFF0F766E),
          duration: const Duration(seconds: 10),
          createdAt: now.subtract(const Duration(minutes: 4)),
          isSeen: false,
          music: VStoryMusic(
            source: VPlatformFile.fromUrl(networkUrl: _musicUrl),
            clipStart: const Duration(seconds: 30),
            clipEnd: const Duration(seconds: 35),
            durationPolicy: VStoryMusicDurationPolicy.shortest,
            volume: 0.35,
            loop: false,
          ),
        ),
      ],
    ),
    VStoryGroup(
      user: const VStoryUser(
        id: 'music_mixing',
        name: 'Music Mixing',
        imageUrl: 'https://i.pravatar.cc/150?u=music-mixing',
      ),
      stories: [
        VVideoStory(
          url: _videoUrl,
          caption:
              'DUCK ORIGINAL: video audio remains audible below the music.',
          duration: const Duration(seconds: 10),
          createdAt: now.subtract(const Duration(minutes: 3)),
          isSeen: false,
          music: VStoryMusic(
            source: VPlatformFile.fromUrl(networkUrl: _musicUrl),
            clipStart: const Duration(seconds: 40),
            clipEnd: const Duration(seconds: 50),
            durationPolicy: VStoryMusicDurationPolicy.keepStoryDuration,
            mixPolicy: VStoryMusicMixPolicy.duckOriginal,
            originalAudioVolume: 0.15,
            volume: 0.4,
            loop: false,
          ),
        ),
        VVideoStory(
          url: _videoUrl,
          caption: 'REPLACE ORIGINAL: only the background music is audible.',
          duration: const Duration(seconds: 10),
          createdAt: now.subtract(const Duration(minutes: 2)),
          isSeen: false,
          music: VStoryMusic(
            source: VPlatformFile.fromUrl(networkUrl: _musicUrl),
            clipStart: const Duration(seconds: 50),
            clipEnd: const Duration(minutes: 1),
            durationPolicy: VStoryMusicDurationPolicy.keepStoryDuration,
            mixPolicy: VStoryMusicMixPolicy.replaceOriginal,
            volume: 0.4,
            loop: false,
          ),
        ),
        VVoiceStory(
          url: _voiceUrl,
          caption:
              'MIX: the voice-story audio and background music play together.',
          backgroundColor: const Color(0xFF1E3A8A),
          duration: const Duration(seconds: 10),
          createdAt: now.subtract(const Duration(minutes: 1)),
          isSeen: false,
          music: VStoryMusic(
            source: VPlatformFile.fromUrl(networkUrl: _musicUrl),
            clipStart: const Duration(minutes: 1),
            clipEnd: const Duration(minutes: 1, seconds: 10),
            durationPolicy: VStoryMusicDurationPolicy.keepStoryDuration,
            mixPolicy: VStoryMusicMixPolicy.mix,
            volume: 0.25,
            loop: false,
          ),
        ),
      ],
    ),
  ];
}
