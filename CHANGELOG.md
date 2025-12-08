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
