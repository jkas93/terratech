import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terratech/app.dart';

void main() {
  group('TerraTechApp', () {
    testWidgets('should render app without errors', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: TerraTechApp()));

      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should have correct title', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: TerraTechApp()));

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, 'TerraTech');
    });

    testWidgets('should have debug banner disabled', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: TerraTechApp()));

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.debugShowCheckedModeBanner, false);
    });
  });
}
