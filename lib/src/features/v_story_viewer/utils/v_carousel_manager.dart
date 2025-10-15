import 'package:flutter/material.dart';

import '../models/v_story_viewer_config.dart';

/// Manages carousel scrolling state and behavior
///
/// Handles carousel scroll detection and pause/resume logic.
class VCubePageManager {
  VCubePageManager({
    required VStoryViewerConfig config,
    required this.onScrollStateChanged,
  }) : _config = config;

  final VStoryViewerConfig _config;
  final void Function(bool isScrolling) onScrollStateChanged;

  bool _isCarouselScrolling = false;
  PageController? _pageController;

  bool get isScrolling => _isCarouselScrolling;
  PageController? get pageController => _pageController;

  /// Initialize page controller for carousel mode
  void initializePageController(int initialPage) {
    _pageController = PageController(initialPage: initialPage);
    _pageController!.addListener(_handleCarouselScrolled);
  }

  void _handleCarouselScrolled() {
    if (!_config.pauseOnCarouselScroll) return;
    if (_pageController == null) return;

    final isScrolling = _pageController!.position.isScrollingNotifier.value;

    if (_isCarouselScrolling == isScrolling) return;

    _isCarouselScrolling = isScrolling;
    onScrollStateChanged(isScrolling);
  }

  /// Navigate to next page in carousel
  void nextPage() {
    _pageController?.nextPage(
      duration: _config.carouselAnimationDuration,
      curve: Curves.easeInOut,
    );
  }

  /// Navigate to previous page in carousel
  void previousPage() {
    _pageController?.previousPage(
      duration: _config.carouselAnimationDuration,
      curve: Curves.easeInOut,
    );
  }

  void dispose() {
    _pageController?.removeListener(_handleCarouselScrolled);
    _pageController?.dispose();
    _pageController = null;
  }
}
