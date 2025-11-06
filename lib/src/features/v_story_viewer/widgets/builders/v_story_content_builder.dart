import 'package:flutter/material.dart';

import '../../../../core/callbacks/v_reply_callbacks.dart';
import '../../../v_gesture_detector/widgets/v_gesture_callbacks.dart';
import '../../../v_gesture_detector/widgets/v_gesture_wrapper.dart';
import '../../../v_media_viewer/controllers/v_base_media_controller.dart';
import '../../../v_media_viewer/widgets/v_media_display.dart';
import '../../../v_progress_bar/controllers/v_progress_controller.dart';
import '../../../v_progress_bar/widgets/v_segmented_progress.dart';
import '../../../v_reactions/controllers/v_reaction_controller.dart';
import '../../../v_reactions/widgets/v_reaction_animation.dart';
import '../../../v_reply_system/views/v_reply_view.dart';
import '../../../v_reply_system/widgets/v_reply_overlay.dart';
import '../../../v_story_footer/models/v_engagement_data.dart';
import '../../../v_story_footer/models/v_error_recovery_state.dart';
import '../../../v_story_footer/models/v_footer_config.dart';
import '../../../v_story_footer/views/v_footer_view.dart';
import '../../../v_story_header/models/v_header_config.dart';
import '../../../v_story_header/views/v_header_view.dart';
import '../../../v_story_models/models/v_base_story.dart';
import '../../../v_story_models/models/v_story_group.dart';
import '../../../v_story_models/models/v_text_story.dart';
import '../../models/v_story_transition.dart';
import '../../models/v_story_viewer_callbacks.dart';
import '../v_story_transition_wrapper.dart';
import 'v_loading_overlay_builder.dart';

/// Builder for story content with all layers
class VStoryContentBuilder {
  const VStoryContentBuilder._();

  static Widget build({
    required VGestureCallbacks gestureCallbacks,
    required VBaseMediaController mediaController,
    required VBaseStory currentStory,
    required bool isLoading,
    required double mediaLoadingProgress,
    required VProgressController progressController,
    required VStoryGroup currentGroup,
    required VReactionController reactionController,
    required BuildContext context,
    required VStoryViewerCallbacks? callbacks,
    required FocusNode replyTextFieldFocusNode,
    required double maxContentWidth,
    required bool isPaused,
    VoidCallback? onPlayPausePressed,
    VoidCallback? onMutePressed,
    Color? loadingSpinnerColor,
    VFooterConfig? footerConfig,
    VHeaderConfig? headerConfig,
    VEngagementData? engagementData,
    VErrorRecoveryState? errorState,
    VoidCallback? onFooterRetry,
    VTransitionConfig? transitionConfig,
  }) {
    final backgroundColor = _getBackgroundColor(currentStory);
    // Build the main story content
    final storyContent = SafeArea(
      child: VGestureWrapper(
        callbacks: gestureCallbacks,
        child: ColoredBox(
          color: backgroundColor,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: VMediaDisplay(
                        controller: mediaController,
                        story: currentStory,
                        spinnerColor: loadingSpinnerColor,
                      ),
                    ),
                    Column(
                      children: [
                        _buildProgressBar(progressController, maxContentWidth),
                        _buildHeader(
                          currentGroup,
                          currentStory,
                          context,
                          mediaController,
                          maxContentWidth,
                          onPlayPausePressed,
                          onMutePressed,
                          headerConfig,
                        ),
                      ],
                    ),
                    VReactionAnimation(controller: reactionController),
                    if (isLoading)
                      VLoadingOverlayBuilder.build(mediaLoadingProgress),
                  ],
                ),
              ),
              _buildFooter(
                currentStory,
                maxContentWidth,
                footerConfig,
                engagementData,
                errorState,
                onFooterRetry,
              ),
            ],
          ),
        ),
      ),
    );

    // Build the reply view
    final replyView = _buildReplyView(
      currentStory,
      context,
      callbacks,
      replyTextFieldFocusNode,
      maxContentWidth,
    );

    // Wrap story content with transition if configured
    final transitionedContent = transitionConfig != null
        ? VStoryTransitionWrapper(
            child: storyContent,
            storyId: currentStory.id,
            transitionConfig: transitionConfig,
          )
        : storyContent;

    // Wrap with VReplyOverlay for web platform blur effect
    return VReplyOverlay(
      storyContent: transitionedContent,
      replyWidget: replyView,
      focusNode: replyTextFieldFocusNode,
    );
  }

  static Widget _buildProgressBar(
    VProgressController controller,
    double maxContentWidth,
  ) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 8, left: 8),
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: VSegmentedProgress(controller: controller),
      ),
    );
  }

  static Widget _buildHeader(
    VStoryGroup group,
    VBaseStory story,
    BuildContext context,
    VBaseMediaController mediaController,
    double maxContentWidth,
    VoidCallback? onPlayPausePressed,
    VoidCallback? onMutePressed,
    VHeaderConfig? config,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8),
      constraints: BoxConstraints(maxWidth: maxContentWidth),
      child: VHeaderView(
        user: group.user,
        createdAt: story.createdAt,
        config: config,
        onClosePressed: () => Navigator.of(context).pop(),
        mediaController: mediaController,
        currentStory: story,
        onPlayPausePressed: onPlayPausePressed,
        onMutePressed: onMutePressed,
      ),
    );
  }

  static Widget _buildReplyView(
    VBaseStory story,
    BuildContext context,
    VStoryViewerCallbacks? callbacks,
    FocusNode replyTextFieldFocusNode,
    double maxContentWidth,
  ) {
    return VReplyView(
      story: story,
      callbacks: VReplyCallbacks(
        onFocusChanged: callbacks?.replyCallbacks?.onFocusChanged,
        onReplySubmitted: callbacks?.replyCallbacks?.onReplySubmitted,
      ),
      replyTextFieldFocusNode: replyTextFieldFocusNode,
      maxContentWidth: maxContentWidth,
    );
  }

  static Color _getBackgroundColor(VBaseStory story) {
    if (story is VTextStory) {
      return story.backgroundColor;
    }
    return Colors.black;
  }

  static Widget _buildFooter(
    VBaseStory story,
    double maxContentWidth,
    VFooterConfig? config,
    VEngagementData? engagementData,
    VErrorRecoveryState? errorState,
    VoidCallback? onRetry,
  ) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxContentWidth),
      child: VFooterView(
        caption: story.caption,
        source: story.source,
        engagementData: engagementData ?? const VEngagementData(),
        errorState: errorState ?? const VErrorRecoveryState(),
        config: config,
        onRetry: onRetry,
        createdAt: story.createdAt,
      ),
    );
  }
}
