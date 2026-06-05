import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/calendar_model.dart';

class StatsCardsWidget extends StatelessWidget {
  final CycleStats stats;

  const StatsCardsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.loop_rounded,
              iconColor: AppColors.phaseOvulation,
              iconBg: AppColors.purpleSoft,
              label: 'Durée\nmoyenne',
              value: stats.avgCycleLabel,
              subtitle: '${stats.cyclesAnalyzed} cycles',
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: _StatCard(
              icon: Icons.water_drop_rounded,
              iconColor: AppColors.phaseRules,
              iconBg: AppColors.phaseRulesSoft,
              label: 'Durée\nrègles',
              value: stats.avgPeriodLabel,
              subtitle: 'En moyenne',
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: _StatCard(
              icon: Icons.favorite_rounded,
              iconColor: AppColors.pink,
              iconBg: AppColors.pinkSoft,
              label: 'Jour\novulation',
              value: stats.avgOvulationLabel,
              subtitle: 'Habituel',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          // Label
          Text(
            label,
            style: AppTextStyles.cardLabel.copyWith(
              fontSize: 10,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          // Valeur principale
          Text(
            value,
            style: AppTextStyles.cardValue.copyWith(
              fontSize: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          // Sous-titre
          Text(subtitle, style: AppTextStyles.cardSubValue),
        ],
      ),
    );
  }
}