import 'package:flutter/material.dart';

/// A container for the story header.
class VHeaderContainer extends StatelessWidget {
  /// Creates a new instance of [VHeaderContainer].
  const VHeaderContainer({required this.child, this.padding, super.key});

  /// The content of the header.
  final Widget child;

  /// The padding around the header.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
