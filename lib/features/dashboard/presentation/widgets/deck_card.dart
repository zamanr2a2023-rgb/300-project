import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../content/data/decks_data.dart';
import '../../../content/data/words_repository.dart';
import '../../../learning/domain/word_progress.dart';
import '../../../learning/domain/word_status.dart';

class DeckCardData {
  const DeckCardData({
    required this.id,
    required this.name,
    required this.description,
    required this.badgeText,
    required this.emoji,
    required this.count,
    required this.pct,
  });

  final String id;
  final String name;
  final String description;
  final String badgeText;
  final String emoji;
  final int count;
  final int pct;
}

List<DeckCardData> buildDeckCards(ProgressMap progress, WordsCatalog catalog) {
  return DecksData.all.map((deck) {
    final words = catalog.forDeck(deck.id);
    final learned = words
        .where((w) => progress[w.id]?.status == WordStatus.known)
        .length;
    return DeckCardData(
      id: deck.id,
      name: deck.name,
      description: deck.description,
      badgeText: deck.badgeText,
      emoji: deck.emoji,
      count: words.length,
      pct: words.isEmpty ? 0 : ((learned / words.length) * 100).round(),
    );
  }).toList();
}

class DeckCardTile extends StatelessWidget {
  const DeckCardTile({required this.deck, required this.onTap});

  final DeckCardData deck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: AppColors.ringLeaf,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(deck.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            deck.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            deck.badgeText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      deck.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppColors.mutedFg,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${deck.count} words',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.mutedFg,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: deck.pct / 100,
                        minHeight: 4,
                        backgroundColor: AppColors.muted,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${deck.pct}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
