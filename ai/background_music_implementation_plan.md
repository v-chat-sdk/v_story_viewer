# Background Music Playback and Synchronization Plan

## Status and Scope

Core implementation is complete. Focused unit/widget tests and Android, iOS
simulator, and web builds pass; the real-device audio-focus, codec, latency,
and browser-CORS matrix remains manual follow-up. This document records the
implemented design and the remaining platform validation scope.

## Key Decision

Use one authoritative story timeline. The progress bar, visual media, and background music must follow that timeline; they must never run as independent clocks.

The existing `AnimationController` remains the master clock because it already drives progress and completion. Audio/video positions are followers. Their positions are checked periodically and corrected only when drift exceeds a tolerance.

Music does not change story duration by default. A caller must explicitly choose a policy that lets music affect the story duration.

## Current Findings That Must Be Fixed First

1. [`_onContentLoaded`](../lib/src/widgets/v_story_viewer.dart) currently resolves duration as `reportedMediaDuration ?? item.duration ?? 5s`. This contradicts the model documentation: an explicit `VVideoStory.duration` or `VVoiceStory.duration` should override detected media duration.
2. [`VideoContent`](../lib/src/widgets/content/video_content.dart) and [`VoiceContent`](../lib/src/widgets/content/voice_content.dart) start playback before notifying the viewer that loading completed. Music cannot start on the same timeline boundary while this remains true.
3. A quick pointer tap currently resumes the old story before deciding whether to navigate. This can briefly restart old audio before the next story.
4. One `_isPaused` Boolean cannot safely represent overlapping pause causes such as manual pause, pointer hold, reply focus, group drag, and app background.
5. `_resetContent()` clears pause state during navigation. Group drag completion is not centrally coordinated.
6. Asynchronous load/error callbacks do not carry a story-session identity. A late callback from an old story can affect the new current story.
7. Existing tests cover models but not viewer timing, navigation, media lifecycle, or race conditions.

## Proposed Public API

Add `v_platform: ^2.1.5` and export a new model:

```dart
enum VStoryMusicDurationPolicy {
  keepStoryDuration,
  matchMusicClip,
  shortest,
}

enum VStoryMusicMixPolicy {
  mix,
  duckOriginal,
  replaceOriginal,
}

final class VStoryMusic {
  final VPlatformFile source;
  final Duration clipStart;
  final Duration? clipEnd;
  final VStoryMusicDurationPolicy durationPolicy;
  final VStoryMusicMixPolicy mixPolicy;
  final double volume;
  final double originalAudioVolume;
  final bool loop;
}
```

Add `VStoryMusic? music` to `VStoryItem` and forward it through every subtype constructor and `copyWith`. All parameters remain optional, so stories without music remain source-compatible.

Recommended defaults:

- `durationPolicy: keepStoryDuration`
- `mixPolicy: duckOriginal`
- `volume: 0.35`
- `originalAudioVolume: 0.2`
- `clipStart: Duration.zero`
- `loop: true`

Do not attach music to `VVoiceStory` by default. Voice plus background music should require an explicit mix policy.

## Duration Resolution

Resolve duration only after story content is ready and music metadata is ready, failed, or timed out.

```text
baseStoryDuration =
  item.duration
  ?? reportedContentDuration
  ?? config.defaultDuration

musicClipDuration =
  (clipEnd ?? detectedMusicDuration) - clipStart

effectiveDuration =
  keepStoryDuration -> baseStoryDuration
  matchMusicClip    -> musicClipDuration
  shortest         -> min(baseStoryDuration, musicClipDuration)
```

Rules:

- An explicit story duration always wins when calculating `baseStoryDuration`.
- `matchMusicClip` requires a finite, detected music duration and a valid clip.
- Invalid clips report a non-fatal music error. Unknown duration falls back to
  the base story duration when no explicit clip end is available.
- If music is longer than the story, stop it when the story ends.
- If music is shorter and `loop == true`, repeat the configured clip.
- If music is shorter and `loop == false`, the story continues silently.
- Music completion must never navigate directly. Only master-timeline completion may call “next.”

## Playback Coordinator

Coordinate playback through viewer session state plus the internal
`StoryMusicController`, with:

