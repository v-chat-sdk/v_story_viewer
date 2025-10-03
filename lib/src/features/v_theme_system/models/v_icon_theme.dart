import 'package:flutter/material.dart';

/// Icon theme configuration for story viewer
@immutable
class VIconTheme {
  const VIconTheme({
    this.closeIcon = Icons.close,
    this.moreIcon = Icons.more_vert,
    this.shareIcon = Icons.share,
    this.pauseIcon = Icons.pause,
    this.playIcon = Icons.play_arrow,
    this.muteIcon = Icons.volume_off,
    this.unmuteIcon = Icons.volume_up,
    this.sendIcon = Icons.send,
    this.likeIcon = Icons.favorite,
    this.likeOutlineIcon = Icons.favorite_border,
    this.replyIcon = Icons.reply,
    this.downloadIcon = Icons.download,
    this.checkIcon = Icons.check,
    this.errorIcon = Icons.error_outline,
    this.warningIcon = Icons.warning_amber_outlined,
    this.infoIcon = Icons.info_outline,
    this.iconSize = 24.0,
    this.iconColor = Colors.white,
  });

  /// Close icon
  final IconData closeIcon;

  /// More options icon
  final IconData moreIcon;

  /// Share icon
  final IconData shareIcon;

  /// Pause icon
  final IconData pauseIcon;

  /// Play icon
  final IconData playIcon;

  /// Mute icon
  final IconData muteIcon;

  /// Unmute icon
  final IconData unmuteIcon;

  /// Send icon
  final IconData sendIcon;

  /// Like icon (filled)
  final IconData likeIcon;

  /// Like icon (outline)
  final IconData likeOutlineIcon;

  /// Reply icon
  final IconData replyIcon;

  /// Download icon
  final IconData downloadIcon;

  /// Check icon
  final IconData checkIcon;

  /// Error icon
  final IconData errorIcon;

  /// Warning icon
  final IconData warningIcon;

  /// Info icon
  final IconData infoIcon;

  /// Default icon size
  final double iconSize;

  /// Default icon color
  final Color iconColor;

  /// Create a copy with modifications
  VIconTheme copyWith({
    IconData? closeIcon,
    IconData? moreIcon,
    IconData? shareIcon,
    IconData? pauseIcon,
    IconData? playIcon,
    IconData? muteIcon,
    IconData? unmuteIcon,
    IconData? sendIcon,
    IconData? likeIcon,
    IconData? likeOutlineIcon,
    IconData? replyIcon,
    IconData? downloadIcon,
    IconData? checkIcon,
    IconData? errorIcon,
    IconData? warningIcon,
    IconData? infoIcon,
    double? iconSize,
    Color? iconColor,
  }) {
    return VIconTheme(
      closeIcon: closeIcon ?? this.closeIcon,
      moreIcon: moreIcon ?? this.moreIcon,
      shareIcon: shareIcon ?? this.shareIcon,
      pauseIcon: pauseIcon ?? this.pauseIcon,
      playIcon: playIcon ?? this.playIcon,
      muteIcon: muteIcon ?? this.muteIcon,
      unmuteIcon: unmuteIcon ?? this.unmuteIcon,
      sendIcon: sendIcon ?? this.sendIcon,
      likeIcon: likeIcon ?? this.likeIcon,
      likeOutlineIcon: likeOutlineIcon ?? this.likeOutlineIcon,
      replyIcon: replyIcon ?? this.replyIcon,
      downloadIcon: downloadIcon ?? this.downloadIcon,
      checkIcon: checkIcon ?? this.checkIcon,
      errorIcon: errorIcon ?? this.errorIcon,
      warningIcon: warningIcon ?? this.warningIcon,
      infoIcon: infoIcon ?? this.infoIcon,
      iconSize: iconSize ?? this.iconSize,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  /// Default light icon theme
  static const VIconTheme light = VIconTheme(iconColor: Colors.black87);

  /// Default dark icon theme
  static const VIconTheme dark = VIconTheme();
}
