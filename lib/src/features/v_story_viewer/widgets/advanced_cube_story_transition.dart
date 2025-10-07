import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A PageView with 3D cube transition effect
///
/// Usage:
/// ```dart
/// CubePageView(
///   controller: _pageController,
///   itemCount: items.length,
///   onPageChanged: (index) => print('Page: $index'),
///   itemBuilder: (context, index) => YourWidget(items[index]),
/// )
/// ```
class CubePageView extends StatefulWidget {
  const CubePageView({
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.onPageChanged,
    this.pageSnapping = true,
    this.physics,
    this.perspective = 0.001,
    this.rotationAngle,
  });

  /// Controller for the PageView
  final PageController controller;

  /// Number of pages
  final int itemCount;

  /// Builder for each page
  final IndexedWidgetBuilder itemBuilder;

  /// Called when the page changes
  final ValueChanged<int>? onPageChanged;

  /// Whether pages should snap
  final bool pageSnapping;

  /// Physics for the PageView
  final ScrollPhysics? physics;

  /// 3D perspective depth (default: 0.001)
  /// Smaller = less pronounced, Larger = more pronounced
  final double perspective;

  /// Custom rotation angle multiplier (default: π/2 for 90° rotation)
  final double? rotationAngle;

  @override
  State<CubePageView> createState() => _CubePageViewState();
}

class _CubePageViewState extends State<CubePageView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    // CRITICAL: Remove listener to prevent memory leaks
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Only rebuild if we're actually scrolling
    if (mounted && widget.controller.position.isScrollingNotifier.value) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      onPageChanged: widget.onPageChanged,
      itemCount: widget.itemCount,
      pageSnapping: widget.pageSnapping,
      physics: widget.physics,
      itemBuilder: (context, index) {
        return _buildCubePage(index);
      },
    );
  }

  Widget _buildCubePage(int index) {
    var page = 0.0;

    if (widget.controller.position.haveDimensions) {
      page = widget.controller.page ?? 0.0;
    }

    // Calculate rotation angle based on page offset
    var pageOffset = page - index;

    // Clamp the offset to prevent excessive rotation
    pageOffset = pageOffset.clamp(-1.0, 1.0);

    // Calculate rotation angle (default 90 degrees)
    final rotationAngle = widget.rotationAngle ?? (math.pi / 2);

    return Transform(
      alignment: pageOffset > 0 ? Alignment.centerLeft : Alignment.centerRight,
      transform: Matrix4.identity()
        ..setEntry(3, 2, widget.perspective) // Perspective
        ..rotateY(pageOffset * rotationAngle),
      child: widget.itemBuilder(context, index),
    );
  }
}

// =============================================================================
// USAGE EXAMPLE
// =============================================================================

class CubePageViewExample extends StatefulWidget {
  const CubePageViewExample({super.key});

  @override
  State<CubePageViewExample> createState() => _CubePageViewExampleState();
}

class _CubePageViewExampleState extends State<CubePageViewExample> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Page indicator
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Page ${_currentPage + 1} of 5',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Cube PageView
          Expanded(
            child: CubePageView(
              controller: _controller,
              itemCount: 5,
              // ✅ onPageChanged callback
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                print('📄 Page changed to: $index');
              },
              pageSnapping: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildPage(index);
              },
            ),
          ),

          // Navigation buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous button
                  ElevatedButton.icon(
                    onPressed: _currentPage > 0
                        ? () => _controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                  const SizedBox(width: 16),
                  // Next button
                  ElevatedButton.icon(
                    onPressed: _currentPage < 4
                        ? () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[index], colors[index].withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pages,
              size: 100,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 20),
            Text(
              'Page ${index + 1}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Swipe to navigate',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
