import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

/// Test screen for v_progress_bar feature
///
/// Tests all use cases:
/// - Start/Pause/Resume progress
/// - Jump to specific bar
/// - Different bar counts
/// - Different styles (WhatsApp, Instagram)
/// - Callbacks (onBarComplete, onProgressUpdate)
class ProgressTestScreen extends StatefulWidget {
  const ProgressTestScreen({super.key});

  @override
  State<ProgressTestScreen> createState() => _ProgressTestScreenState();
}

class _ProgressTestScreenState extends State<ProgressTestScreen> {
  late VProgressController _controller;
  VProgressStyle _currentStyle = VProgressStyle.whatsapp;
  int _lastCompletedBar = -1;
  double _currentProgressValue = 0;
  int _barCount = 4;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = VProgressController(
      barCount: _barCount,
      callbacks: VProgressCallbacks(
        onBarComplete: (index) {
          setState(() {
            _lastCompletedBar = index;
          });

          // Auto-advance to next bar
          if (index < _controller.barCount - 1) {
            _controller.startProgress(index + 1, const Duration(seconds: 5));
          }
        },
        onProgressUpdate: (progress) {
          setState(() {
            _currentProgressValue = progress;
          });
        },

      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startProgress(int index, Duration duration) {
    _controller.startProgress(index, duration);
    setState(() {});
  }

  void _pauseProgress() {
    _controller.pauseProgress();
    setState(() {});
  }

  void _resumeProgress() {
    _controller.resumeProgress();
    setState(() {});
  }

  void _resetProgress() {
    _controller.resetProgress();
    setState(() {});
  }

  void _changeBarCount(int newCount) {
    _controller.dispose();
    setState(() {
      _barCount = newCount;
      _lastCompletedBar = -1;
      _currentProgressValue = 0;
    });
    _initController();
  }

  void _toggleStyle() {
    setState(() {
      _currentStyle = _currentStyle == VProgressStyle.whatsapp
          ? VProgressStyle.instagram
          : VProgressStyle.whatsapp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Progress Bar Test'),
        backgroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Progress bar display area
            Container(
              height: 200,
              color: Colors.grey[900],
              child: Center(
                child: VSegmentedProgress(
                  controller: _controller,
                  style: _currentStyle,

                ),
              ),
            ),

            // Status info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(),
                const SizedBox(height: 16),
                _buildStoryControlsCard(),
                const SizedBox(height: 16),
                _buildGroupControlsCard(),
                const SizedBox(height: 16),
                _buildStyleControlsCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildStatusRow('Current Index', '${_controller.currentIndex}'),
            _buildStatusRow('Progress', '${(_currentProgressValue * 100).toStringAsFixed(1)}%'),
            _buildStatusRow('Is Running', _controller.isRunning ? 'Yes' : 'No'),
            _buildStatusRow('Last Completed', _lastCompletedBar == -1 ? 'None' : 'Bar $_lastCompletedBar'),
            _buildStatusRow('Total Bars', '${_controller.barCount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bar Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                _controller.barCount,
                (index) {
                  final isCurrentBar = _controller.currentIndex == index;
                  return ElevatedButton(
                    onPressed: () => _startProgress(index, const Duration(seconds: 5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentBar ? Colors.green : null,
                    ),
                    child: Text('Bar $index'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controller.isRunning ? _pauseProgress : null,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !_controller.isRunning && _controller.currentIndex != -1
                        ? _resumeProgress
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_controller.currentIndex != -1)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetProgress,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Current Bar'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bar Count Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const Text(
              'Change the number of progress bars',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [3, 4, 5, 6].map((count) {
                final isSelected = _barCount == count;
                return ElevatedButton(
                  onPressed: () => _changeBarCount(count),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blue : null,
                  ),
                  child: Text('$count bars'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Style',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleStyle,
                icon: const Icon(Icons.palette),
                label: Text(
                  'Current: ${_currentStyle == VProgressStyle.whatsapp ? "WhatsApp" : "Instagram"}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
