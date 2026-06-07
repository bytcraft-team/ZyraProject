import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/day_info_model.dart';

class DayDetailBottomSheet extends StatelessWidget {
  final DayInfoModel dayInfo;

  const DayDetailBottomSheet({super.key, required this.dayInfo});

  static Future<void> show(BuildContext context, DayInfoModel dayInfo) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DayDetailBottomSheet(dayInfo: dayInfo),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${days[date.weekday]} ${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final phase = dayInfo.phase;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppDimensions.lg,
        right: AppDimensions.lg,
        top: AppDimensions.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          // Date
          Text(_formatDate(dayInfo.date), style: AppTextStyles.calendarTitle),
          const SizedBox(height: 4),
          Text(
            dayInfo.isPredicted ? ' Données prédites' : ' Données confirmées',
            style: AppTextStyles.cardSubValue,
          ),
          const SizedBox(height: AppDimensions.lg),
          // Infos
          _InfoRow(
            icon: phase.icon,
            iconColor: phase.activeColor,
            iconBg: phase.softColor,
            title: 'Phase',
            value: phase.label,
          ),
          const SizedBox(height: AppDimensions.sm),
          _InfoRow(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.purple,
            iconBg: AppColors.purpleSoft,
            title: 'Fertilité',
            value: dayInfo.fertilityLevel.label,
          ),
          const SizedBox(height: AppDimensions.lg),
          // Jour du cycle
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: phase.softColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                Text(
                  'Jour ${dayInfo.dayInCycle} du cycle',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontWeight: FontWeight.w600,
                    color: phase.activeColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: AppDimensions.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.cardLabel),
            Text(value, style: AppTextStyles.cardValue.copyWith(fontSize: 16)),
          ],
        ),
      ],
    );
  }
}