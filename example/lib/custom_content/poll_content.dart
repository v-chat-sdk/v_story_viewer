import 'package:flutter/material.dart';

class PollStoryContent extends StatefulWidget {
  const PollStoryContent({super.key});
  @override
  State<PollStoryContent> createState() => _PollStoryContentState();
}

class _PollStoryContentState extends State<PollStoryContent> {
  int? _selectedOption;
  final _votes = [42, 28, 15, 10];
  @override
  Widget build(BuildContext context) {
    final totalVotes = _votes.reduce((a, b) => a + b);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'What\'s your favorite Flutter feature?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ..._buildPollOptions(totalVotes),
              if (_selectedOption != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Total votes: $totalVotes',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPollOptions(int totalVotes) {
    final options = [
      'Hot Reload',
      'Widget System',
      'Cross-Platform',
      'Performance'
    ];
    return List.generate(options.length, (index) {
      final isSelected = _selectedOption == index;
      final hasVoted = _selectedOption != null;
      final percentage =
          hasVoted ? (_votes[index] / totalVotes * 100).round() : 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: _selectedOption == null
              ? () => setState(() => _selectedOption = index)
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isSelected ? 0.3 : 0.15),
              borderRadius: BorderRadius.circular(12),
              border:
                  isSelected ? Border.all(color: Colors.white, width: 2) : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    options[index],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                if (hasVoted)
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
