import 'package:zyra/cycle/data/models/cycle_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/settings_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'widgets/header_widget.dart';
import 'widgets/phase_ring_widget.dart';
import 'widgets/phase_chips_widget.dart';
import 'widgets/info_cards_grid_widget.dart';
import 'widgets/next_period_banner_widget.dart';
import 'widgets/mini_calendar_widget.dart';
import 'bottom_sheets/phase_detail_bottom_sheet.dart';
import 'bottom_sheets/day_detail_bottom_sheet.dart';

class CycleHomeScreen extends StatelessWidget {
  const CycleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeViewModel, SettingsViewModel>(
      builder: (context, vm, settingsVm, _) {
        // ✅ Pas de Scaffold ici — le Scaffold est dans MainShell
        switch (vm.state) {
          case ViewState.idle:
          case ViewState.loading:
            return const _HomeLoading();
          case ViewState.error:
            return _HomeError(
              message: vm.errorMessage ?? 'Erreur',
              onRetry: vm.loadData,
            );
          case ViewState.success:
            if (vm.user == null || vm.cycle == null) {
              return const _HomeLoading();
            }
            return _HomeBody(vm: vm, settings: settingsVm.settings ?? const CycleSettings());
        }
      },
    );
  }
}



// ── Loading ────────────────────────────────────────────────────
class _HomeLoading extends StatelessWidget {
  const _HomeLoading();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(AppColors.pink),
      ),
    );
  }
}

// ── Error ──────────────────────────────────────────────────────
class _HomeError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _HomeError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 56),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pink,
            ),
            child: const Text('Réessayer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  final HomeViewModel vm;
  final CycleSettings settings;

  const _HomeBody({required this.vm, required this.settings});

  @override
  Widget build(BuildContext context) {
    final user  = vm.user!;
    final cycle = vm.cycle!;

    return SafeArea(
      bottom: false, // bottomNav gère l'espace bas
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.sm),
                HeaderWidget(
                  user: user,
                  greeting: vm.greeting,
                  onAvatarTap: () {},
                ),
                const SizedBox(height: AppDimensions.lg),
                PhaseRingWidget(
                  currentDay: cycle.currentDay,
                  totalDays: cycle.cycleDuration,
                  currentPhase: cycle.currentPhase,
                  phaseDescription: cycle.currentPhase.description,
                ),
                const SizedBox(height: AppDimensions.lg),
                PhaseChipsWidget(
                  activePhase: cycle.currentPhase,
                  onPhaseTap: (p) => PhaseDetailBottomSheet.show(context, p),
                ),
                const SizedBox(height: AppDimensions.lg),
                InfoCardsGridWidget(
                  daysUntilPeriod: cycle.daysUntilNextPeriod,
                  nextPeriodDate: vm.nextPeriodDateFormatted,
                  fertilityLevel: vm.todayFertility,
                  cycleDuration: cycle.cycleDuration,
                  isRegular: cycle.isRegular,
                  basalTemperature: vm.todayTemperature,
                  temperatureDelta: vm.temperatureDeltaFormatted,
                ),
                const SizedBox(height: AppDimensions.lg),
                const SizedBox(height: AppDimensions.lg),
                NextPeriodBannerWidget(
                  nextPeriodDate: vm.nextPeriodDateFormatted,
                  daysUntilPeriod: cycle.daysUntilNextPeriod,
                  expectedDuration: cycle.expectedPeriodDuration,
                  cycleProgress: vm.cycleProgress,
                ),
                const SizedBox(height: AppDimensions.lg),
                // Dans MiniCalendarWidget :
MiniCalendarWidget(
  monthLabel: vm.selectedMonthLabel,
  days: vm.monthDays,
  today: DateTime.now(),
  onDayTap: (d) => DayDetailBottomSheet.show(context, d),
  onPreviousMonth: vm.previousMonth,
  onNextMonth: vm.nextMonth,
),
                const SizedBox(height: 100), // espace pour bottomNav
              ],
            ),
          ),
        ],
      ),
    );
  }
}