- A monotonically increasing session ID.
- Playback state derived from readiness, session identity, and pause reasons.
- The master `AnimationController`.
- Content and music readiness.
- Effective duration and current timeline position.
- A `Set<StoryPauseReason>` rather than one Boolean.
- Built-in video/voice widgets driven by the viewer's pause and volume state.
- A cached music position and one in-flight music synchronization guard.

Suggested pause reasons:

```dart
enum StoryPauseReason {
  preparing,
  manual,
  pointerHold,
  reply,
  caption,
  appLifecycle,
  groupDrag,
  callback,
}
```

Playback is active only when the session is ready and the pause-reason set is empty.

### Starting a Session

1. Increment the session ID and invalidate all old callbacks.
2. Stop the previous timeline and participants immediately.
3. Prepare visual content and music in parallel.
4. Keep every participant paused while preparing.
5. Resolve effective duration.
6. Seek music to `clipStart`.
7. Issue participant resume commands together and start the master timeline.
8. If music exceeds a bounded preparation timeout, start the story without it. If music becomes ready later, seek it to the current expected position before joining.

### Drift Correction

Do not seek on every animation frame. Cache audio positions from player streams and check approximately every 500 ms.

```text
elapsed = effectiveDuration * timelineProgress

expectedMusicPosition =
  clipStart + (
    loop
      ? elapsed modulo musicClipDuration
      : min(elapsed, musicClipDuration)
  )
```

If `abs(actual - expected)` exceeds a proposed 200 ms tolerance, seek once to the expected position. On every resume, seek before playing; this removes drift accumulated during pause or background transitions.

`audioplayers.seek()` changes position without changing playing state, which fits this coordinator. Native loop mode may introduce gaps, so clip looping should be managed and verified explicitly rather than assumed gapless.

## Interaction and Transition Matrix

| Event | Required coordinator behavior |
|---|---|
| Content load | Mark content ready; never autoplay independently |
| Music load | Mark music ready, validate clip, and participate in the start barrier |
| Quick next/previous tap | Keep `pointerHold`, invalidate old session, stop old music, navigate, then prepare the new session; never resume the old one |
| Auto-completion | Complete once from the master timeline and invalidate the session before navigating |
| Long press | Add `pointerHold`; remove it only on release/cancel |
| Keyboard/play button | Toggle only the `manual` pause reason |
| Reply focus | Add/remove `replyFocus`; it must not clear another reason |
| Caption expansion | Add/remove `captionExpanded` |
| Group drag | Add `groupDrag`; keep the selected group paused through `onPageChanged`; remove it after drag settles |
| App inactive/paused | Add `appBackground` |
| App resumed | Remove only `appBackground`; preserve manual, reply, or hold pauses |
| Mute/unmute | Change participant volumes without changing timeline position |
| Close/dispose | Invalidate session, cancel timers/subscriptions, stop and dispose every player |
| Music error | Report through `onMusicError`; continue the visual story |
| Content error | Preserve existing fatal handling, but guard its auto-skip timer with the session ID |

Previous-story navigation should restart that story and its configured music clip. Cross-story music continuity is intentionally out of initial scope; it can later be added with an explicit continuity key.

## `VPlatformFile` Source Adapter

Create a single tested adapter:

| Source | `audioplayers` source |
|---|---|
| URL | `UrlSource(fullNetworkUrl, mimeType: mimeType)` |
| Native path | `DeviceFileSource(fileLocalPath, mimeType: mimeType)` |
| Bytes | `BytesSource(Uint8List.fromList(bytes), mimeType: mimeType)` |
| Asset | `AssetSource(normalizedAssetPath, mimeType: mimeType)` |

Additional rules:

- Reject path sources on web; web file pickers must provide bytes.
- Validate audio using MIME type and extension because `VPlatformFile` currently classifies audio as a generic file.
- Use the actual MIME type; do not hardcode `audio/mpeg`.
- Reuse `StoryCacheManager` for remote URLs on supported platforms.
- Prefer URL/path for large tracks. Byte sources duplicate music in memory.
- Rely on `audioplayers` byte-source fallbacks on Apple/Linux platforms.
- Normalize asset paths without changing the application's global `AudioCache`.

## Implementation Phases

### Phase 1: Timing Foundation

- Correct duration precedence.
- Introduce session IDs and pause reasons.
- Centralize start, pause, resume, completion, and navigation.
- Fix pointer-up ordering, lifecycle resume behavior, group-drag settlement, and stale auto-skip callbacks.
- Add coordinator unit and viewer widget tests before music is introduced.

