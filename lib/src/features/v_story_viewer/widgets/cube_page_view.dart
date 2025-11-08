import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/v_story_transition.dart';

/// A PageView with 3D cube transition effect or fade animation
///
/// Creates either a 3D cube rotation effect or fade animation when transitioning between pages.
/// Supports both horizontal and vertical swipe directions.
///
/// **Usage:**
/// ```dart
/// CubePageView(
///   controller: _pageController,
///   itemCount: items.length,
///   scrollDirection: Axis.horizontal,
///   transitionType: VTransitionType.slide,
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
    this.scrollDirection = Axis.horizontal,
    this.transitionType = VTransitionType.slide,
  });

  final PageController controller;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final bool pageSnapping;
  final ScrollPhysics? physics;

  /// 3D perspective depth (smaller = less pronounced, larger = more pronounced)
  final double perspective;

  /// Custom rotation angle multiplier (default: π/2 for 90° rotation)
  final double? rotationAngle;

  /// Scroll direction for page navigation (horizontal or vertical)
  final Axis scrollDirection;

  /// Transition type for page changes (slide/fade/zoom)
  final VTransitionType transitionType;

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
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
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
      scrollDirection: widget.scrollDirection,
      itemBuilder: (context, index) => _buildPage(index),
    );
  }

  Widget _buildPage(int index) {
    return switch (widget.transitionType) {
      VTransitionType.fade => _buildFadePage(index),
      VTransitionType.zoom => _buildZoomPage(index),
      VTransitionType.slide => _buildCubePage(index),
    };
  }

  Widget _buildFadePage(int index) {
    final pageOffset = _calculatePageOffset(index);
    final opacity = (1.0 - pageOffset.abs()).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: widget.itemBuilder(context, index),
    );
  }

  Widget _buildZoomPage(int index) {
    final pageOffset = _calculatePageOffset(index);
    final scale = math.max(0.8, 1.0 - pageOffset.abs() * 0.2);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: (1.0 - pageOffset.abs()).clamp(0.0, 1.0),
        child: widget.itemBuilder(context, index),
      ),
    );
  }

  Widget _buildCubePage(int index) {
    final pageOffset = _calculatePageOffset(index);
    final rotationAngle = widget.rotationAngle ?? (math.pi / 2);
    final alignment = _getRotationAlignment(pageOffset);

    return Transform(
      alignment: alignment,
      transform: _createTransformMatrix(pageOffset, rotationAngle),
      child: widget.itemBuilder(context, index),
    );
  }

  double _calculatePageOffset(int index) {
    try {
      if (widget.controller.positions.isEmpty) {
        return 0;
      }
      if (widget.controller.positions.length > 1) {
        return 0;
      }
      if (!widget.controller.position.haveDimensions) {
        return 0;
      }

      final page = widget.controller.page ?? 0;
      final offset = page - index;
      return offset.clamp(-1, 1);
    } catch (e) {
      return 0;
    }
  }

  Alignment _getRotationAlignment(double pageOffset) {
    if (widget.scrollDirection == Axis.horizontal) {
      return pageOffset > 0 ? Alignment.centerLeft : Alignment.centerRight;
    } else {
      return pageOffset > 0 ? Alignment.topCenter : Alignment.bottomCenter;
    }
  }

  Matrix4 _createTransformMatrix(double pageOffset, double rotationAngle) {
    final matrix = Matrix4.identity()..setEntry(3, 2, widget.perspective);

    if (widget.scrollDirection == Axis.horizontal) {
      matrix.rotateY(pageOffset * rotationAngle);
    } else {
      matrix.rotateX(pageOffset * rotationAngle);
    }

    return matrix;
  }
}
