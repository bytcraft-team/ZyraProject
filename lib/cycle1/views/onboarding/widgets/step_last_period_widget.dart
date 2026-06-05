import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'shared_widgets.dart';

class StepLastPeriodWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const StepLastPeriodWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<StepLastPeriodWidget> createState() => _StepLastPeriodWidgetState();
}

class _StepLastPeriodWidgetState extends State<StepLastPeriodWidget> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime.now();
  }

  static const _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDisabled(DateTime date) {
    final today = DateTime.now();
    return date.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepTitle(
          emoji: '',
          title: 'Quand ont commencé\ntes dernières règles ?',
          subtitle: 'Sélectionne la date de début '
              'de ta dernière menstruation.',
        ),

        const SizedBox(height: AppDimensions.lg),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _MonthNavigation(
                month: _displayMonth,
                onPrevious: () => setState(() {
                  _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month - 1,
                  );
                }),
                onNext: () => setState(() {
                  _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month + 1,
                  );
                }),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: _weekDays.map((d) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              _CalendarGrid(
                month: _displayMonth,
                selectedDate: widget.selectedDate,
                isDisabled: _isDisabled,
                isSameDay: _isSameDay,
                onDateSelected: widget.onDateSelected,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),

        if (widget.selectedDate != null) ...[
          const SizedBox(height: AppDimensions.md),
          _SelectedDateBanner(date: widget.selectedDate!),
        ],
      ],
    );
  }
}

class _MonthNavigation extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthNavigation({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  static const _months = [
    '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onPrevious,
            child: const Icon(Icons.chevron_left_rounded,
                color: AppColors.textSecondary),
          ),
          Text(
            '${_months[month.month]} ${month.year}',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onNext,
            child: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime? selectedDate;
  final bool Function(DateTime) isDisabled;
  final bool Function(DateTime, DateTime) isSameDay;
  final Function(DateTime) onDateSelected;

  const _CalendarGrid({
    required this.month,
    required this.selectedDate,
    required this.isDisabled,
    required this.isSameDay,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final offset = firstDay.weekday - 1;
    final daysCount = DateTime(month.year, month.month + 1, 0).day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: List.generate(
          ((offset + daysCount) / 7).ceil(),
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayIndex = cellIndex - offset;

                if (dayIndex < 0 || dayIndex >= daysCount) {
                  return const Expanded(child: SizedBox(height: 40));
                }

                final date = DateTime(month.year, month.month, dayIndex + 1);
                final isSelected =
                    selectedDate != null && isSameDay(date, selectedDate!);
                final disabled = isDisabled(date);

                return Expanded(
                  child: GestureDetector(
                    onTap: disabled ? null : () => onDateSelected(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 38,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.pink : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: disabled
                                ? Colors.grey.shade300
                                : isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedDateBanner extends StatelessWidget {
  final DateTime date;
  const _SelectedDateBanner({required this.date});

  static const _months = [
    '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.pinkSoft,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.pinkSoft),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.pink, size: 20),
          const SizedBox(width: 8),
          Text(
            'Début des règles : ${date.day} '
            '${_months[date.month]} ${date.year}',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.pink,
            ),
          ),
        ],
      ),
    );
  }
}
