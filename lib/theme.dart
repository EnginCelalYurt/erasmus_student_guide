import 'package:flutter/material.dart';

/// Modern Erasmus Student Guide theme: crisp slate surfaces with Erasmus blue
/// and teal accents, designed for WCAG AA contrast in both light and dark modes.
class AppTheme {
  static const erasmusBlue = Color(0xFF2563EB);
  static const erasmusTeal = Color(0xFF0D9488);
  static const lightBg = Color(0xFFF8FAFC);
  static const darkBg = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const ink = Color(0xFF0F172A);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: erasmusBlue,
      primary: erasmusBlue,
      onPrimary: Colors.white,
      secondary: erasmusTeal,
      onSecondary: Colors.white,
      brightness: Brightness.light,
      surface: lightBg,
    );
    return _finish(
      ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: lightBg,
      ),
      cardColor: Colors.white,
      inputFillColor: Colors.white,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: erasmusBlue,
      primary: const Color(0xFF60A5FA),
      onPrimary: ink,
      secondary: const Color(0xFF2DD4BF),
      onSecondary: ink,
      brightness: Brightness.dark,
      surface: darkBg,
    );
    return _finish(
      ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: darkBg,
      ),
      cardColor: darkSurface,
      inputFillColor: darkSurface,
    );
  }

  static ThemeData _finish(
    ThemeData base, {
    required Color cardColor,
    required Color inputFillColor,
  }) {
    final scheme = base.colorScheme;
    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: base.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 70,
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
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
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }

  /// Pill-shaped input decoration for search bars across screens.
  static InputDecoration searchDecoration(
    BuildContext context, {
    required String hintText,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    const radius = BorderRadius.all(Radius.circular(28));
    return InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(Icons.search, size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }
}
