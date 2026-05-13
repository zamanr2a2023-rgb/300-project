import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../../../../core/widgets/paned_status_bar.dart';
import '../../../content/data/words_data.dart';
import '../../../content/domain/word.dart';
import '../../../learning/domain/word_progress.dart';
import '../../../learning/domain/word_status.dart';
import '../../../learning/presentation/view_models/learning_view_model.dart';
import '../providers/dashboard_tab_provider.dart';

class LearnTabScreen extends ConsumerStatefulWidget {
  const LearnTabScreen({super.key});

  @override
  ConsumerState<LearnTabScreen> createState() => _LearnTabScreenState();
}

class _LearnTabScreenState extends ConsumerState<LearnTabScreen> {
  int _idx = 0;
  bool _flipped = false;
  Offset? _drag;
  Offset? _start;

  List<Word> _buildQueue(ProgressMap progress) {
    final pending = [
      ...WordsData.all.where((w) => progress[w.welsh]?.status == WordStatus.learning),
      ...WordsData.all.where((w) =>
          !progress.containsKey(w.welsh) ||
          progress[w.welsh]!.status == WordStatus.newWord),
    ];
    return pending.isEmpty ? WordsData.all : pending;
  }

  Future<void> _handleAction(_SwipeAction action, Word word) async {
    final status =
        action == _SwipeAction.know ? WordStatus.learned : WordStatus.learning;
    await ref
        .read(learningViewModelProvider.notifier)
        .recordReview(welsh: word.welsh, status: status);
    if (mounted) {
      setState(() {
        _idx++;
        _flipped = false;
        _drag = null;
        _start = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final learningAsync = ref.watch(learningViewModelProvider);

    return learningAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('$e')),
      ),
      data: (state) {
        final queue = _buildQueue(state.progress);
        if (queue.isEmpty) return const _AllDone();

        final safeIdx = _idx % queue.length;
        final current = queue[safeIdx];
        final next = queue[(safeIdx + 1) % queue.length];
        final total = queue.length;
        final pct = total == 0 ? 0.0 : safeIdx / total;
        final wordStatus = state.progress[current.welsh]?.status ?? WordStatus.newWord;

        // Determine live gesture hint
        _SwipeAction? hint;
        if (_drag != null) {
          final dx = _drag!.dx;
          final dy = _drag!.dy;
          if (dy < -40 && dy.abs() > dx.abs()) {
            hint = _SwipeAction.know;
          } else if (dx > 40) {
            hint = _SwipeAction.sort;
          } else if (dx < -40) {
            hint = _SwipeAction.dontKnow;
          }
        }

        double opacity = 1.0;
        if (_drag != null) {
          opacity = (1 -
                  ((_drag!.dx.abs() > _drag!.dy.abs()
                          ? _drag!.dx.abs()
                          : _drag!.dy.abs()) /
                      400))
              .clamp(0.3, 1.0);
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: MeshBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PanedStatusBar(),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          border: AppColors.ringLeaf,
                        ),
                        child: Icon(Icons.close_rounded, size: 18, color: AppColors.foreground),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: AppColors.muted,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${safeIdx + 1}/$total',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        current.category.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.leaf,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Think · then flip',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          color: AppColors.mutedFg,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Stacked cards area
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Back card 2 (cream, rotated)
                      Transform.translate(
                        offset: const Offset(-20, 16),
                        child: Transform.rotate(
                          angle: -0.055,
                          child: Container(
                            width: MediaQuery.sizeOf(context).width - 72,
                            height: 340,
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(28),
                              border: AppColors.ringLeaf,
                            ),
                          ),
                        ),
                      ),
                      // Back card 1 (white, slight rotation)
                      Transform.translate(
                        offset: const Offset(14, 10),
                        child: Transform.rotate(
                          angle: 0.035,
                          child: Container(
                            width: MediaQuery.sizeOf(context).width - 68,
                            height: 340,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: AppColors.shadowSoft,
                            ),
                          ),
                        ),
                      ),
                      // Interactive front card
                      AnimatedOpacity(
                        opacity: opacity,
                        duration: const Duration(milliseconds: 80),
                        child: Transform.translate(
                          offset: _drag ?? Offset.zero,
                          child: Transform.rotate(
                            angle: (_drag?.dx ?? 0) * 0.0005,
                            child: GestureDetector(
                              onPanStart: (d) {
                                _start = d.globalPosition;
                              },
                              onPanUpdate: (d) {
                                setState(() {
                                  _drag = d.globalPosition - (_start ?? d.globalPosition);
                                });
                              },
                              onPanEnd: (_) {
                                final d = _drag ?? Offset.zero;
                                final th = 90.0;
                                if (d.dy < -th && d.dy.abs() > d.dx.abs()) {
                                  _handleAction(_SwipeAction.know, current);
                                } else if (d.dx > th) {
                                  _handleAction(_SwipeAction.sort, current);
                                } else if (d.dx < -th) {
                                  _handleAction(_SwipeAction.dontKnow, current);
                                } else {
                                  setState(() {
                                    _drag = null;
                                    _start = null;
                                  });
                                }
                              },
                              onTap: () => setState(() => _flipped = !_flipped),
                              child: _FlashCard(
                                word: current,
                                flipped: _flipped,
                                status: wordStatus,
                                hint: hint,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),
                Text(
                  'Up next: ${next.english}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.mutedFg,
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionBtn(
                        icon: Icons.arrow_back_rounded,
                        label: "Don't know",
                        tone: _BtnTone.muted,
                        onTap: () => _handleAction(_SwipeAction.dontKnow, current),
                      ),
                      _ActionBtn(
                        icon: Icons.arrow_upward_rounded,
                        label: 'Know it',
                        tone: _BtnTone.primary,
                        big: true,
                        onTap: () => _handleAction(_SwipeAction.know, current),
                      ),
                      _ActionBtn(
                        icon: Icons.arrow_forward_rounded,
                        label: 'Sort of',
                        tone: _BtnTone.accent,
                        onTap: () => _handleAction(_SwipeAction.sort, current),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),
              ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────

class _AllDone extends ConsumerWidget {
  const _AllDone();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PanedStatusBar(),
            Expanded(
              child: SafeArea(
                top: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text('🎉', style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Well done!',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ve mastered every word.\nCheck back tomorrow for review.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.mutedFg,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () {
                            ref.read(panedDashboardTabIndexProvider.notifier).state = 2;
                          },
                          child: const Text('View progress'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────

class _FlashCard extends StatelessWidget {
  const _FlashCard({
    required this.word,
    required this.flipped,
    required this.status,
    this.hint,
  });

  final Word word;
  final bool flipped;
  final WordStatus status;
  final _SwipeAction? hint;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width - 48;
    return Container(
      width: w,
      height: 360,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.shadowCard,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Status + audio row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == WordStatus.learning
                            ? AppColors.accent.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status == WordStatus.learning ? 'Review' : 'New word',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: status == WordStatus.learning
                              ? AppColors.accent
                              : AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.volume_up_rounded,
                          size: 16, color: AppColors.primary),
                    ),
                  ],
                ),
                // Card content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(word.emoji, style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      if (!flipped) ...[
                        Text(
                          'ENGLISH',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedFg,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          word.english,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: AppColors.foreground,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Do you know the Welsh word?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.mutedFg,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'WELSH',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.leaf,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          word.welsh,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '/${word.pronunciation}/',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.mutedFg,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          word.english,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.foreground.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  flipped
                      ? 'Swipe to grade yourself'
                      : 'Tap to reveal · swipe to grade',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.mutedFg,
                  ),
                ),
              ],
            ),
          ),
          // Gesture overlays
          if (hint == _SwipeAction.know)
            _Overlay(label: 'Know it', color: AppColors.primary, pos: _OverlayPos.top),
          if (hint == _SwipeAction.sort)
            _Overlay(label: 'Sort of', color: AppColors.accent, pos: _OverlayPos.right),
          if (hint == _SwipeAction.dontKnow)
            _Overlay(label: 'Practice', color: AppColors.foreground, pos: _OverlayPos.left),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────

enum _SwipeAction { know, sort, dontKnow }
enum _OverlayPos { top, left, right }
enum _BtnTone { primary, accent, muted }

class _Overlay extends StatelessWidget {
  const _Overlay({required this.label, required this.color, required this.pos});

  final String label;
  final Color color;
  final _OverlayPos pos;

  @override
  Widget build(BuildContext context) {
    Alignment align;
    double? angle;
    switch (pos) {
      case _OverlayPos.top:
        align = Alignment.topCenter;
        angle = null;
      case _OverlayPos.left:
        align = Alignment.centerLeft;
        angle = -0.2;
      case _OverlayPos.right:
        align = Alignment.centerRight;
        angle = 0.2;
    }
    return Positioned.fill(
      child: Align(
        alignment: align,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Transform.rotate(
            angle: angle ?? 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.shadowCard,
              ),
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
    this.big = false,
  });

  final IconData icon;
  final String label;
  final _BtnTone tone;
  final VoidCallback onTap;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (tone) {
      _BtnTone.primary => AppColors.primary,
      _BtnTone.accent => AppColors.accent,
      _BtnTone.muted => AppColors.card,
    };
    final fgColor = switch (tone) {
      _BtnTone.primary => Colors.white,
      _BtnTone.accent => Colors.white,
      _BtnTone.muted => AppColors.foreground,
    };
    final size = big ? 64.0 : 56.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: tone == _BtnTone.muted ? AppColors.ringLeaf : null,
              boxShadow: AppColors.shadowSoft,
            ),
            child: Icon(icon, color: fgColor, size: big ? 28 : 22),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.mutedFg,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
