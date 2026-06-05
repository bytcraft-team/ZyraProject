import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/settings_model.dart';
import 'shared_widgets.dart';

class StepGoalWidget extends StatelessWidget {
  final UserGoal? selected;
  final Function(UserGoal) onSelected;

  const StepGoalWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Adaptation responsive
    final dynamicAspectRatio = screenWidth < 360 ? 1.0 : 1.12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepTitle(
          emoji: '',
          title: 'Quel est ton objectif\nprincipal ?',
          subtitle: 'Nous personnaliserons l\'app\nselon ton objectif.',
        ),

        const SizedBox(height: AppDimensions.lg),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimensions.sm,
            crossAxisSpacing: AppDimensions.sm,
            childAspectRatio: dynamicAspectRatio,

            children: UserGoal.values.map((g) {
              final isSelected = g == selected;

              return GestureDetector(
                onTap: () => onSelected(g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.pinkSoft
                        : Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.pink
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.04 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        g.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        g.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.pink
                              : AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Flexible(
                        child: Text(
                          g.description,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}