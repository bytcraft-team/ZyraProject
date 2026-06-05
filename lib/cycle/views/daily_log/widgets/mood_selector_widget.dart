import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/daily_log_model.dart';
import '_section_card.dart';

class MoodSelectorWidget extends StatelessWidget {
  final List<MoodType> selectedMoods;
  final Function(MoodType) onToggle;

  const MoodSelectorWidget({
    super.key,
    required this.selectedMoods,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Humeur',
      icon: Icons.sentiment_satisfied_rounded,
      iconColor: AppColors.phaseFertile,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: MoodType.values.map((mood) {
          final isSelected = selectedMoods.contains(mood);
          return _MoodItem(
            mood: mood,
            isSelected: isSelected,
            onTap: () => onToggle(mood),
          );
        }).toList(),
      ),
    );
  }
}

class _MoodItem extends StatelessWidget {
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodItem({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.pinkSoft : Colors.grey.shade100,
              border: Border.all(
                color: isSelected ? AppColors.pink : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.pink.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                mood.emoji,
                style: TextStyle(
                  fontSize: isSelected ? 26 : 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mood.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? AppColors.pink : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}