import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studysphere_ai/main.dart';
import 'package:studysphere_ai/core/theme/app_theme.dart';

void main() {
  group('StudySphere AI App Tests', () {
    testWidgets('App should render correctly without throwing exceptions', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child: StudySphereApp(),
        ),
      );

      // Verify that the GoRouter initializes and builds at least the initial Scaffold/MaterialApp
      expect(find.byType(StudySphereApp), findsOneWidget);
    });

    test('AppTheme should have correct neon and deep space colors', () {
      final theme = AppTheme.darkTheme;
      
      // Verify our specific UI Overhaul colors were applied correctly
      expect(theme.scaffoldBackgroundColor, equals(const Color(0xFF0B0D17)));
      expect(theme.colorScheme.primary, equals(const Color(0xFF8A2BE2)));
      expect(theme.colorScheme.secondary, equals(const Color(0xFF00FFFF)));
      expect(theme.brightness, equals(Brightness.dark));
    });
  });
}
