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
import '../../../v_story_header/views/v_header_view.dart';
import '../../../v_story_models/models/v_base_story.dart';
import '../../../v_story_models/models/v_story_group.dart';
import '../../models/v_story_viewer_callbacks.dart';
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
    VoidCallback? onPlayPausePressed,
    VoidCallback? onMutePressed,
  }) {
    // Build the main story content
    final storyContent = VGestureWrapper(
      callbacks: gestureCallbacks,
      child: Stack(
        children: [
          VMediaDisplay(controller: mediaController, story: currentStory),
          _buildProgressBar(progressController),
          _buildHeader(
            currentGroup,
            currentStory,
            context,
            mediaController,
            onPlayPausePressed,
            onMutePressed,
          ),
          VReactionAnimation(controller: reactionController),
          if (isLoading)
            VLoadingOverlayBuilder.build(mediaLoadingProgress),
        ],
      ),
    );

    // Build the reply view
    final replyView = _buildReplyView(
      currentStory,
      context,
      callbacks,
      replyTextFieldFocusNode,
    );

    // Wrap with VReplyOverlay for web platform blur effect
    return VReplyOverlay(
      storyContent: storyContent,
      replyWidget: replyView,
      focusNode: replyTextFieldFocusNode,
    );
  }

  static Widget _buildProgressBar(VProgressController controller) {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: VSegmentedProgress(controller: controller),
    );
  }

  static Widget _buildHeader(
    VStoryGroup group,
    VBaseStory story,
    BuildContext context,
    VBaseMediaController mediaController,
    VoidCallback? onPlayPausePressed,
    VoidCallback? onMutePressed,
  ) {
    return Positioned(
      top: 24,
      left: 8,
      right: 8,
      child: VHeaderView(
        user: group.user,
        createdAt: story.createdAt,
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
    FocusNode  replyTextFieldFocusNode,
  ) {
    return VReplyView(
      story: story,
      callbacks: VReplyCallbacks(
        onFocusChanged: callbacks?.replyCallbacks?.onFocusChanged,
        onReplySubmitted: callbacks?.replyCallbacks?.onReplySubmitted,
      ),
      replyTextFieldFocusNode: replyTextFieldFocusNode,
    );
  }
}
