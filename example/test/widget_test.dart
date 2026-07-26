import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('shows the background music demo', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('V Story Viewer Demo'), findsOneWidget);

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    tabBar.controller!.index = 4;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Background Music Lab'), findsOneWidget);
    expect(find.text('Open Music Timing Demo'), findsOneWidget);
    expect(find.text('Pause and Resume'), findsOneWidget);
  });
}
