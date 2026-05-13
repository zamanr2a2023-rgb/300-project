import 'package:flutter/material.dart';

/// Spacing scale for consistent padding across the app.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Standard horizontal gutter for [ResponsiveCenter] / page padding.
  static EdgeInsets pageHorizontal(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1100) return const EdgeInsets.symmetric(horizontal: 64);
    if (w >= 840) return const EdgeInsets.symmetric(horizontal: 48);
    return const EdgeInsets.symmetric(horizontal: md);
  }
}
