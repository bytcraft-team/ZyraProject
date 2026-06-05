import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/daily_log_model.dart';
import '_section_card.dart';

class FlowIntensityWidget extends StatelessWidget {
  final FlowIntensity? selected;
  final Function(FlowIntensity) onSelect;

  const FlowIntensityWidget({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Flux menstruel',
      icon: Icons.water_drop_rounded,
      iconColor: AppColors.phaseRules,
      child: Row(
        children: FlowIntensity.values.map((intensity) {
          final isSelected = selected == intensity;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(intensity),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.pinkSoft
                      : Colors.grey.shade50,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.pink
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cercle coloré
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: intensity.color,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: intensity.color.withOpacity(0.4),
                                  blurRadius: 6,
                                )
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      intensity.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.pink
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}