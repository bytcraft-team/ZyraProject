import 'package:flutter/material.dart';
import 'package:zyra/cycle/data/models/cycle_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/calendar_model.dart';
import '../../../data/models/day_info_model.dart';
import '../../../core/utils/date_utils.dart';

class CalendarDayDetailSheet extends StatelessWidget {
  final CalendarDay day;

  const CalendarDayDetailSheet({super.key, required this.day});

  static Future<void> show(BuildContext context, CalendarDay day) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalendarDayDetailSheet(day: day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phase = day.phase;
    final color = day.phaseColor;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppDimensions.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: AppDimensions.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ── En-tête ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg),
            child: Row(
              children: [
                // Cercle phase
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(89),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${day.date.day}',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CycleDateUtils.formatDayMonthFull(day.date),
                      style: AppTextStyles.userName.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          phase.label,
                          style: AppTextStyles.cardSubValue.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (day.isPredicted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull),
                            ),
                            child: Text(
                              'Prédit',
                              style: AppTextStyles.cardLabel.copyWith(
                                  fontSize: 9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // ── Infos ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg),
            child: Column(
              children: [
                _InfoRow(
                  label: 'Jour du cycle',
                  value: 'Jour ${day.dayInCycle}',
                  icon: Icons.loop_rounded,
                  color: color,
                ),
                const Divider(height: AppDimensions.lg),
                _InfoRow(
                  label: 'Fertilité',
                  value: day.fertilityLevel.label,
                  icon: Icons.favorite_rounded,
                  color: AppColors.pink,
                ),
                const Divider(height: AppDimensions.lg),
                if (day.basalTemperature != null) ...[
                  _InfoRow(
                    label: 'Température basale',
                    value:
                        '${day.basalTemperature!.toStringAsFixed(1)}°C',
                    icon: Icons.thermostat_rounded,
                    color: AppColors.warning,
                  ),
                  const Divider(height: AppDimensions.lg),
                ],
                _InfoRow(
                  label: 'Données enregistrées',
                  value: day.hasLoggedData ? 'Oui ✅' : 'Non',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.success,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // ── Description de la phase ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: day.phaseSoftColor,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                phase.detailedDescription,
                style: AppTextStyles.ringSubText.copyWith(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // ── Bouton fermer ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull),
                  ),
                ),
                child: const Text(
                  'Fermer',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(31),
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Text(label, style: AppTextStyles.cardLabel),
        ),
        Text(
          value,
          style: AppTextStyles.cardValue.copyWith(
            fontSize: 15,
            color: color,
          ),
        ),
      ],
    );
  }
}