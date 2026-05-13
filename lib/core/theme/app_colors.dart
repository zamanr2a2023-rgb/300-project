import 'package:flutter/material.dart';

/// Exact color palette from the original Paned web app (converted from OKLCH).
abstract final class AppColors {
  /// oklch(0.42 0.13 155) — dark forest green, main brand colour.
  static const Color primary = Color(0xFF1A6B43);

  /// oklch(0.98 0.01 92) — primary button text.
  static const Color onPrimary = Color(0xFFFAF8F2);

  /// oklch(0.55 0.13 155) — medium leaf green (borders, category labels).
  static const Color leaf = Color(0xFF2D8A55);

  /// oklch(0.58 0.21 27) — warm orange-red (streak / accent highlights).
  static const Color accent = Color(0xFFC85B1C);

  /// oklch(0.98 0.01 92) — accent button text.
  static const Color onAccent = Color(0xFFFAF8F2);

  /// oklch(0.97 0.022 92) — warm cream (highlight cards / back card tint).
  static const Color cream = Color(0xFFF5EDD0);

  /// oklch(0.985 0.012 95) — page background (warm off-white).
  static const Color background = Color(0xFFFAF8F2);

  /// oklch(0.22 0.04 155) — near-black with a green tint.
  static const Color foreground = Color(0xFF1A2E25);

  /// oklch(1 0 0) — card surface (pure white).
  static const Color card = Color(0xFFFFFFFF);

  /// oklch(0.94 0.025 92) — secondary / chip background.
  static const Color secondary = Color(0xFFEDE8D8);

  /// oklch(0.94 0.02 92) — muted background.
  static const Color muted = Color(0xFFEBE5DC);

  /// oklch(0.5 0.02 155) — muted text.
  static const Color mutedFg = Color(0xFF6B7E74);

  /// oklch(0.9 0.02 110) — subtle card border.
  static const Color border = Color(0xFFE3DDD5);

  /// oklch(0.18 0.03 155) — dark ink (phone frame).
  static const Color ink = Color(0xFF12201A);

  // ── Dark surface (used in dark mode scaffold) ──────────────────
  static const Color surfaceDark = Color(0xFF101A14);

  // ── Soft shadows ───────────────────────────────────────────────
  static List<BoxShadow> get shadowSoft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowCard => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Thin leaf-green border used on cards (replaces Tailwind `ring-leaf`).
  static Border get ringLeaf => Border.all(
        color: AppColors.leaf.withValues(alpha: 0.18),
        width: 1.5,
      );
}
