import 'package:flutter/material.dart';
import '../models/v_story_models.dart';
import '../controllers/v_story_controller.dart';
import '../utils/v_story_viewer_config.dart';
import 'v_story_progress_bar.dart';
import 'v_story_content_container.dart';
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
                onTap: () => controller.nextStory(),
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
      top: 0,
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
      top: config.progressStyle.padding.top + config.progressStyle.height + 16,

      left: 0,
      right: 0,
      child: headerBuilder != null
          ? headerBuilder!(context, group.user, story)
          : VStoryHeader(user: group.user, story: story, onClose: onDismiss),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Positioned(
      bottom: 0,
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
