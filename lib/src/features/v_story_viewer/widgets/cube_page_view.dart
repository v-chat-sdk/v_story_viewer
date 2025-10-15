import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A PageView with 3D cube transition effect
///
/// Creates a 3D cube rotation effect when transitioning between pages.
/// Each page rotates along the Y-axis creating a cube-like appearance.
///
/// **Usage:**
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
      itemBuilder: (context, index) => _buildCubePage(index),
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
    if (!widget.controller.position.haveDimensions) {
      return 0;
    }

    final page = widget.controller.page ?? 0;
    final offset = page - index;
    return offset.clamp(-1, 1);
  }

  Alignment _getRotationAlignment(double pageOffset) {
    return pageOffset > 0 ? Alignment.centerLeft : Alignment.centerRight;
  }

  Matrix4 _createTransformMatrix(double pageOffset, double rotationAngle) {
    return Matrix4.identity()
      ..setEntry(3, 2, widget.perspective)
      ..rotateY(pageOffset * rotationAngle);
  }
}
