import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_model.dart';
import '../../../viewmodels/calendar_viewmodel.dart';

class CycleAnalysisWidget extends StatelessWidget {
  final CalendarViewModel vm;

  const CycleAnalysisWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final phaseColor = vm.currentPhase.activeColor;
    final progress = vm.cycleProgress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 360;
                      final mainContent = Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _PhaseSummary(
                              phaseColor: phaseColor,
                              fertilityLabel: vm.fertilityProbabilityLabel,
                              fertilitySummary: vm.fertilityProbabilitySummary,
                              phaseLabel: vm.currentPhase.label,
                              phaseDescription: vm.currentPhase.description,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.md),
                          _ProgressRing(
                            progress: progress,
                            phaseColor: phaseColor,
                          ),
                        ],
                      );

                      return isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _PhaseSummary(
                                  phaseColor: phaseColor,
                                  fertilityLabel: vm.fertilityProbabilityLabel,
                                  fertilitySummary: vm.fertilityProbabilitySummary,
                                  phaseLabel: vm.currentPhase.label,
                                  phaseDescription: vm.currentPhase.description,
                                ),
                                const SizedBox(height: AppDimensions.md),
                                Center(
                                  child: _ProgressRing(
                                    progress: progress,
                                    phaseColor: phaseColor,
                                  ),
                                ),
                              ],
                            )
                          : mainContent;
                    },
                  ),
                  const SizedBox(height: AppDimensions.md),
                  
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            
            
          ],
        ),
      ),
    );
  }
}




class _ProgressRing extends StatelessWidget {
  final double progress;
  final Color phaseColor;

  const _ProgressRing({
    required this.progress,
    required this.phaseColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return SizedBox(
          width: 126,
          height: 126,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 126,
                height: 126,
                child: CircularProgressIndicator(
                  value: animatedValue,
                  strokeWidth: 12,
                  backgroundColor: phaseColor.withAlpha(36),
                  valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(animatedValue * 100).round()}%',
                    style: AppTextStyles.cardValue.copyWith(
                      fontSize: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cycle',
                    style: AppTextStyles.cardLabel.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PhaseSummary extends StatelessWidget {
  final Color phaseColor;
  final String fertilityLabel;
  final String fertilitySummary;
  final String phaseLabel;
  final String phaseDescription;

  const _PhaseSummary({
    required this.phaseColor,
    required this.fertilityLabel,
    required this.fertilitySummary,
    required this.phaseLabel,
    required this.phaseDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 4),
        Text(
          fertilityLabel,
          style: AppTextStyles.cardValue.copyWith(
            fontSize: 36,
            color: phaseColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          fertilitySummary,
          style: AppTextStyles.cardLabel.copyWith(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: phaseColor.withAlpha(41),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.circle, color: phaseColor, size: 16),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Text(
                '$phaseLabel • $phaseDescription',
                style: AppTextStyles.ringSubText.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}



