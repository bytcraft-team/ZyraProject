import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/cycle/core/constants/app_colors.dart';
import 'package:zyra/cycle/core/constants/app_dimensions.dart';
import 'package:zyra/cycle/viewmodels/settings_viewmodel.dart';
import 'package:zyra/main_shell.dart';

import 'widgets/step_cycle_duration_widget.dart';
import 'widgets/step_goal_widget.dart';
import 'widgets/step_last_period_widget.dart';
//import 'widgets/step_period_duration_widget.dart';
import 'widgets/step_regularity_widget.dart';
import 'widgets/onboarding_nav_buttons.dart';
import 'widgets/progress_bar_widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Widget _buildStep(SettingsViewModel vm) {
    switch (vm.currentStep) {
      case 0:
        return StepLastPeriodWidget(
          selectedDate: vm.selectedLastPeriod,
          onDateSelected: vm.selectLastPeriodDate,
        );
      case 1:
        return StepCycleDurationWidget(
          value: vm.cycleDuration,
          onChanged: vm.setCycleDuration,
        );
      case 2:
        return StepPeriodDurationWidget(
          value: vm.periodDuration,
          onChanged: vm.setPeriodDuration,
        );
      case 3:
        return StepRegularityWidget(
          selected: vm.regularity,
          onSelected: vm.setRegularity,
        );
      case 4:
        return StepGoalWidget(
          selected: vm.goal,
          onSelected: vm.setGoal,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      body: SafeArea(
        child: Consumer<SettingsViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Onboarding cycle',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                OnboardingProgressBar(
                  currentStep: vm.currentStep,
                  totalSteps: SettingsViewModel.totalSteps,
                ),
                const SizedBox(height: AppDimensions.md),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.sm,
                    ),
                    child: _buildStep(vm),
                  ),
                ),
                OnboardingNavButtons(
                  currentStep: vm.currentStep,
                  totalSteps: SettingsViewModel.totalSteps,
                  canProceed: vm.canProceed,
                  isLastStep: vm.currentStep == SettingsViewModel.totalSteps - 1,
                  isLoading: vm.state == SettingsLoadState.loading,
                  onPrevious: vm.previousStep,
                  onNext: vm.nextStep,
                  onFinish: () async {
                    final success = await vm.finishOnboarding();
                    if (success && context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainShell()),
                        (route) => false,
                      );
                      return;
                    }

                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Impossible de terminer l\'onboarding. Réessaie.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
