import 'package:flutter/material.dart';

/// A loading indicator for when a reply is being sent.
class VReplyLoadingIndicator extends StatelessWidget {
  /// Creates a new instance of [VReplyLoadingIndicator].
  const VReplyLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
