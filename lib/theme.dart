import 'package:flutter/material.dart';

/// Brick + paper, closer to Łódź factory streets than the Erasmus logo.
class AppTheme {
  static const brick = Color(0xFF8F2D2D);
  static const moss = Color(0xFF3D5A4C);
  static const paper = Color(0xFFF3EEE4);
  static const ink = Color(0xFF1C1614);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: brick,
      primary: brick,
      secondary: moss,
      brightness: Brightness.light,
      surface: paper,
    );
    return _finish(
      ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: paper,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: brick,
      primary: const Color(0xFFD57A76),
      secondary: const Color(0xFF8FB39A),
      brightness: Brightness.dark,
    );
    return _finish(ThemeData(useMaterial3: true, colorScheme: scheme));
  }

  static ThemeData _finish(ThemeData base) {
    final scheme = base.colorScheme;
    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: base.scaffoldBackgroundColor,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 68,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final on = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
