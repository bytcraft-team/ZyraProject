import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'shared_widgets.dart';

class StepCycleDurationWidget extends StatelessWidget {
  final int value;
  final Function(int) onChanged;

  const StepCycleDurationWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const int _min = 21;
  static const int _max = 35;

  @override
  Widget build(BuildContext context) {
    return _DurationStep(
      emoji: '',
      title: 'Quelle est la durée\nde ton cycle ?',
      subtitle: 'Le cycle commence le premier jour '
          'des règles et se termine la veille\n'
          'des règles suivantes.',
      value: value,
      min: _min,
      max: _max,
      unit: 'jours',
      hint: _hint(value),
      onChanged: onChanged,
    );
  }

  String _hint(int v) {
    if (v < 24) return ' Cycle court';
    if (v <= 32) return 'Durée normale';
    return ' Cycle long';
  }
}

class StepPeriodDurationWidget extends StatelessWidget {
  final int value;
  final Function(int) onChanged;

  const StepPeriodDurationWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const int _min = 2;
  static const int _max = 8;

  @override
  Widget build(BuildContext context) {
    return _DurationStep(
      emoji: '',
      title: 'Combien de jours\ndurent tes règles ?',
      subtitle: 'La durée habituelle des saignements\n'
          'depuis le premier jour.',
      value: value,
      min: _min,
      max: _max,
      unit: 'jours',
      hint: _hint(value),
      onChanged: onChanged,
    );
  }

  String _hint(int v) {
    if (v <= 3) return '💧 Règles courtes';
    if (v <= 6) return '✅ Durée normale';
    return '⚠️ Règles longues';
  }
}

class _DurationStep extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final String unit;
  final String hint;
  final Function(int) onChanged;

  const _DurationStep({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitle(
          emoji: emoji,
          title: title,
          subtitle: subtitle,
        ),
        const SizedBox(height: AppDimensions.xl),
        Center(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pink,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      ' $unit',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pinkSoft,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  hint,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pink,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.pink,
                  inactiveTrackColor: AppColors.pinkSoft,
                  thumbColor: AppColors.pink,
                  overlayColor: AppColors.pink.withAlpha((0.15 * 255).round()),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 14,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 24,
                  ),
                  trackHeight: 6,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Slider(
                    value: value.toDouble(),
                    min: min.toDouble(),
                    max: max.toDouble(),
                    divisions: max - min,
                    onChanged: (v) => onChanged(v.round()),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$min j',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      )),
                  Text('$max j',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
