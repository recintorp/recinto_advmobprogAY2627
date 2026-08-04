// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recinto_advmobprog/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RecintoAdvMobProg());

    // Verify that our app builds and shows the HomeScreen with the settings icon.
    expect(find.byIcon(Icons.settings), findsOneWidget);
    
    // Verify that the old counter elements are completely gone.
    expect(find.text('0'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}