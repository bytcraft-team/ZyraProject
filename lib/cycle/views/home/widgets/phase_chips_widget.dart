import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_model.dart';

class PhaseChipsWidget extends StatelessWidget {
  final CyclePhase activePhase;
  final Function(CyclePhase) onPhaseTap;

  const PhaseChipsWidget({
    super.key,
    required this.activePhase,
    required this.onPhaseTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.chipHeight + 8,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: 4,
        ),
        itemCount: CyclePhase.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
        itemBuilder: (context, index) {
          final phase = CyclePhase.values[index];
          final isActive = phase == activePhase;
          return _PhaseChip(
            phase: phase,
            isActive: isActive,
            onTap: () => onPhaseTap(phase),
          );
        },
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  final CyclePhase phase;
  final bool isActive;
  final VoidCallback onTap;

  const _PhaseChip({
    required this.phase,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? phase.activeColor : phase.softColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isActive
                ? phase.activeColor
                : phase.activeColor.withAlpha((0.3 * 255).round()),
            width: 1.5,
          ),
        ),
        child: Text(
          phase.label,
          style: isActive
              ? AppTextStyles.chipActive
              : AppTextStyles.chipInactive.copyWith(
                  color: phase.activeColor,
                ),
        ),
      ),
    );
  }
}