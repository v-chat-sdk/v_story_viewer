import 'package:flutter/material.dart';

/// Test screen for v_localization feature
class LocalizationTestScreen extends StatelessWidget {
  const LocalizationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localization Test'),
      ),
      body: const Center(
        child: Text('Localization Test Screen - Coming Soon'),
      ),
    );
  }
}
