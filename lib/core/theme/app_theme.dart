import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Paned design system — matches the original web app's Fraunces/Plus Jakarta Sans palette.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            secondary: AppColors.leaf,
            onSecondary: Colors.white,
            tertiary: AppColors.accent,
            onTertiary: AppColors.onAccent,
            surface: AppColors.surfaceDark,
            onSurface: Colors.white,
            surfaceContainerLow: const Color(0xFF1A2A1E),
            surfaceContainerHigh: const Color(0xFF243020),
            outline: AppColors.border,
            outlineVariant: AppColors.border.withValues(alpha: 0.5),
            error: const Color(0xFFE05C3A),
          )
        : ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            secondary: AppColors.leaf,
            onSecondary: Colors.white,
            tertiary: AppColors.accent,
            onTertiary: AppColors.onAccent,
            surface: AppColors.background,
            onSurface: AppColors.foreground,
            surfaceContainerLow: AppColors.secondary,
            surfaceContainerHigh: AppColors.card,
            outline: AppColors.border,
            outlineVariant: AppColors.border.withValues(alpha: 0.6),
            error: const Color(0xFFC94A1E),
          );

    // Plus Jakarta Sans for body text (equivalent to "Plus Jakarta Sans" in the original).
    final bodyFont = GoogleFonts.plusJakartaSans;
    // DM Serif Display as a serif display font close to Fraunces.
    final displayFont = GoogleFonts.dmSerifDisplay;

    final textTheme = TextTheme(
      displayLarge: displayFont(fontSize: 57, fontWeight: FontWeight.w900, color: colorScheme.onSurface, letterSpacing: -1.5),
      displayMedium: displayFont(fontSize: 45, fontWeight: FontWeight.w900, color: colorScheme.onSurface, letterSpacing: -1),
      displaySmall: displayFont(fontSize: 36, fontWeight: FontWeight.w900, color: colorScheme.onSurface, letterSpacing: -0.5),
      headlineLarge: displayFont(fontSize: 32, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
      headlineMedium: displayFont(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
      headlineSmall: displayFont(fontSize: 24, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
      titleLarge: bodyFont(fontSize: 22, fontWeight: FontWeight.w800, color: colorScheme.onSurface),
      titleMedium: bodyFont(fontSize: 16, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      titleSmall: bodyFont(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      bodyLarge: bodyFont(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
      bodyMedium: bodyFont(fontSize: 14, fontWeight: FontWeight.w400, color: colorScheme.onSurface),
      bodySmall: bodyFont(fontSize: 12, fontWeight: FontWeight.w400, color: colorScheme.onSurfaceVariant),
      labelLarge: bodyFont(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      labelMedium: bodyFont(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      labelSmall: bodyFont(fontSize: 10, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: bodyFont(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurface,
        ),
      ),
      // We use a custom bottom nav — disable default NavigationBar styling.
      navigationBarTheme: NavigationBarThemeData(
        height: 0,
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: bodyFont(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.leaf.withValues(alpha: 0.35), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: bodyFont(fontWeight: FontWeight.w600, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.leaf.withValues(alpha: 0.25), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: bodyFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedFg, letterSpacing: 0.8),
        hintStyle: bodyFont(fontSize: 14, color: AppColors.mutedFg),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.leaf.withValues(alpha: 0.18), width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
