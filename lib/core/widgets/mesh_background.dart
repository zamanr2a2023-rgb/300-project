import 'package:flutter/material.dart';

/// Full-screen gradient background matching the Figma design:
/// soft sage-green wash at the top fading through cream to a warm
/// peach/coral wash at the bottom.
class MeshBackground extends StatelessWidget {
  const MeshBackground({super.key, required this.child});

  final Widget child;

  // Sage green tint — leaf colour blended ~38 % over the cream background.
  static const Color _topGreen = Color(0xFFB8D4C2);

  // Warm peach tint — accent/coral blended ~26 % over the cream background.
  static const Color _bottomCoral = Color(0xFFF0CEBD);

  // Cream midpoint (matches AppColors.background).
  static const Color _mid = Color(0xFFFAF8F2);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_topGreen, _mid, _bottomCoral],
          stops: [0.0, 0.48, 1.0],
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}
