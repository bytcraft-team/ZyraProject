import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/day_info_model.dart';
import '../../../data/repositories/daily_log_repository.dart';
import '../../../data/models/daily_log_model.dart';
import '../../daily_log/daily_log_bottom_sheet.dart';
import '../../../viewmodels/home_viewmodel.dart';

class DayDetailBottomSheet extends StatefulWidget {
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

  @override
  State<DayDetailBottomSheet> createState() => _DayDetailBottomSheetState();
}

class _DayDetailBottomSheetState extends State<DayDetailBottomSheet> {
  DailyLogModel? _log;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  Future<void> _loadLog() async {
    setState(() { _loading = true; });
    try {
      final repo = DailyLogRepositoryImpl();
      final l = await repo.getLogForDate(widget.dayInfo.date);
      setState(() { _log = l; _loading = false; });
    } catch (e) {
      setState(() { _log = null; _loading = false; });
    }
  }

  Future<void> _onEdit() async {
    await DailyLogBottomSheet.show(context: context, date: widget.dayInfo.date, onSaved: () async {
      // After saving, try to refresh HomeViewModel and local log
      try {
        final homeVm = context.read<HomeViewModel>();
        await homeVm.loadData();
      } catch (_) {}
      await _loadLog();
    });
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
    final phase = widget.dayInfo.phase;

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
          // Handle + Edit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              TextButton(
                onPressed: _onEdit,
                child: const Text('Modifier'),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          // Date
          Text(_formatDate(widget.dayInfo.date), style: AppTextStyles.calendarTitle),
          const SizedBox(height: 4),
          Text(
            widget.dayInfo.isPredicted ? ' Données prédites' : ' Données confirmées',
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
            value: widget.dayInfo.fertilityLevel.label,
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
                  'Jour ${widget.dayInfo.dayInCycle} du cycle',
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
          // Daily log details
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (!_loading && _log == null)
            Center(child: Text('Non renseigné', style: AppTextStyles.cardSubValue)),
          if (!_loading && _log != null) ...[
            if (_log!.flowIntensity != null) _DetailRow(label: 'Flux', value: _log!.flowIntensity!.label),
            if (_log!.moods.isNotEmpty) _DetailRow(label: 'Humeur', value: _log!.moods.map((m) => m.emoji).join(' ')),
            if (_log!.symptoms.isNotEmpty) _DetailRow(label: 'Symptômes', value: _log!.symptoms.map((s) => s.type.label).join(', ')),
            if (_log!.cervicalMucus != null) _DetailRow(label: 'Glaire', value: _log!.cervicalMucus!.label),
            if (_log!.notes.isNotEmpty) _DetailRow(label: 'Notes', value: _log!.notes.join('\n')),
          ],
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.cardLabel),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.cardValue),
        ],
      ),
    );
  }
}