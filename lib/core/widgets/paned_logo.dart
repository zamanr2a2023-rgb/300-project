import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Web `paned-logo.png`; falls back to a stylised cup if the asset is missing.
class PanedLogo extends StatelessWidget {
  const PanedLogo({super.key, required this.size});

  static const assetPath = 'assets/images/paned-logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _FallbackLogo(size: size),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.leaf],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.14),
        boxShadow: AppColors.shadowCard,
      ),
      child: Center(
        child: Text('☕', style: TextStyle(fontSize: size * 0.42)),
      ),
    );
  }
}
