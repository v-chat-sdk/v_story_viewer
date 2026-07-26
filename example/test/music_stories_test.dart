import 'package:example/data/music_stories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  group('music example stories', () {
    test('covers every duration policy with explicit clip bounds', () {
      final timingStories = createMusicStories().first.stories;
      final music = timingStories.map((story) => story.music!).toList();

      expect(
        music.map((item) => item.durationPolicy),
        [
          VStoryMusicDurationPolicy.keepStoryDuration,
          VStoryMusicDurationPolicy.matchMusicClip,
          VStoryMusicDurationPolicy.shortest,
        ],
      );
      expect(
        music.map((item) => item.resolveClipDuration(null)),
        const [
          Duration(seconds: 4),
          Duration(seconds: 6),
          Duration(seconds: 5),
        ],
      );
      expect(music.map((item) => item.loop), [true, false, false]);
    });

    test('covers every original-audio mixing policy', () {
      final mixingStories = createMusicStories()[1].stories;

      expect(mixingStories[0], isA<VVideoStory>());
      expect(mixingStories[1], isA<VVideoStory>());
      expect(mixingStories[2], isA<VVoiceStory>());
      expect(
        mixingStories.map((story) => story.music!.mixPolicy),
        [
          VStoryMusicMixPolicy.duckOriginal,
          VStoryMusicMixPolicy.replaceOriginal,
          VStoryMusicMixPolicy.mix,
        ],
      );
    });
  });
}
