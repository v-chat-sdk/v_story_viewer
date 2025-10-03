# V Gesture Detector

## Purpose
Handles user interactions - taps, swipes, long press.

## Key Components
- **VGestureController**: Processes gesture events
- **VTapZoneDetector**: Left/right/center tap zones
- **VSwipeHandler**: Vertical swipe detection

## Gestures
- **Tap left**: Previous story
- **Tap right**: Next story
- **Long press**: Pause
- **Swipe right**: Show next user stories 
- **Swipe left**: Show Previous user stories 
- **Swipe down**: Close viewer

## Usage
```dart
VGestureDetector(
  onTapLeft: () => previousStory(),
  onTapRight: () => nextStory(),
  onLongPress: () => pause(),
etc...
)
```
