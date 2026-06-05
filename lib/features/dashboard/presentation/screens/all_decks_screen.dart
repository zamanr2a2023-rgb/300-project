import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../content/presentation/providers/words_catalog_provider.dart';
import '../../../learning/presentation/view_models/learning_view_model.dart';
import '../providers/dashboard_tab_provider.dart';
import '../providers/selected_deck_provider.dart';
import '../widgets/deck_card.dart';

class AllDecksScreen extends ConsumerWidget {
  const AllDecksScreen({super.key});

  void _openDeck(WidgetRef ref, String deckId) {
    ref.read(selectedDeckIdProvider.notifier).state = deckId;
    ref.read(panedDashboardTabIndexProvider.notifier).state = 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningAsync = ref.watch(learningViewModelProvider);
    final catalogAsync = ref.watch(wordsCatalogProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: AppColors.ringLeaf,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your decks',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: learningAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (state) {
                  return catalogAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (catalog) {
                      final decks =
                          buildDeckCards(state.progress, catalog);
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        itemCount: decks.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (context, i) {
                          final deck = decks[i];
                          return DeckCardTile(
                            deck: deck,
                            onTap: () {
                              _openDeck(ref, deck.id);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
