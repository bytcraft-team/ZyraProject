import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '_section_card.dart';

class TemperatureInputWidget extends StatelessWidget {
  final double temperature;
  final bool showWarning;
  final String warningMessage;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const TemperatureInputWidget({
    super.key,
    required this.temperature,
    required this.showWarning,
    required this.warningMessage,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Température basale',
      icon: Icons.thermostat_rounded,
      iconColor: AppColors.warning,
      child: Column(
        children: [
          // Contrôles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton moins
              _TempButton(
                icon: Icons.remove_rounded,
                onTap: onDecrease,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.lg),
              // Valeur
              Column(
                children: [
                  Text(
                    '${temperature.toStringAsFixed(1)}°C',
                    style: AppTextStyles.ringDayNumber.copyWith(
                      fontSize: 42,
                      color: _tempColor(),
                    ),
                  ),
                  const Text(
                    'Température du matin',
                    style: AppTextStyles.cardSubValue,
                  ),
                ],
              ),
              const SizedBox(width: AppDimensions.lg),
              // Bouton plus
              _TempButton(
                icon: Icons.add_rounded,
                onTap: onIncrease,
                color: AppColors.pink,
              ),
            ],
          ),
          // Thermomètre visuel
          const SizedBox(height: AppDimensions.md),
          _TemperatureBar(temperature: temperature),
          // Warning
          if (showWarning) ...[
            const SizedBox(height: AppDimensions.md),
            _WarningBanner(message: warningMessage),
          ],
        ],
      ),
    );
  }

  Color _tempColor() {
    if (temperature >= 37.0) return AppColors.phaseOvulation;
    if (temperature >= 36.5) return AppColors.pink;
    return AppColors.textSecondary;
  }
}

class _TempButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _TempButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _TemperatureBar extends StatelessWidget {
  final double temperature;
  const _TemperatureBar({required this.temperature});

  @override
  Widget build(BuildContext context) {
    // Plage: 35°C -> 42°C = 7 degrés
    final progress = ((temperature - 35.0) / 7.0).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('35°', style: AppTextStyles.cardSubValue),
            Text('37°', style: AppTextStyles.cardSubValue.copyWith(
              color: AppColors.phaseOvulation,
            )),
            const Text('42°', style: AppTextStyles.cardSubValue),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(builder: (_, constraints) {
          return Stack(
            children: [
              // Track
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 8,
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.pinkLight, AppColors.phaseOvulation],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Marker ovulation 37°
              Positioned(
                left: constraints.maxWidth * ((37.0 - 35.0) / 7.0) - 1,
                child: Container(
                  width: 2,
                  height: 8,
                  color: AppColors.phaseOvulation,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String message;
  const _WarningBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm + 4),
      decoration: BoxDecoration(
        color: AppColors.purpleSoft,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.purple, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                color: AppColors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}