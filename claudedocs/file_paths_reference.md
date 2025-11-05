# V-Story Viewer File Paths Reference

## Theme System Files

### Core Theme Models
- **Main Theme**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_theme_system/models/v_story_theme.dart`
- **Color Scheme**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_theme_system/models/v_color_scheme.dart`
- **Typography**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_theme_system/models/v_typography.dart`
- **Icon Theme**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_theme_system/models/v_icon_theme.dart`

### Theme Management
- **Theme Controller**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_theme_system/controllers/v_theme_controller.dart`
- **Theme Provider**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_theme_system/widgets/v_theme_provider.dart`

---

## Header Component Files (Responsive)

- **Header View**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_story_header/views/v_header_view.dart` (Lines: 103-114, 125)
- **Header Config**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_story_header/models/v_header_config.dart`
- **User Info Widget**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_story_header/widgets/v_user_info.dart` (Lines: 20-36)
- **Timestamp Widget**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_story_header/widgets/v_timestamp.dart` (Lines: 36-52)

---

## Gesture & Interaction Files (Responsive)

- **Gesture Wrapper**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_gesture_detector/widgets/v_gesture_wrapper.dart` (Lines: 65-68)
- **Gesture Config**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_gesture_detector/models/v_gesture_config.dart`

---

## Progress Bar Files (Theme-Based)

- **Segmented Progress**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_progress_bar/widgets/v_segmented_progress.dart`
- **Progress Style**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_progress_bar/models/v_progress_style.dart`
- **Progress Controller**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_progress_bar/controllers/v_progress_controller.dart`

---

## Main Story Viewer Files (Responsive)

- **VStoryViewer Widget**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_story_viewer/widgets/v_story_viewer.dart` (Lines: 66-79)
- **Story Viewer Config**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_story_viewer/models/v_story_viewer_config.dart`
- **Story Content Builder**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_story_viewer/widgets/builders/v_story_content_builder.dart` (Line: 45 - SafeArea)

---

## Media Viewer Files (Theme-Based)

- **Media Display**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_media_viewer/widgets/v_media_display.dart`
- **Image Viewer**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_media_viewer/widgets/v_image_viewer.dart`
- **Video Viewer**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_media_viewer/widgets/v_video_viewer.dart`
- **Text Viewer**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_media_viewer/widgets/v_text_viewer.dart`

---

## Reply System Files (Responsive)

- **Reply Input**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_reply_system/widgets/v_reply_input.dart` (Line: 157)
- **Reply View**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_reply_system/views/v_reply_view.dart`
- **Reply Config**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/features/v_reply_system/models/v_reply_config.dart`

---

## Constants & Utilities

- **Story Constants**: `/Users/hatemragap/flutter_projects/v_chat_projects/packages/v_story_viewer/lib/src/core/constants/v_story_constants.dart`

---

## Summary by Category

### Files Using MediaQuery (6 files)
1. `v_timestamp.dart` - Lines 37-38
2. `v_user_info.dart` - Lines 21-22
3. `v_header_view.dart` - Lines 104, 125
4. `v_gesture_wrapper.dart` - Lines 65, 68
5. `v_story_viewer.dart` - Line 67
6. `v_reply_input.dart` - Line 157

### Files Using SafeArea (1 file)
1. `v_story_content_builder.dart` - Line 45

### Theme Model Files (4 files)
1. `v_story_theme.dart`
2. `v_color_scheme.dart`
3. `v_typography.dart`
4. `v_icon_theme.dart`

### Theme Configuration Files (3 files)
1. `v_progress_style.dart`
2. `v_header_config.dart`
3. `v_reply_config.dart`

---

## Key Properties by File

### VStoryTheme Properties
- `borderRadius` (8.0)
- `elevation` (4.0)
- `animationDuration` (300ms)
- `progressBarHeight` (2.0)
- `progressBarSpacing` (4.0)
- `headerHeight` (60.0)
- `footerHeight` (60.0)
- `replyInputHeight` (48.0)
- `tapZoneWidth` (0.3 = 30%)
- `maxContentWidth` (600.0)
- `enableShadows` (true)
- `enableRippleEffect` (true)
- `enableHapticFeedback` (false)

### VColorScheme Properties (21 total)
- `primary`, `secondary`
- `background`, `surface`, `error`
- `onPrimary`, `onSecondary`, `onBackground`, `onSurface`, `onError`
- `progressBackground`, `progressForeground`
- `headerBackground`, `footerBackground`
- `overlayBackground`
- `shimmerBase`, `shimmerHighlight`

### VTypography Properties (18 total)
- `headline1` through `headline6`
- `subtitle1`, `subtitle2`
- `body1`, `body2`
- `caption`, `button`, `overline`
- `storyText`, `userName`, `timestamp`, `replyHint`, `errorText`

---

## Responsive Calculation Patterns Found

### Pattern 1: Font Size by Breakpoint
```dart
// Found in: v_timestamp.dart, v_user_info.dart
final screenWidth = MediaQuery.of(context).size.width;
if (screenWidth >= 1000) {
  // Desktop
} else if (screenWidth >= 600) {
  // Tablet
} else {
  // Mobile
}
```

### Pattern 2: Icon Size by Breakpoint
```dart
// Found in: v_header_view.dart
final screenWidth = MediaQuery.of(context).size.width;
if (screenWidth >= 1000) return 56;
else if (screenWidth >= 600) return 52;
else return 48;
```

### Pattern 3: Layout Width Constraint
```dart
// Found in: v_story_viewer.dart
final screenWidth = MediaQuery.of(context).size.width;
if (screenWidth >= 1000) return 700;
else if (screenWidth >= 600) return 600;
else return screenWidth - 16;
```

### Pattern 4: Safe Zone Calculation
```dart
// Found in: v_gesture_wrapper.dart
final headerSafeZoneHeight = MediaQuery.of(context).viewPadding.top + 60;
```

