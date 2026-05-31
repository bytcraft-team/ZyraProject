import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../viewmodels/settings_viewmodel.dart';
import '../shared_widgets.dart';

class NotificationsSectionWidget extends StatelessWidget {
  final SettingsViewModel vm;

  const NotificationsSectionWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final notifs = vm.notifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          icon: Icons.notifications_rounded,
          title: 'Notifications & Rappels',
        ),
        const SizedBox(height: AppDimensions.sm),

        _NotifCard(
          icon: '📔',
          iconColor: AppColors.pink,
          title: 'Rappel journal quotidien',
          subtitle: 'Te rappelle de remplir ton journal',
          value: notifs.dailyJournalReminder,
          onChanged: vm.toggleDailyReminder,
          trailing: notifs.dailyJournalReminder
              ? _TimeSelector(
                  time: notifs.dailyReminderTime ??
                      const TimeOfDay(hour: 21, minute: 0),
                  onChanged: vm.setDailyReminderTime,
                )
              : null,
        ),

        _NotifCard(
          icon: '🩸',
          iconColor: AppColors.phaseRules,
          title: 'Alerte règles dans 2 jours',
          subtitle: 'Préviens-toi avant l\'arrivée des règles',
          value: notifs.periodInTwoDaysAlert,
          onChanged: vm.togglePeriodAlert,
        ),

        _NotifCard(
          icon: '🌸',
          iconColor: AppColors.phaseFertile,
          title: 'Début fenêtre fertile',
          subtitle: 'Notification quand tu entres en période fertile',
          value: notifs.fertileWindowAlert,
          onChanged: vm.toggleFertileAlert,
        ),

        _NotifCard(
          icon: '🔴',
          iconColor: AppColors.phaseOvulation,
          title: 'Jour d\'ovulation prévu',
          subtitle: 'Alerte le jour estimé de l\'ovulation',
          value: notifs.ovulationAlert,
          onChanged: vm.toggleOvulationAlert,
        ),

        _NotifCard(
          icon: '✅',
          iconColor: AppColors.success,
          title: 'Fin de règles',
          subtitle: 'Confirmation de fin de la phase menstruelle',
          value: notifs.periodEndAlert,
          onChanged: vm.togglePeriodEndAlert,
        ),
      ],
    );
  }
}

class _NotifCard extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final Widget? trailing;

  const _NotifCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColors.pink,
                ),
              ),
            ],
          ),
          if (trailing != null) ...[
            const SizedBox(height: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final TimeOfDay time;
  final Function(TimeOfDay) onChanged;

  const _TimeSelector({required this.time, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.pink,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.pinkSoft,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time_rounded,
                size: 16, color: AppColors.pink),
            const SizedBox(width: 6),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:'
              '${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.pink,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit_rounded,
                size: 12, color: AppColors.pink),
          ],
        ),
      ),
    );
  }
}