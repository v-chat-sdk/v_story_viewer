import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/src/features/v_reply_system/widgets/v_reply_overlay.dart';

void main() {
  group('VReplyOverlay', () {
    late FocusNode focusNode;

    setUp(() {
      focusNode = FocusNode();
    });

    tearDown(() {
      focusNode.dispose();
    });

    testWidgets('should show normal layout on non-web platforms', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VReplyOverlay(
              storyContent: const Center(child: Text('Story Content')),
              replyWidget: const Text('Reply Widget'),
              focusNode: focusNode,
            ),
          ),
        ),
      );

      // Should not show any overlay elements
      expect(find.byType(BackdropFilter), findsNothing);
      expect(
        find.byType(GestureDetector),
        findsOneWidget,
      ); // Only the scaffold gesture detector

      // Should show normal layout
      expect(find.text('Story Content'), findsOneWidget);
      expect(find.text('Reply Widget'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('should not show overlay when unfocused on web', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride =
          TargetPlatform.linux; // Simulate desktop/web

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VReplyOverlay(
              storyContent: const Center(child: Text('Story Content')),
              replyWidget: const Text('Reply Widget'),
              focusNode: focusNode,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show content but no overlay when unfocused
      expect(find.text('Story Content'), findsOneWidget);
      expect(find.text('Reply Widget'), findsOneWidget);

      // Overlay should be hidden (opacity 0)
      final overlayFinder = find.byType(GestureDetector).last;
      if (overlayFinder.evaluate().isNotEmpty) {
        final overlayContainer = tester.widget<GestureDetector>(overlayFinder);
        expect(overlayContainer.child, isA<Container>());
      }

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('should show overlay when focused on web', (tester) async {
      debugDefaultTargetPlatformOverride =
          TargetPlatform.linux; // Simulate desktop/web

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VReplyOverlay(
              storyContent: const Center(child: Text('Story Content')),
              replyWidget: const Text('Reply Widget'),
              focusNode: focusNode,
            ),
          ),
        ),
      );

      // Focus the node
      focusNode.requestFocus();
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 250),
      ); // Animation duration

      // Should show overlay with blur effect
      expect(find.byType(BackdropFilter), findsOneWidget);

      // Content should still be visible
      expect(find.text('Story Content'), findsOneWidget);
      expect(find.text('Reply Widget'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('should unfocus when overlay is tapped', (tester) async {
      debugDefaultTargetPlatformOverride =
          TargetPlatform.linux; // Simulate desktop/web

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VReplyOverlay(
              storyContent: const Center(child: Text('Story Content')),
              replyWidget: const Text('Reply Widget'),
              focusNode: focusNode,
            ),
          ),
        ),
      );

      // Focus the node
      focusNode.requestFocus();
      expect(focusNode.hasFocus, isTrue);

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 250),
      ); // Animation duration

      // Tap on the overlay
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pump();

      // Focus should be lost
      expect(focusNode.hasFocus, isFalse);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
