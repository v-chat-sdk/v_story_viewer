# V Reply System

## Purpose
Story reply/comment functionality.

## Key Components
- **VReplyController**: Reply management
- **VReplyInput**: Input field widget
- **VReplyList**: Reply display

## Usage
```dart
VReplyInput(
  onSubmit: (text) => sendReply(text),
  placeholder: 'Reply to story...',
)
```
