import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/daily_log_model.dart';
import '_section_card.dart';

class CervicalMucusWidget extends StatelessWidget {
  final CervicalMucusType? selected;
  final Function(CervicalMucusType) onSelect;

  const CervicalMucusWidget({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Signes cervicaux (mucus)',
      icon: Icons.opacity_rounded,
      iconColor: const Color(0xFF64B5F6),
      child: Column(
        children: [
          // Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CervicalMucusType.values.map((type) {
              final isSelected = selected == type;
              return _MucusOption(
                type: type,
                isSelected: isSelected,
                onTap: () => onSelect(type),
              );
            }).toList(),
          ),
          // Hint fertilité
          if (selected != null) ...[
            const SizedBox(height: AppDimensions.md),
            _FertilityHint(hint: selected!.fertilityHint, color: selected!.color),
          ],
        ],
      ),
    );
  }
}

class _MucusOption extends StatelessWidget {
  final CervicalMucusType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _MucusOption({
    required this.type,
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? type.color.withOpacity(0.2)
                  : Colors.grey.shade100,
              border: Border.all(
                color: isSelected ? type.color : Colors.grey.shade200,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                type.emoji,
                style: TextStyle(fontSize: isSelected ? 22 : 18),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            type.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? type.color : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FertilityHint extends StatelessWidget {
  final String hint;
  final Color color;

  const _FertilityHint({required this.hint, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.sm + 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          hint,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}