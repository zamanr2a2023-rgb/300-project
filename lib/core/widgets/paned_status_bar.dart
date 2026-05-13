import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fake iOS-style status row from the web [StatusBar] in `PhoneFrame.tsx`.
class PanedStatusBar extends StatelessWidget {
  const PanedStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.foreground.withValues(alpha: 0.8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
          Row(
            children: [
              Container(
                width: 12,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.foreground.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 12,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.foreground.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 20,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: AppColors.foreground.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(1.5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.foreground.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
