import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/daily_log_model.dart';
import '_section_card.dart';

class SymptomsGridWidget extends StatelessWidget {
  final List<SymptomType> symptoms;
  final bool Function(SymptomType) isSelected;
  final int Function(SymptomType) getIntensity;
  final Function(SymptomType) onToggle;
  final Function(SymptomType, int) onIntensityChange;
  final bool showAll;
  final VoidCallback onToggleShowAll;

  const SymptomsGridWidget({
    super.key,
    required this.symptoms,
    required this.isSelected,
    required this.getIntensity,
    required this.onToggle,
    required this.onIntensityChange,
    required this.showAll,
    required this.onToggleShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Symptômes physiques',
      icon: Icons.monitor_heart_rounded,
      iconColor: AppColors.purple,
      child: Column(
        children: [
          // Grille des symptômes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount(context),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemCount: symptoms.length + 1, // +1 pour le bouton "Ajouter"
            itemBuilder: (context, index) {
              if (index == symptoms.length) {
                return _AddMoreButton(
                  showAll: showAll,
                  onTap: onToggleShowAll,
                );
              }
              final symptom = symptoms[index];
              final selected = isSelected(symptom);
              final intensity = getIntensity(symptom);

              return _SymptomButton(
                symptom: symptom,
                isSelected: selected,
                intensity: intensity,
                onTap: () => onToggle(symptom),
                onLongPress: () => _showIntensityPicker(
                  context, symptom, intensity,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  int _crossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 600) return 6;
    return 4;
  }

  void _showIntensityPicker(
      BuildContext context, SymptomType symptom, int current) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => _IntensityDialog(
        symptom: symptom,
        currentIntensity: current,
        onSelect: (intensity) {
          onIntensityChange(symptom, intensity);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SymptomButton extends StatelessWidget {
  final SymptomType symptom;
  final bool isSelected;
  final int intensity;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _SymptomButton({
    required this.symptom,
    required this.isSelected,
    required this.intensity,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purpleSoft : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.purple
                : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(symptom.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    symptom.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 9,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.purple
                          : AppColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Badge intensité
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: _IntensityBadge(intensity: intensity),
              ),
          ],
        ),
      ),
    );
  }
}

class _IntensityBadge extends StatelessWidget {
  final int intensity;
  const _IntensityBadge({required this.intensity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: AppColors.purple,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$intensity',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AddMoreButton extends StatelessWidget {
  final bool showAll;
  final VoidCallback onTap;

  const _AddMoreButton({required this.showAll, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.pinkSoft,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.pink.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showAll ? Icons.remove_circle_outline : Icons.add_circle_outline,
              color: AppColors.pink,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              showAll ? 'Réduire' : 'Ajouter',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.pink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntensityDialog extends StatelessWidget {
  final SymptomType symptom;
  final int currentIntensity;
  final Function(int) onSelect;

  const _IntensityDialog({
    required this.symptom,
    required this.currentIntensity,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      title: Row(
        children: [
          Text(symptom.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              symptom.label.replaceAll('\n', ' '),
              style: AppTextStyles.cardValue.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Intensité du symptôme',
              style: AppTextStyles.cardSubValue),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3].map((i) {
              final isSelected = i == currentIntensity;
              return GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.purple : AppColors.purpleSoft,
                    border: Border.all(
                      color: AppColors.purple,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _label(i),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.purple,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _label(int i) {
    switch (i) {
      case 1: return 'Légère';
      case 2: return 'Modérée';
      case 3: return 'Intense';
      default: return '$i';
    }
  }
}