### Phase 2: Music Model and Source Layer

- Add `v_platform`.
- Add `VStoryMusic`, enums, validation, exports, and `copyWith` support.
- Add a player interface, `audioplayers` implementation, and `VPlatformFile` adapter.
- Keep plugin code behind an injectable interface so tests use a fake player.

### Phase 3: Participant Integration

- Add the background-music participant.
- Refactor built-in video and voice content so they prepare paused and follow coordinator commands.
- Apply independent music/original-media volumes.
- Add readiness timeout, late join, completion handling, and drift correction.

### Phase 4: Navigation, Cache, and Platform Hardening

- Preload the next story's remote music.
- Stop old playback before next/previous/group transitions.
- Start web playback muted and use the existing user play/unmute controls for
  autoplay-safe recovery.
- Validate CORS, MIME types, assets, byte fallback, audio focus, and disposal on every platform.

### Phase 5: Documentation and Example

- Add URL, path, bytes, and asset examples.
- Demonstrate image music, text music, video ducking, pause/resume, and rapid navigation.
- Update `README.md`, `CHANGELOG.md`, API docs, and example tests.

## Test Plan

### Unit Tests

- Duration-policy matrix, including explicit story override and invalid clips.
- Music-position calculation for start offsets, loop boundaries, and no-loop completion.
- Pause-reason independence.
- Session invalidation and stale callback rejection.
- All four `VPlatformFile` mappings and invalid-source errors.
- Drift threshold and one-seek-at-a-time behavior.

### Widget Tests With Fake Players

- Progress waits until required participants are ready.
- Video/voice/music do not autoplay during preparation.
- Pause freezes progress and every participant.
- Resume seeks to the expected position before playback.
- Quick next/previous never resumes the old player.
- Rapid repeated navigation cannot activate stale sources.
- Group drag, reply focus, manual pause, and app lifecycle do not clear each other.
- Music failure remains non-fatal.
- Content failure auto-skip cannot move a later session.
- Exactly one completion/viewed callback fires.

### Platform Integration Tests

- Android, iOS, web, Windows, macOS, and Linux.
- URL, local path, bytes, and asset playback where supported.
- Video plus music volume policy.
- Background/foreground and audio-focus behavior.
- Web autoplay rejection and recovery through a real user gesture.
- URL CORS/content-type failures.
- Repeated open/close and rapid navigation leak checks.

## Acceptance Criteria

1. Stories without music behave exactly as before, except for corrected duration and pause/navigation bugs.
2. Progress, built-in media, and music start from the same session boundary.
3. Real-device music drift remains within a proposed 250 ms bound and is corrected without audible seek thrashing.
4. No old music is audible after next, previous, group change, close, or disposal.
5. Pause position remains stable across long press, manual pause, reply focus, drag, and app background.
6. Resuming one pause reason never overrides another active reason.
7. A music load failure never blocks or skips otherwise valid story content.
8. Explicit story duration, music duration policies, clipping, looping, and volume mixing match their documented behavior.
9. Web autoplay failure produces a recoverable user action rather than silent desynchronization.
10. Formatter, analyzer, unit/widget tests, coverage, example build, and platform smoke tests pass.

## Validation Commands

```bash
dart format lib test example/lib example/test
flutter analyze
flutter test
flutter test --coverage
cd example && flutter analyze
cd example && flutter test
```

Manual device validation is still required because audio focus, codec support, autoplay, CORS, and playback latency differ by platform.

## Research References

- Flutter's `AnimationController` is a linear, frame-driven timeline and supports stopping and continuing from its current value: <https://api.flutter.dev/flutter/animation/AnimationController-class.html>
- `audioplayers` documents pause as position-preserving, stop as position-resetting, seek as position-only, player completion events, and loop caveats: <https://github.com/bluefireteam/audioplayers/blob/main/getting_started.md>
- Chrome may reject audible autoplay without user interaction, so playback success must not be assumed: <https://developer.chrome.com/blog/autoplay/>
- The workspace `VPlatformFile` implementation supports URL, path, bytes, and asset sources: [`v_platform_file.dart`](../../v_platform/lib/src/v_platform_file.dart)
- The workspace voice player already demonstrates `VPlatformFile` to `audioplayers` conversion for URL, path, and bytes: [`voice_audio_service.dart`](../../v_chat_voice_player/lib/src/services/voice_audio_service.dart)
