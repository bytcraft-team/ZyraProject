import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_model.dart';

class PhaseRingWidget extends StatefulWidget {
  final int currentDay;
  final int totalDays;
  final CyclePhase currentPhase;
  final String phaseDescription;

  const PhaseRingWidget({
    super.key,
    required this.currentDay,
    required this.totalDays,
    required this.currentPhase,
    required this.phaseDescription,
  });

  @override
  State<PhaseRingWidget> createState() => _PhaseRingWidgetState();
}

class _PhaseRingWidgetState extends State<PhaseRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentDay / widget.totalDays,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = _ringSize(context);

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _PhaseRingPainter(
              progress: _progressAnimation.value,
              activeColor: widget.currentPhase.activeColor,
              softColor: AppColors.pinkSoft,
              strokeWidth: AppDimensions.ringStrokeWidth,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'JOUR DU CYCLE',
                    style: AppTextStyles.ringLabel,
                  ),
                  Text(
                    '${widget.currentDay}',
                    style: AppTextStyles.ringDayNumber,
                  ),
                  Text(
                    widget.currentPhase.label,
                    style: AppTextStyles.ringPhaseName.copyWith(
                      color: widget.currentPhase.activeColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.phaseDescription,
                    style: AppTextStyles.ringSubText,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _ringSize(BuildContext context) {
    final screen = MediaQuery.of(context).size.width;
    if (screen >= 600) return 270;
    if (screen >= 400) return 220;
    return 200;
  }
}

class _PhaseRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color softColor;
  final double strokeWidth;

  const _PhaseRingPainter({
    required this.progress,
    required this.activeColor,
    required this.softColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Track de fond
    final trackPaint = Paint()
      ..color = softColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Arc de progression
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [activeColor.withAlpha((0.8 * 255).round()), activeColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Dot indicateur à la fin de l'arc
    if (progress > 0.02) {
      final dotAngle = startAngle + sweepAngle;
      final dotX = center.dx + radius * cos(dotAngle);
      final dotY = center.dy + radius * sin(dotAngle);

      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final dotBorderPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 + 2, dotBorderPaint);
      canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 - 1, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_PhaseRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.activeColor != activeColor;
}