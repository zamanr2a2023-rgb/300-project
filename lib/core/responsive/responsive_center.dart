import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'breakpoints.dart';

/// Constrains content width on large screens and applies responsive horizontal padding.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    required this.child,
    this.maxWidth = 1200,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final bp = AppBreakpoint.fromWidth(MediaQuery.sizeOf(context).width);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: bp == AppBreakpoint.compact ? double.infinity : maxWidth,
        ),
        child: Padding(
          padding: AppSpacing.pageHorizontal(context),
          child: child,
        ),
      ),
    );
  }
}
