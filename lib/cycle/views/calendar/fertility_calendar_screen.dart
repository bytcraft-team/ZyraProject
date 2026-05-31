import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import 'widgets/calendar_header_widget.dart';
import 'widgets/calendar_legend_widget.dart';
import 'widgets/calendar_grid_widget.dart';
import 'widgets/cycle_timeline_widget.dart';
import 'widgets/cycle_analysis_widget.dart';
import 'widgets/stats_cards_widget.dart';
import 'widgets/advice_card_widget.dart';
import 'widgets/day_detail_bottom_sheet.dart';

class FertilityCalendarScreen extends StatelessWidget {
  const FertilityCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarViewModel>(
      builder: (context, vm, _) {
        // ── État idle ou loading ──────────────────────────────
        if (vm.state == CalendarLoadState.idle ||
            vm.state == CalendarLoadState.loading) {
          return const _CalendarLoading();
        }

        // ── État erreur ───────────────────────────────────────
        if (vm.state == CalendarLoadState.error) {
          return _CalendarError(
            message: vm.errorMessage ?? 'Une erreur est survenue',
            onRetry: vm.init,
          );
        }

        // ── État succès mais données manquantes ───────────────
        if (vm.calendarMonth == null) {
          return const _CalendarLoading();
        }

        // ── Succès ────────────────────────────────────────────
        return _CalendarBody(vm: vm);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Loading
// ─────────────────────────────────────────────────────────────
class _CalendarLoading extends StatelessWidget {
  const _CalendarLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.pink),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Error
// ─────────────────────────────────────────────────────────────
class _CalendarError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CalendarError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusFull,
                  ),
                ),
              ),
              child: const Text(
                'Réessayer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Body principal
// ─────────────────────────────────────────────────────────────
class _CalendarBody extends StatelessWidget {
  final CalendarViewModel vm;

  const _CalendarBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.sm),

                // ── 1. Header navigation mois ─────────────────
                CalendarHeaderWidget(
                  monthLabel: vm.monthLabel,
                  onPrevious: vm.previousMonth,
                  onNext: vm.nextMonth,
                ),

                const SizedBox(height: AppDimensions.sm),

                // ── 2. Légende des couleurs ───────────────────
                const CalendarLegendWidget(),

                const SizedBox(height: AppDimensions.md),

                // ── 3. Grille du calendrier ───────────────────
                CalendarGridWidget(
                  calendarMonth: vm.calendarMonth!,
                  onDayTap: (day) =>
                      CalendarDayDetailSheet.show(context, day),
                ),

                const SizedBox(height: AppDimensions.lg),

                // ── 4. Analyse intelligente du cycle ───────────
                if (vm.stats != null)
                  CycleAnalysisWidget(vm: vm),

                const SizedBox(height: AppDimensions.lg),

                // ── 5. Timeline du cycle ──────────────────────
                if (vm.timeline.isNotEmpty)
                  CycleTimelineWidget(
                    segments: vm.timeline,
                    currentDay: vm.currentCycleDay,
                    cycleDuration: vm.cycleDuration,
                  ),

                const SizedBox(height: AppDimensions.lg),

                // ── 6. Statistiques ───────────────────────────
                if (vm.stats != null)
                  StatsCardsWidget(stats: vm.stats!),

                const SizedBox(height: AppDimensions.lg),

                // ── 7. Conseil contextuel ─────────────────────
                AdviceCardWidget(advice: vm.currentAdvice),

                // Espace pour la bottomNav
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}