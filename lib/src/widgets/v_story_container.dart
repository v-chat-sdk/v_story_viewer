import 'package:flutter/material.dart';
import '../models/v_story_models.dart';
import '../controllers/v_story_controller.dart';
import 'v_story_viewer.dart';
import 'v_story_progress_bar.dart';
import 'v_story_content.dart';
import 'v_story_header.dart';
import 'v_story_footer.dart';

/// Container widget for story content layout and positioning.
class VStoryContainer extends StatelessWidget {
  /// The story to display
  final VBaseStory story;

  /// The story controller
  final VStoryController controller;

  /// The story group
  final VStoryGroup group;

  /// Viewer configuration
  final VStoryViewerConfig config;

  /// Custom header builder
  final Widget Function(BuildContext, VStoryUser, VBaseStory)? headerBuilder;

  /// Custom footer builder
  final Widget Function(BuildContext, VBaseStory)? footerBuilder;

  /// Error widget builder
  final Widget Function(BuildContext, Object?)? errorBuilder;

  /// Loading widget builder
  final Widget Function(BuildContext)? loadingBuilder;

  /// Called when dismissed
  final VoidCallback? onDismiss;

  /// Creates a story container
  const VStoryContainer({
    super.key,
    required this.story,
    required this.controller,
    required this.group,
    required this.config,
    this.headerBuilder,
    this.footerBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Story content
        VStoryContentContainer(
          story: story,
          controller: controller,
          textStyle: config.textStoryStyle,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
        ),

        // Gradient overlays for better readability
        _buildGradientOverlays(context),

        // Gesture zones - must be after content but before UI elements
        if (config.enableGestures) ...[
          // Left tap zone for previous story (20% of screen width)
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: size.width * 0.4,
              height: size.height,
              child: GestureDetector(
                onTap: () => controller.previous(),
                // behavior: HitTestBehavior.opaque,
              ),
            ),
          ),

          // Right tap zone for next story (20% of screen width)
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: size.width * 0.4,
              height: size.height,
              child: GestureDetector(
                onTap: () => controller.next(),
                // behavior: HitTestBehavior.opaque,
              ),
            ),
          ),

          // Full screen overlay for long press pause/resume and vertical swipe
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: GestureDetector(
                onLongPressDown: (_) => controller.pause(),
                onLongPressUp: controller.play,
                onLongPressEnd: (_) => controller.play(),
                onLongPressCancel: controller.play,
                onVerticalDragEnd: config.gestureConfig.swipeEnabled
                    ? (details) {
                        // Swipe down to dismiss
                        if (details.velocity.pixelsPerSecond.dy > 
                            config.gestureConfig.swipeVelocityThreshold) {
                          onDismiss?.call();
                        }
                      }
                    : null,
                // behavior: HitTestBehavior.translucent,
              ),
            ),
          ),
        ],

        // Progress bars
        if (config.showProgressBars) _buildProgressBars(context),

        // Header
        if (config.showHeader) _buildHeader(context),

        // Footer
        if (config.showFooter) _buildFooter(context),
      ],
    );
  }

  Widget _buildGradientOverlays(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          // Top gradient for header visibility
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const Spacer(),
          // Bottom gradient for footer visibility
          if (config.showFooter)
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBars(BuildContext context) {
    final currentIndex = group.stories.indexOf(story);

    return Positioned(
      top: config.useSafeArea ? 0 : MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: VStoryProgressBar(
        controller: controller,
        style: config.progressStyle,
        totalStories: group.stories.length,
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: config.useSafeArea
          ? config.progressStyle.padding.top + config.progressStyle.height + 16
          : MediaQuery.of(context).padding.top +
                config.progressStyle.padding.top +
                config.progressStyle.height +
                16,
      left: 0,
      right: 0,
      child: headerBuilder != null
          ? headerBuilder!(context, group.user, story)
          : VStoryHeader(user: group.user, story: story, onClose: onDismiss),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Positioned(
      bottom: config.useSafeArea ? 0 : MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: footerBuilder != null
          ? footerBuilder!(context, story)
          : VStoryFooter(
              story: story,
              controller: controller,
              user: group.user,
              showReplyField: config.enableReply,
              onReplySubmitted: config.replyConfig?.onReplySend != null
                  ? (reply) async {
                      final success = await config.replyConfig!.onReplySend(
                        reply.text,
                        story,
                      );
                      if (!success) {
                        // Handle failure if needed
                      }
                    }
                  : null,
              replyPlaceholder:
                  config.replyConfig?.hintText ?? 'Send a reply...',
            ),
    );
  }
}

/// Responsive story container that adapts to screen size.
class VResponsiveStoryContainer extends StatelessWidget {
  /// The story viewer widget
  final Widget storyViewer;

  /// Maximum width for tablet/desktop
  final double maxWidth;

  /// Background color for letterboxing
  final Color backgroundColor;

  /// Whether to center the viewer
  final bool centerViewer;

  /// Creates a responsive story container
  const VResponsiveStoryContainer({
    super.key,
    required this.storyViewer,
    this.maxWidth = 500,
    this.backgroundColor = Colors.black,
    this.centerViewer = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // For mobile, use full width
        if (width <= maxWidth) {
          return storyViewer;
        }

        // For tablet/desktop, constrain width
        Widget constrained = SizedBox(
          width: maxWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: storyViewer,
          ),
        );

        // Center if configured
        if (centerViewer) {
          constrained = Center(child: constrained);
        }

        return Container(color: backgroundColor, child: constrained);
      },
    );
  }
}

/// Animated story container with transitions.
class VAnimatedStoryContainer extends StatefulWidget {
  /// The story to display
  final VBaseStory story;

  /// The story controller
  final VStoryController controller;

  /// Animation duration
  final Duration animationDuration;

  /// Animation curve
  final Curve animationCurve;

  /// Child widget
  final Widget child;

  /// Creates an animated story container
  const VAnimatedStoryContainer({
    super.key,
    required this.story,
    required this.controller,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    required this.child,
  });

  @override
  State<VAnimatedStoryContainer> createState() =>
      _VAnimatedStoryContainerState();
}

class _VAnimatedStoryContainerState extends State<VAnimatedStoryContainer>
    with SingleTickerProviderStateMixin {
  /// Animation controller
  late AnimationController _animationController;

  /// Fade animation
  late Animation<double> _fadeAnimation;

  /// Scale animation
  late Animation<double> _scaleAnimation;

  /// Current story ID
  String? _currentStoryId;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );

    _currentStoryId = widget.story.id;
    _animationController.forward();
  }

  @override
  void didUpdateWidget(VAnimatedStoryContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate on story change
    if (widget.story.id != _currentStoryId) {
      _currentStoryId = widget.story.id;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
