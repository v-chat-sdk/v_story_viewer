## 2.1.1

### New Features
* **Expandable Captions** - Story captions now show 2 lines collapsed with a "more" indicator. Tap to expand full text (scrollable). Story progress pauses while caption is expanded and resumes on collapse.

## 2.1.0

### New Features
* **Group Scroll Direction** - Configure story group navigation axis via `VStoryConfig.groupScrollDirection` (horizontal/vertical).
* **Vertical Demo Tab** - Example app now includes a vertical paging tab.
* add `onReplyFocusChanged` to the `StoryFooterBuilder footerBuilder` so you can create your own style and change the **focus** of the story
### Notes
* Vertical group paging uses a standard PageView (no cube) and disables swipe up/down callbacks to avoid gesture conflicts.

## 2.0.2

### New Features
* **Built-in Text Parser** - Lightweight regex-based text parsing for `VTextStory`:
  * **Markdown-style formatting**: Bold (`**text**`, `__text__`), Italic (`*text*`, `_text_`), Inline code (`` `code` ``)
  * **Auto-detected links**: URLs (http/https/www), Emails, Phone numbers
  * **Social patterns**: @mentions, #hashtags
  * **Markdown links**: `[text](url)` syntax
* **Tap Callbacks** - Handle user interactions with parsed elements:
  * `onUrlTap(String url)` - URL/link taps
  * `onPhoneTap(String phone)` - Phone number taps
  * `onEmailTap(String email)` - Email taps
  * `onMentionTap(String mention)` - @mention taps (without @)
  * `onHashtagTap(String hashtag)` - #hashtag taps (without #)
* **Custom Styling** - Override default styles for each parsed element type
* **Zero Dependencies** - No external markdown or parsing packages required

### Usage
```dart
VTextStory(
  text: 'Hello **World**! Contact @john at john@email.com #flutter',
  enableParsing: true,
  parserConfig: VTextParserConfig(
    onMentionTap: (mention) => openProfile(mention),
    onHashtagTap: (tag) => searchHashtag(tag),
    onUrlTap: (url) => launchUrl(url),
    onPhoneTap: (phone) => launchDialer(phone),
    onEmailTap: (email) => launchEmail(email),
    // Optional custom styles
    boldStyle: TextStyle(fontWeight: FontWeight.w900),
    mentionStyle: TextStyle(color: Colors.blue),
  ),
  backgroundColor: Colors.purple,
  createdAt: DateTime.now(),
  isSeen: false,
)
```

## 2.0.1

### Breaking Changes
* **Enhanced Error Handling**: `onError` callback now receives `VStoryError` instead of `Object`
  * Enables pattern matching for specific error handling
  * Includes original exception, stack trace, and structured error data

### New Features
* Added `VStoryError` sealed class with 6 error types:
  * `VStoryLoadError` - General content loading failure
  * `VStoryNetworkError` - Network connectivity issues
  * `VStoryTimeoutError` - Request timeout with duration info
  * `VStoryCacheError` - Cache read/write failures
  * `VStoryFormatError` - Unsupported media format
  * `VStoryPermissionError` - Storage/network permission denied
* Auto-classification of errors based on exception type and message
* All errors include `message`, `originalError`, and `stackTrace` fields
* **Preset Configurations** for cleaner API:
  * `VStoryConfig.forOwner()` - Optimized for viewing own stories (no reply, menu visible)
  * `VStoryConfig.forViewer()` - Optimized for viewing others' stories (reply + emoji visible)
  * `VStoryConfig.minimal()` - Clean, distraction-free viewing experience
* Added `VStoryConfig.copyWith()` method for easy config customization
* **Story `copyWith()` Methods** for immutable updates:
  * `VImageStory.copyWith()` - Create modified image story copies
  * `VVideoStory.copyWith()` - Create modified video story copies
  * `VTextStory.copyWith()` - Create modified text story copies
  * `VVoiceStory.copyWith()` - Create modified voice story copies
  * `VCustomStory.copyWith()` - Create modified custom story copies
* **VStoryGroup Helpers** for easier story management:
  * `unseenStories` - List of unseen stories
  * `seenStories` - List of seen stories
  * `firstUnseenStory` - First unseen story or null
  * `latestStory` - Most recently created story
  * `oldestStory` - Oldest story in the group

### Migration Guide

#### Error Handling
```dart
// Before (2.0.0)
onError: (group, item, error) {
  print('Error: $error');
}

// After (2.0.1)
onError: (group, item, error) {
  switch (error) {
    case VStoryNetworkError():
      showSnackBar('Check internet connection');
    case VStoryTimeoutError():
      showSnackBar('Request timed out');
    case VStoryCacheError():
      clearCache();
    case VStoryFormatError():
      log('Unsupported: ${error.format}');
    case VStoryPermissionError():
      requestPermission();
    case VStoryLoadError():
      log('Failed: ${error.message}');
  }
}
```

#### Preset Configurations
```dart
// Before (2.0.0) - Manual conditional configuration
VStoryViewer(
  config: VStoryConfig(
    showReplyField: !isMe,
    showEmojiButton: !isMe,
    showMenuButton: true,
  ),
  onMenuTap: isMe ? handleOwnerMenu : handleViewerMenu,
)

// After (2.0.1) - Clean preset configs
VStoryViewer(
  config: isMe ? VStoryConfig.forOwner() : VStoryConfig.forViewer(),
  onMenuTap: isMe ? handleOwnerMenu : handleViewerMenu,
)

// With customization
VStoryViewer(
  config: VStoryConfig.forViewer().copyWith(
    progressColor: Colors.blue,
    showEmojiButton: false,
  ),
)
```

#### Story copyWith
```dart
// Mark a story as seen
final seenStory = imageStory.copyWith(isSeen: true);

// Update caption
final updatedStory = videoStory.copyWith(caption: 'New caption!');
```

#### VStoryGroup Helpers
```dart
// Get unseen stories only
final unseen = group.unseenStories;

// Get the first unread story
final startAt = group.firstUnseenStory;

// Get the most recent story
final latest = group.latestStory;
```

## 2.0.0

* Complete rewrite with sealed classes for story types
* Added `VImageStory`, `VVideoStory`, `VTextStory`, `VVoiceStory`, `VCustomStory`
* 3D cube transitions between user stories
* Segmented progress bar with gradient ring indicator
* RTL support for Arabic/Hebrew layouts
* Keyboard navigation for desktop/web (arrow keys, space, escape)
* Custom overlay support via `overlayBuilder`
* Rich text support via `richText` and `textBuilder`
* Exponential backoff retry for failed media (5 attempts)
* 24-hour story expiry filtering
* Comprehensive callbacks: `onStoryViewed`, `onReply`, `onSwipeUp`, `onMenuTap`, etc.
* Custom header/footer builders via `VStoryConfig`
* i18n support via `VStoryTexts`
* Memory optimized: immediate dispose of video/audio controllers

## 1.0.0

* Initial release
