import 'package:flutter/material.dart';

enum AppButtonVariant { filled, outline }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.filled => FilledButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
    };
  }
}
