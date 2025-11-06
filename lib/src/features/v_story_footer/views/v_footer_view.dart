import 'package:flutter/material.dart';

import '../../v_theme_system/models/v_spacing_tokens.dart';
import '../models/v_engagement_data.dart';
import '../models/v_error_recovery_state.dart';
import '../models/v_footer_config.dart';
import '../widgets/v_engagement_indicators.dart';
import '../widgets/v_error_recovery_widget.dart';

/// Footer view for story with caption and engagement indicators
class VFooterView extends StatefulWidget {
  const VFooterView({
    this.caption,
    this.source,
    this.engagementData = const VEngagementData(),
    this.errorState = const VErrorRecoveryState(),
    this.config,
    this.onRetry,
    this.createdAt,
    super.key,
  });

  /// Story caption text
  final String? caption;

  /// Story source/attribution
  final String? source;

  /// Engagement metrics
  final VEngagementData engagementData;

  /// Error recovery state
  final VErrorRecoveryState errorState;

  /// Footer configuration
  final VFooterConfig? config;

  /// Callback when retry is triggered
  final VoidCallback? onRetry;

  /// Story creation date
  final DateTime? createdAt;

  @override
  State<VFooterView> createState() => _VFooterViewState();
}

class _VFooterViewState extends State<VFooterView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration:
          widget.config?.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return 'weeks ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config ?? const VFooterConfig();
    final hasCaption = widget.caption != null && widget.caption!.isNotEmpty;
    final hasContent = hasCaption || widget.engagementData.hasEngagement;

    if (!hasContent && !widget.errorState.hasError) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      reverse: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.showDivider)
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          if (widget.errorState.hasError)
            VErrorRecoveryWidget(
              errorState: widget.errorState,
              onRetry: widget.onRetry,
            ),
          if (!widget.errorState.hasError)
            ColoredBox(
              color:
                  config.backgroundColor ?? Colors.black.withValues(alpha: 0.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasCaption) ...[
                    Padding(
                      padding: EdgeInsets.all(VSpacingTokens.lg),
                      child: GestureDetector(
                        onTap: _toggleExpanded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.caption!,
                              maxLines: _isExpanded
                                  ? null
                                  : config.maxCaptionLines,
                              overflow: _isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style:
                                  config.captionTextStyle ??
                                  Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white),
                            ),
                            if (!_isExpanded && widget.caption!.length > 100)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: VSpacingTokens.sm,
                                ),
                                child: Text(
                                  'Show more',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(color: Colors.blue),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (config.showEngagementIndicators &&
                      widget.engagementData.hasEngagement)
                    VEngagementIndicators(
                      data: widget.engagementData,
                      config: config,
                    ),
                  if (widget.source != null || widget.createdAt != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        VSpacingTokens.lg,
                        hasCaption ? 0 : VSpacingTokens.lg,
                        VSpacingTokens.lg,
                        VSpacingTokens.lg,
                      ),
                      child: Row(
                        children: [
                          if (widget.source != null) ...[
                            Expanded(
                              child: Text(
                                widget.source!,
                                style:
                                    config.metadataTextStyle ??
                                    Theme.of(context).textTheme.labelSmall
                                        ?.copyWith(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (widget.createdAt != null) ...[
                            if (widget.source != null)
                              SizedBox(width: VSpacingTokens.md),
                            Text(
                              _getTimeAgo(widget.createdAt!),
                              style:
                                  config.metadataTextStyle ??
                                  Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
