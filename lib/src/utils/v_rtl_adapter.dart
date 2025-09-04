import 'package:flutter/material.dart';
import '../../v_story_viewer.dart' show VGestureZone;
import 'v_story_localizations.dart';

/// Adapts gesture zones and navigation for RTL languages.
/// 
/// This utility handles the mirroring of gesture zones and
/// navigation directions for right-to-left languages.
class VRTLAdapter {
  /// The text direction (LTR or RTL)
  final TextDirection textDirection;
  
  /// Whether RTL mode is active
  final bool isRTL;
  
  /// Creates an RTL adapter
  const VRTLAdapter({
    required this.textDirection,
  }) : isRTL = textDirection == TextDirection.rtl;
  
  /// Creates an RTL adapter from context
  factory VRTLAdapter.of(BuildContext context) {
    final localizations = VStoryLocalizations.of(context);
    return VRTLAdapter(
      textDirection: localizations.textDirection,
    );
  }
  
  /// Adapts horizontal navigation direction
  /// 
  /// In LTR: left = previous, right = next
  /// In RTL: left = next, right = previous
  VNavigationDirection adaptNavigationDirection(VNavigationDirection direction) {
    if (!isRTL) return direction;
    
    switch (direction) {
      case VNavigationDirection.previous:
        return VNavigationDirection.next;
      case VNavigationDirection.next:
        return VNavigationDirection.previous;
      default:
        return direction;
    }
  }
  
  /// Adapts gesture zone based on RTL
  /// 
  /// In LTR: left zone = previous, right zone = next
  /// In RTL: left zone = next, right zone = previous
  VGestureZone adaptGestureZone(VGestureZone zone) {
    if (!isRTL) return zone;
    
    switch (zone) {
      case VGestureZone.left:
        return VGestureZone.right;
      case VGestureZone.right:
        return VGestureZone.left;
    }
  }
  
  /// Adapts swipe direction based on RTL
  /// 
  /// In LTR: swipe left = next, swipe right = previous
  /// In RTL: swipe left = previous, swipe right = next
  VSwipeDirection adaptSwipeDirection(VSwipeDirection direction) {
    if (!isRTL) return direction;
    
    switch (direction) {
      case VSwipeDirection.left:
        return VSwipeDirection.right;
      case VSwipeDirection.right:
        return VSwipeDirection.left;
      default:
        return direction;
    }
  }
  
  /// Gets the adapted alignment for UI elements
  /// 
  /// In LTR: start = left, end = right
  /// In RTL: start = right, end = left
  Alignment getAlignment(VAlignment alignment) {
    switch (alignment) {
      case VAlignment.topStart:
        return isRTL ? Alignment.topRight : Alignment.topLeft;
      case VAlignment.topEnd:
        return isRTL ? Alignment.topLeft : Alignment.topRight;
      case VAlignment.centerStart:
        return isRTL ? Alignment.centerRight : Alignment.centerLeft;
      case VAlignment.centerEnd:
        return isRTL ? Alignment.centerLeft : Alignment.centerRight;
      case VAlignment.bottomStart:
        return isRTL ? Alignment.bottomRight : Alignment.bottomLeft;
      case VAlignment.bottomEnd:
        return isRTL ? Alignment.bottomLeft : Alignment.bottomRight;
      case VAlignment.center:
        return Alignment.center;
      case VAlignment.topCenter:
        return Alignment.topCenter;
      case VAlignment.bottomCenter:
        return Alignment.bottomCenter;
    }
  }
  
  /// Gets the adapted edge insets for padding/margin
  /// 
  /// Swaps left and right values for RTL
  EdgeInsets adaptEdgeInsets(EdgeInsets insets) {
    if (!isRTL) return insets;
    
    return EdgeInsets.fromLTRB(
      insets.right,
      insets.top,
      insets.left,
      insets.bottom,
    );
  }
  
  /// Gets the adapted edge insets directional
  /// 
  /// Automatically handles RTL based on text direction
  EdgeInsetsDirectional getDirectionalInsets({
    double start = 0.0,
    double top = 0.0,
    double end = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsetsDirectional.only(
      start: start,
      top: top,
      end: end,
      bottom: bottom,
    );
  }
  

  
  /// Gets progress bar direction
  /// 
  /// In LTR: progress fills left to right
  /// In RTL: progress fills right to left
  TextDirection getProgressDirection() {
    return textDirection;
  }
  
  /// Adapts a horizontal drag offset for RTL
  /// 
  /// In RTL, horizontal drags are inverted
  double adaptDragOffset(double offset) {
    return isRTL ? -offset : offset;
  }
  
  /// Adapts a rotation angle for RTL
  /// 
  /// Some rotations need to be inverted for RTL
  double adaptRotation(double radians) {
    return isRTL ? -radians : radians;
  }
  
  /// Gets the start position for overlays
  /// 
  /// Returns the appropriate side based on text direction
  double getOverlayStartPosition(double screenWidth, double overlayWidth) {
    return isRTL ? screenWidth - overlayWidth : 0;
  }
  
  /// Gets the end position for overlays
  /// 
  /// Returns the appropriate side based on text direction
  double getOverlayEndPosition(double screenWidth, double overlayWidth) {
    return isRTL ? 0 : screenWidth - overlayWidth;
  }
}

/// Navigation directions
enum VNavigationDirection {
  /// Navigate to previous story
  previous,
  
  /// Navigate to next story
  next,
  
  /// Navigate up (dismiss)
  up,
  
  /// Navigate down
  down,
}



/// Swipe directions
enum VSwipeDirection {
  /// Swipe left
  left,
  
  /// Swipe right
  right,
  
  /// Swipe up
  up,
  
  /// Swipe down
  down,
}

/// Alignment positions
enum VAlignment {
  /// Top start (top-left in LTR, top-right in RTL)
  topStart,
  
  /// Top center
  topCenter,
  
  /// Top end (top-right in LTR, top-left in RTL)
  topEnd,
  
  /// Center start (center-left in LTR, center-right in RTL)
  centerStart,
  
  /// Center
  center,
  
  /// Center end (center-right in LTR, center-left in RTL)
  centerEnd,
  
  /// Bottom start (bottom-left in LTR, bottom-right in RTL)
  bottomStart,
  
  /// Bottom center
  bottomCenter,
  
  /// Bottom end (bottom-right in LTR, bottom-left in RTL)
  bottomEnd,
}

/// Extension for easy RTL adaptation
extension VRTLAdapterExtension on BuildContext {
  /// Gets the RTL adapter for this context
  VRTLAdapter get rtlAdapter => VRTLAdapter.of(this);
  
  /// Adapts an alignment for the current text direction
  Alignment adaptAlignment(VAlignment alignment) {
    return rtlAdapter.getAlignment(alignment);
  }
  
  /// Adapts edge insets for the current text direction
  EdgeInsets adaptInsets(EdgeInsets insets) {
    return rtlAdapter.adaptEdgeInsets(insets);
  }
  
  /// Creates directional insets
  EdgeInsetsDirectional directionalInsets({
    double start = 0.0,
    double top = 0.0,
    double end = 0.0,
    double bottom = 0.0,
  }) {
    return rtlAdapter.getDirectionalInsets(
      start: start,
      top: top,
      end: end,
      bottom: bottom,
    );
  }
}