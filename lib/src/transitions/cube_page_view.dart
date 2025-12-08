import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Cube page view transition for story groups
class CubePageView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final PageController? controller;
  final void Function(int index)? onPageChanged;
  final void Function()? onDragStart;
  final void Function()? onDragEnd;
  final void Function()? onDragCancel;
  const CubePageView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.onPageChanged,
    this.onDragStart,
    this.onDragEnd,
    this.onDragCancel,
  });
  @override
  State<CubePageView> createState() => _CubePageViewState();
}

class _CubePageViewState extends State<CubePageView> {
  late PageController _controller;
  late double _currentPage;
  bool _isDragging = false;
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PageController();
    _currentPage = _controller.initialPage.toDouble();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _currentPage = _controller.page ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          if (!_isDragging) {
            _isDragging = true;
            widget.onDragStart?.call();
          }
        } else if (notification is ScrollEndNotification) {
          if (_isDragging) {
            _isDragging = false;
            final page = _controller.page?.round() ?? 0;
            if (page == _controller.initialPage) {
              widget.onDragCancel?.call();
            } else {
              widget.onDragEnd?.call();
            }
          }
        }
        return false;
      },
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.itemCount,
        physics: const BouncingScrollPhysics(),
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          final diff = index - _currentPage;
          return _buildCubePage(
            child: widget.itemBuilder(context, index),
            index: index,
            diff: diff,
          );
        },
      ),
    );
  }

  Widget _buildCubePage({
    required Widget child,
    required int index,
    required double diff,
  }) {
    // No transformation when page is fully visible
    if (diff.abs() < 0.001) {
      return child;
    }
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final rotationY = diff * (isRtl ? 90 : -90) * math.pi / 180;
    final alignment = diff > 0
        ? (isRtl ? Alignment.centerLeft : Alignment.centerRight)
        : (isRtl ? Alignment.centerRight : Alignment.centerLeft);
    return Transform(
      alignment: alignment,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..rotateY(rotationY),
      child: RepaintBoundary(child: child),
    );
  }
}
