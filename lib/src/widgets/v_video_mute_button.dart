import 'package:flutter/material.dart';
import '../models/v_story_models.dart';
import '../controllers/v_story_controller.dart';

/// Mute button widget for video stories
class VVideoMuteButton extends StatefulWidget {
  final VStoryController controller;
  final VVideoStory videoStory;
  
  const VVideoMuteButton({
    super.key,
    required this.controller,
    required this.videoStory,
  });
  
  @override
  State<VVideoMuteButton> createState() => _VVideoMuteButtonState();
}

class _VVideoMuteButtonState extends State<VVideoMuteButton> {
  bool _isMuted = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize mute state from video story
    _isMuted = widget.videoStory.muted;
  }
  
  void _toggleMute() {
    final videoController = widget.controller.getVideoController(widget.videoStory.id);
    if (videoController != null) {
      setState(() {
        _isMuted = !_isMuted;
        videoController.setVolume(_isMuted ? 0.0 : 1.0);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleMute,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isMuted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}