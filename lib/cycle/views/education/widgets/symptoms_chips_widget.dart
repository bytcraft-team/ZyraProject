import 'package:zyra/cycle/data/models/cycle_model.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/education_model.dart';

class SymptomsChipsWidget extends StatelessWidget {
  final PhaseEducationContent content;
  final int? selectedIndex;
  final Function(int) onToggle;

  const SymptomsChipsWidget({
    super.key,
    required this.content,
    required this.selectedIndex,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = content.phase.activeColor;
    final softColor = content.phase.softColor;
    final symptoms = content.symptoms;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre ──────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.healing_rounded,
                  color: color,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Symptômes courants',
                style: AppTextStyles.cardValue.copyWith(fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.md),

          // ── Chips ──────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symptoms.asMap().entries.map((entry) {
              final i = entry.key;
              final symptom = entry.value;
              final isSelected = selectedIndex == i;

              return GestureDetector(
                onTap: () => onToggle(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : softColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(symptom.emoji,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text(
                        symptom.label,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // ── Explication du symptôme sélectionné ───────────
          if (selectedIndex != null &&
              selectedIndex! < symptoms.length) ...[
            const SizedBox(height: AppDimensions.md),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _SymptomExplanation(
                symptom: symptoms[selectedIndex!],
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SymptomExplanation extends StatelessWidget {
  final EducationSymptom symptom;
  final Color color;

  const _SymptomExplanation({
    required this.symptom,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(symptom.emoji,
              style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  symptom.explanation,
                  style: AppTextStyles.ringSubText.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}