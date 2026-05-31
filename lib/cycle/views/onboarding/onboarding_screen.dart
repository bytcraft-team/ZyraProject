import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/settings_viewmodel.dart';
import 'widgets/progress_bar_widget.dart';
import 'widgets/step_last_period_widget.dart';
import 'widgets/step_cycle_duration_widget.dart';
import 'widgets/step_regularity_widget.dart';
import 'widgets/step_goal_widget.dart';
import 'widgets/onboarding_nav_buttons.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              OnboardingProgressBar(
                currentStep: vm.currentStep,
                totalSteps: SettingsViewModel.totalSteps,
              ),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: SingleChildScrollView(
                    key: ValueKey(vm.currentStep),
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildStep(vm),
                  ),
                ),
              ),

              OnboardingNavButtons(
                currentStep: vm.currentStep,
                totalSteps: SettingsViewModel.totalSteps,
                canProceed: vm.canProceed,
                isLoading: vm.state == SettingsLoadState.loading,
                isLastStep: vm.currentStep ==
                    SettingsViewModel.totalSteps - 1,
                onNext: vm.nextStep,
                onPrevious: vm.previousStep,
                onFinish: () async {
                  final success = await vm.finishOnboarding();
                  if (!success) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Erreur lors de la sauvegarde. Vérifie la connexion ou regarde la console.',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
}
