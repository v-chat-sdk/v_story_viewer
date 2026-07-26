# V Story Viewer Example

This app demonstrates the story types, navigation modes, customization options,
and synchronized background music provided by `v_story_viewer`.

## Run the Example

```sh
flutter pub get
flutter run -d <device>
```

Open the **Music** tab and select:

- **Music Timing** to test looping, clipped duration policies, press-and-hold
  pause/resume, next/previous navigation, and app backgrounding.
- **Music Mixing** to compare `duckOriginal`, `replaceOriginal`, and `mix`
  against video or voice-story audio.

The demo streams public media URLs, so it requires an internet connection.
Music failures are shown as a non-fatal snackbar while the story continues.
On web, tap the viewer's speaker icon once because browsers initially require
a user gesture before allowing audible playback.
