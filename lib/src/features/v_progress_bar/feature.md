# V Progress Bar

## Purpose
Count-based animated progress indicators showing multi-step progression.

## Key Components
- **VProgressController**: Manages progress state and animations using bar count
- **VSegmentedProgress**: Displays multiple progress bars with WhatsApp-style behavior
- **VProgressStyle**: Style configuration for progress bars
- **VProgressCallbacks**: Callbacks for progress events

## Architecture
Uses **count-based** approach for clean separation of concerns:
- Progress bar only knows about bar count and indices (pure UI concern)
- Orchestrator (VStoryViewer) maps story indices to bar indices
- No coupling to story business logic

## Usage
```dart
// Create controller with bar count
final controller = VProgressController(
  barCount: 5,
  barDuration: Duration(seconds: 3),
  callbacks: VProgressCallbacks(
    onBarComplete: (index) => print('Bar $index completed'),
    onProgressUpdate: (progress) => print('Progress: $progress'),
  ),
);

// Display progress bars
VSegmentedProgress(
  controller: controller,
  style: VProgressStyle.whatsapp, // or VProgressStyle.instagram
)

// Control progress
controller.startProgress(2);  // Start bar at index 2
controller.pauseProgress();
controller.resumeProgress();
controller.jumpToBar(4);      // Jump to bar 4
```

## API
### VProgressController
- `barCount`: Number of progress bars (required)
- `barDuration`: Duration for each bar (required)
- `callbacks`: Event callbacks (optional)

### Methods
- `startProgress(int index)`: Start animating bar at index
- `pauseProgress()`: Pause current animation
- `resumeProgress()`: Resume current animation
- `resetProgress()`: Reset current bar to 0.0
- `jumpToBar(int index)`: Jump to specific bar
- `getProgress(int index)`: Get progress value for bar (0.0-1.0)
