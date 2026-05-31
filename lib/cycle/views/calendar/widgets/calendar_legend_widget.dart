import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class CalendarLegendWidget extends StatelessWidget {
  const CalendarLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _LegendItem(
              color: AppColors.phaseRules,
              label: 'Règles',
              isDashed: false,
            ),
            SizedBox(width: AppDimensions.sm),
            _LegendItem(
              color: AppColors.phaseFertile,
              label: 'Fertile',
              isDashed: false,
            ),
            SizedBox(width: AppDimensions.sm),
            _LegendItem(
              color: AppColors.phaseOvulation,
              label: 'Ovulation',
              isDashed: false,
            ),
            SizedBox(width: AppDimensions.sm),
            _LegendItem(
              color: AppColors.phaseLuteal,
              label: 'Lutéale',
              isDashed: false,
            ),
            SizedBox(width: AppDimensions.sm),
            _LegendItem(
              color: AppColors.pinkLight,
              label: 'Prédit',
              isDashed: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDashed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicateur
        isDashed
            ? _DashedCircle(color: color)
            : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.calendarDayHeader.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DashedCircle extends StatelessWidget {
  final Color color;
  const _DashedCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _DashedCirclePainter(color: color),
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
    final radius = size.width / 2 - 1;
    const dashCount = 8;
    const dashAngle = 2 * 3.14159 / dashCount;

    for (int i = 0; i < dashCount; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle * 0.7,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}