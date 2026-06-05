import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/day_info_model.dart';

class InfoCardsGridWidget extends StatelessWidget {
  final int daysUntilPeriod;
  final String nextPeriodDate;
  final FertilityLevel fertilityLevel;
  final int cycleDuration;
  final bool isRegular;
  final double? basalTemperature;
  final String? temperatureDelta;

  const InfoCardsGridWidget({
    super.key,
    required this.daysUntilPeriod,
    required this.nextPeriodDate,
    required this.fertilityLevel,
    required this.cycleDuration,
    required this.isRegular,
    this.basalTemperature,
    this.temperatureDelta,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppDimensions.sm,
        crossAxisSpacing: AppDimensions.sm,
        childAspectRatio: _aspectRatio(context),
        children: [
          _InfoCard(
            icon: Icons.water_drop_rounded,
            iconBgColor: AppColors.phaseRulesSoft,
            iconColor: AppColors.phaseRules,
            label: 'PROCHAINES RÈGLES',
            value: '${daysUntilPeriod}j',
            subValue: '~$nextPeriodDate',
          ),
          _InfoCard(
            icon: Icons.favorite_rounded,
            iconBgColor: AppColors.phaseOvulationSoft,
            iconColor: AppColors.phaseOvulation,
            label: 'FERTILITÉ',
            value: fertilityLevel.label,
            subValue: "Aujourd'hui",
          ),
          _InfoCard(
            icon: Icons.calendar_month_rounded,
            iconBgColor: const Color(0xFFE8F5E9),
            iconColor: AppColors.success,
            label: 'DURÉE CYCLE',
            value: '${cycleDuration}j',
            subValue: isRegular ? 'Régulier' : 'Irrégulier',
          ),
          _InfoCard(
            icon: Icons.thermostat_rounded,
            iconBgColor: const Color(0xFFFFF8E1),
            iconColor: AppColors.warning,
            label: 'TEMPÉRATURE',
            value: basalTemperature != null
                ? '${basalTemperature!.toStringAsFixed(1)}°'
                : '—',
            subValue: temperatureDelta ?? 'Non saisie',
          ),
        ],
      ),
    );
  }

  double _aspectRatio(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 600) return 1.4;
    return 1.1;
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;
  final String subValue;

  const _InfoCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          // Label
          Text(label, style: AppTextStyles.cardLabel),
          const SizedBox(height: 2),
          // Value
          Text(value, style: AppTextStyles.cardValue),
          const SizedBox(height: 2),
          // Sub value
          Text(subValue, style: AppTextStyles.cardSubValue),
        ],
      ),
    );
  }
}