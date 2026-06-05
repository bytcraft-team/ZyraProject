import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/calendar_model.dart';

class CalendarGridWidget extends StatelessWidget {
  final CalendarMonth calendarMonth;
  final Function(CalendarDay) onDayTap;

  const CalendarGridWidget({
    super.key,
    required this.calendarMonth,
    required this.onDayTap,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Column(
        children: [
          // ── En-têtes des jours ─────────────────────────────
          const _WeekHeader(),
          const SizedBox(height: AppDimensions.sm),
          // ── Grille des jours ───────────────────────────────
          _CalendarGrid(
            calendarMonth: calendarMonth,
            onDayTap: onDayTap,
          ),
        ],
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  static const _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _days.map((d) {
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: AppTextStyles.calendarDayHeader.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final CalendarMonth calendarMonth;
  final Function(CalendarDay) onDayTap;

  const _CalendarGrid({
    required this.calendarMonth,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final offset = calendarMonth.firstWeekdayOffset;
    final days = calendarMonth.days;
    final totalCells = offset + days.length;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayIndex = cellIndex - offset;

              if (dayIndex < 0 || dayIndex >= days.length) {
                return const Expanded(child: SizedBox());
              }

              final day = days[dayIndex];
              return Expanded(
                child: _DayCell(day: day, onTap: () => onDayTap(day)),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _DayCell extends StatelessWidget {
  final CalendarDay day;
  final VoidCallback onTap;

  const _DayCell({required this.day, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 46,
        child: Center(
          child: _buildCell(),
        ),
      ),
    );
  }

  Widget _buildCell() {
    if (day.isToday) {
      return _TodayCell(day: day);
    }
    if (day.isPredicted) {
      return _PredictedCell(day: day);
    }
    return _NormalCell(day: day);
  }
}

// ── Cellule normale (passée ou confirmée) ─────────────────────
class _NormalCell extends StatelessWidget {
  final CalendarDay day;
  const _NormalCell({required this.day});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: day.phaseSoftColor,
          ),
          child: Center(
            child: Text(
              '${day.date.day}',
              style: AppTextStyles.calendarDay.copyWith(
                color: day.phaseColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // Point indicateur données enregistrées
        if (day.hasLoggedData)
          Positioned(
            bottom: 3,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: day.phaseColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Cellule aujourd'hui ────────────────────────────────────────
class _TodayCell extends StatelessWidget {
  final CalendarDay day;
  const _TodayCell({required this.day});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: day.phaseColor,
            boxShadow: [
              BoxShadow(
                color: day.phaseColor.withAlpha(102),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${day.date.day}',
              style: AppTextStyles.calendarDay.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (day.hasLoggedData)
          Positioned(
            bottom: 2,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Cellule prédite ────────────────────────────────────────────
class _PredictedCell extends StatelessWidget {
  final CalendarDay day;
  const _PredictedCell({required this.day});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: day.phaseColor),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: Text(
              '${day.date.day}',
              style: AppTextStyles.calendarDay.copyWith(
                color: day.phaseColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const dashCount = 12;
    const dashAngle = 2 * 3.14159 / dashCount;

    for (int i = 0; i < dashCount; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle * 0.65,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}