import 'package:flutter/material.dart';

import '../../v_theme_system/models/v_spacing_tokens.dart';
import '../models/v_engagement_data.dart';
import '../models/v_footer_config.dart';

/// Widget to display engagement indicators (views, reactions, shares, comments)
class VEngagementIndicators extends StatelessWidget {
  const VEngagementIndicators({
    required this.data,
    required this.config,
    super.key,
  });

  /// Engagement data to display
  final VEngagementData data;

  /// Footer configuration
  final VFooterConfig config;

  /// Format count for display (1000+ becomes "1K")
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: VSpacingTokens.lg,
        vertical: VSpacingTokens.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.hasReactions)
            Padding(
              padding: EdgeInsets.only(bottom: VSpacingTokens.md),
              child: _buildReactionRow(),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (data.viewCount > 0)
                _buildIndicator(
                  icon: Icons.visibility,
                  label: '${_formatCount(data.viewCount)} views',
                ),
              if (data.reactionCount > 0)
                _buildIndicator(
                  icon: Icons.favorite,
                  label: '${_formatCount(data.reactionCount)} reactions',
                ),
              if (data.shareCount > 0)
                _buildIndicator(
                  icon: Icons.share,
                  label: '${_formatCount(data.shareCount)} shares',
                ),
              if (data.commentCount > 0)
                _buildIndicator(
                  icon: Icons.chat_bubble,
                  label: '${_formatCount(data.commentCount)} comments',
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a single engagement indicator
  Widget _buildIndicator({required IconData icon, required String label}) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          SizedBox(width: VSpacingTokens.sm),
          Flexible(
            child: Text(
              label,
              style:
                  config.metadataTextStyle ??
                  const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build reaction emojis row
  Widget _buildReactionRow() {
    return Wrap(
      spacing: VSpacingTokens.sm,
      children: data.topReactions
          .map(
            (reaction) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: VSpacingTokens.sm,
                vertical: VSpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(reaction, style: const TextStyle(fontSize: 18)),
            ),
          )
          .toList(),
    );
  }
}
