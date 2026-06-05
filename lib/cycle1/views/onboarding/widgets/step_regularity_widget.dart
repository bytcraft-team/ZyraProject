import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/settings_model.dart';
import 'shared_widgets.dart';

class StepRegularityWidget extends StatelessWidget {
  final CycleRegularity? selected;
  final ValueChanged<CycleRegularity> onSelected;

  const StepRegularityWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const options = CycleRegularity.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepTitle(
          emoji: '',
          title: 'À quel point ton cycle est-il régulier ?',
          subtitle: 'Choisis la meilleure description de ton cycle.',
        ),

        const SizedBox(height: AppDimensions.lg),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          child: Column(
            children: options.map((o) {
              final isSel = o == selected;
              return GestureDetector(
                onTap: () => onSelected(o),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.pinkSoft : Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.label,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              o.description,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSel) const Icon(Icons.check_circle, color: AppColors.pink),
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
