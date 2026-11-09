import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bekalima/services/theme_controller.dart';
import 'package:bekalima/theme/app_theme.dart';
import 'package:bekalima/theme/glass_palette.dart';

void main() {
  testWidgets('glass palette interpolates during theme transition', (
    tester,
  ) async {
    GlassPalette? seen;

    await tester.pumpWidget(
      ListenableBuilder(
        listenable: ThemeController.instance,
        builder: (context, _) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeController.instance.themeMode,
            themeAnimationDuration: const Duration(milliseconds: 450),
            themeAnimationCurve: Curves.easeInOutCubic,
            home: Builder(
              builder: (context) {
                seen = glassPaletteOf(context);
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );

    expect(seen, isNotNull);
    expect(seen!.gradientStart, GlassPalette.light.gradientStart);

    ThemeController.instance.toggleDarkMode();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    final mid = seen!.gradientStart;
    expect(mid, isNot(GlassPalette.light.gradientStart));
    expect(mid, isNot(GlassPalette.dark.gradientStart));

    await tester.pumpAndSettle();
    expect(seen!.gradientStart, GlassPalette.dark.gradientStart);

    ThemeController.instance.toggleDarkMode();
  });
}
