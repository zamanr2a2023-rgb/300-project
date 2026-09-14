import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../data/profile_repository.dart';
import '../providers/profile_repository_provider.dart';
import '../providers/user_profile_provider.dart';

/// Shared Daily Goal editor used by Settings and Stats.
Future<void> showDailyGoalSheet({
  required BuildContext context,
  required WidgetRef ref,
  int? currentGoal,
}) async {
  final profileGoal =
      ref.read(userProfileProvider).valueOrNull?.dailyGoal ??
          ProfileRepository.defaultDailyGoal;
  final goal = currentGoal ?? profileGoal;

  const options = <int>[10, 15, 20, 25, 30, 40, 50];
  var selected = goal;
  if (!options.contains(selected)) {
    selected = options.reduce(
      (a, b) => (a - goal).abs() <= (b - goal).abs() ? a : b,
    );
  }

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Daily Goal',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How many word reviews do you want each day?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.mutedFg,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: options.map((option) {
                      final active = selected == option;
                      return ChoiceChip(
                        label: Text('$option'),
                        selected: active,
                        onSelected: (_) => setState(() => selected = option),
                        selectedColor: AppColors.primary,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: active
                              ? AppColors.onPrimary
                              : AppColors.foreground,
                        ),
                        backgroundColor: AppColors.secondary,
                        side: BorderSide(
                          color: active ? AppColors.primary : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final session =
                            ref.read(authSessionProvider).valueOrNull;
                        final uid = session?.id;
                        if (uid == null) {
                          Navigator.of(sheetContext).pop();
                          return;
                        }
                        await ref
                            .read(profileRepositoryProvider)
                            .updateDailyGoal(uid, selected);
                        if (!context.mounted) return;
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Daily goal set to $selected words.',
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Save goal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
