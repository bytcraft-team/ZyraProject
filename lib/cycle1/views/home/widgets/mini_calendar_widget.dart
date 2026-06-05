import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/day_info_model.dart';
import '../../../data/models/cycle_model.dart';

class MiniCalendarWidget extends StatelessWidget {
  final String monthLabel;
  final List<DayInfoModel> days;
  final DateTime today;
  final Function(DayInfoModel) onDayTap;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MiniCalendarWidget({
    super.key,
    required this.monthLabel,
    required this.days,
    required this.today,
    required this.onDayTap,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  static const List<String> _weekDays = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header du calendrier
          _CalendarHeader(
            monthLabel: monthLabel,
            onPrevious: onPreviousMonth,
            onNext: onNextMonth,
          ),
          const SizedBox(height: AppDimensions.md),
          // Jours de la semaine
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays
                .map((d) => SizedBox(
                      width: AppDimensions.calendarDaySize,
                      child: Center(
                        child: Text(d, style: AppTextStyles.calendarDayHeader),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppDimensions.sm),
          // Grille des jours
          _CalendarGrid(
            days: days,
            today: today,
            onDayTap: onDayTap,
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final String monthLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _CalendarHeader({
    required this.monthLabel,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(monthLabel, style: AppTextStyles.calendarTitle),
        Row(
          children: [
            _NavButton(icon: Icons.chevron_left, onTap: onPrevious),
            const SizedBox(width: AppDimensions.xs),
            _NavButton(icon: Icons.chevron_right, onTap: onNext),
          ],
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final List<DayInfoModel> days;
  final DateTime today;
  final Function(DayInfoModel) onDayTap;

  const _CalendarGrid({
    required this.days,
    required this.today,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    // Premier jour du mois (offset pour lundi = 0)
    final firstDay = days.first.date;
    final startWeekday = firstDay.weekday - 1; // lundi=0 ... dim=6

    final totalCells = startWeekday + days.length;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayIndex = cellIndex - startWeekday;

              if (dayIndex < 0 || dayIndex >= days.length) {
                return const SizedBox(width: AppDimensions.calendarDaySize);
              }

              final dayInfo = days[dayIndex];
              final isToday = _isSameDay(dayInfo.date, today);

              return _DayCell(
                dayInfo: dayInfo,
                isToday: isToday,
                onTap: () => onDayTap(dayInfo),
              );
            }),
          ),
        );
      }),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCell extends StatelessWidget {
  final DayInfoModel dayInfo;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell({
    required this.dayInfo,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final phase = dayInfo.phase;
    final isPredicted = dayInfo.isPredicted;
    final color = phase.activeColor;
    final softColor = phase.softColor;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppDimensions.calendarDaySize,
        height: AppDimensions.calendarDaySize,
        child: isPredicted
            ? _PredictedDayCell(
                day: dayInfo.date.day,
                color: color,
                isToday: isToday,
              )
            : _ConfirmedDayCell(
                day: dayInfo.date.day,
                color: color,
                softColor: softColor,
                isToday: isToday,
              ),
      ),
    );
  }
}

class _ConfirmedDayCell extends StatelessWidget {
  final int day;
  final Color color;
  final Color softColor;
  final bool isToday;

  const _ConfirmedDayCell({
    required this.day,
    required this.color,
    required this.softColor,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isToday ? color : softColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: color, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: AppTextStyles.calendarDay.copyWith(
            color: isToday ? Colors.white : color,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PredictedDayCell extends StatelessWidget {
  final int day;
  final Color color;
  final bool isToday;

  const _PredictedDayCell({
    required this.day,
    required this.color,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color.withAlpha((0.5 * 255).round())),
      child: Center(
        child: Text(
          '$day',
          style: AppTextStyles.calendarDay.copyWith(
            color: color.withAlpha((0.5 * 255).round()),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    const dashCount = 12;
    const dashAngle = 2 * 3.14159 / dashCount;

    for (int i = 0; i < dashCount; i += 2) {
      final startAngle = i * dashAngle;
      final endAngle = startAngle + dashAngle * 0.7;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}