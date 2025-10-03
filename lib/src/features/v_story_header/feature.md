# V Story Header

## Purpose
Top header with user info and close button.

## Key Components
- **VStoryHeader**: Header container
- **VUserInfo**: Avatar and username
- **VTimestamp**: Story time display

## Usage
```dart
VStoryHeader(
  user: storyUser,
  timestamp: story.timestamp,
  onClose: () => Navigator.pop(context),
)
```
