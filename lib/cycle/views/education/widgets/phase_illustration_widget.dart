import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/education_model.dart';

class PhaseIllustrationWidget extends StatelessWidget {
  final PhaseEducationContent content;

  const PhaseIllustrationWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final phase = content.phase;
    final screenW = MediaQuery.of(context).size.width;
    final illustHeight = screenW >= 600 ? 220.0 : 180.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            phase.softColor,
            phase.activeColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        children: [
          // ── Illustration ───────────────────────────────────
          SizedBox(
            height: illustHeight,
            child: _PhaseIllustration(phase: phase),
          ),

          // ── Titre + durée ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              children: [
                Text(
                  'Phase ${phase.label}',
                  style: AppTextStyles.userName.copyWith(
                    fontSize: 22,
                    color: phase.activeColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: phase.activeColor.withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: phase.activeColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        content.durationLabel,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: phase.activeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Illustration vectorielle par phase ─────────────────────────
class _PhaseIllustration extends StatefulWidget {
  final CyclePhase phase;
  const _PhaseIllustration({required this.phase});

  @override
  State<_PhaseIllustration> createState() => _PhaseIllustrationState();
}

class _PhaseIllustrationState extends State<_PhaseIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_PhaseIllustration old) {
    super.didUpdateWidget(old);
    if (old.phase != widget.phase) {
      _ctrl.reset();
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Center(
          child: CustomPaint(
            size: const Size(160, 160),
            painter: _UterusPainter(phase: widget.phase),
          ),
        ),
      ),
    );
  }
}

// ── Dessin vectoriel de l'utérus selon la phase ────────────────
class _UterusPainter extends CustomPainter {
  final CyclePhase phase;
  const _UterusPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final color = phase.activeColor;
    final softColor = phase.softColor;

    // ── Corps de l'utérus ──────────────────────────────────
    final bodyPaint = Paint()
      ..color = softColor
      ..style = PaintingStyle.fill;

    final bodyStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Forme utérus (trapèze arrondi)
    final bodyPath = Path()
      ..moveTo(cx - 45, cy - 20)
      ..quadraticBezierTo(cx - 50, cy - 35, cx - 30, cy - 40)
      ..quadraticBezierTo(cx, cy - 45, cx + 30, cy - 40)
      ..quadraticBezierTo(cx + 50, cy - 35, cx + 45, cy - 20)
      ..quadraticBezierTo(cx + 45, cy + 15, cx + 20, cy + 25)
      ..lineTo(cx + 10, cy + 35)
      ..lineTo(cx - 10, cy + 35)
      ..lineTo(cx - 20, cy + 25)
      ..quadraticBezierTo(cx - 45, cy + 15, cx - 45, cy - 20)
      ..close();

    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(bodyPath, bodyStroke);

    // ── Trompes de Fallope ─────────────────────────────────
    final tubePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Trompe gauche
    final leftTubePath = Path()
      ..moveTo(cx - 45, cy - 25)
      ..cubicTo(
        cx - 70, cy - 30,
        cx - 75, cy - 10,
        cx - 65, cy,
      );
    canvas.drawPath(leftTubePath, tubePaint);

    // Trompe droite
    final rightTubePath = Path()
      ..moveTo(cx + 45, cy - 25)
      ..cubicTo(
        cx + 70, cy - 30,
        cx + 75, cy - 10,
        cx + 65, cy,
      );
    canvas.drawPath(rightTubePath, tubePaint);

    // ── Contenu selon la phase ─────────────────────────────
    switch (phase) {
      case CyclePhase.rules:
        _drawRulesContent(canvas, cx, cy, color);
        break;
      case CyclePhase.fertile:
        _drawFertileContent(canvas, cx, cy, color);
        break;
      case CyclePhase.ovulation:
        _drawOvulationContent(canvas, cx, cy, color);
        break;
      case CyclePhase.luteal:
        _drawLutealContent(canvas, cx, cy, color);
        break;
    }
  }

  void _drawRulesContent(Canvas c, double cx, double cy, Color color) {
    // Gouttes de sang à l'intérieur
    final dropPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final x = cx - 15 + (i * 15.0);
      final y = cy - 5 + (i.isEven ? 0 : 8);
      final dropPath = Path()
        ..moveTo(x, y - 10)
        ..quadraticBezierTo(x + 5, y, x, y + 5)
        ..quadraticBezierTo(x - 5, y, x, y - 10);
      c.drawPath(dropPath, dropPaint);
    }

    // Ovaires (cercles petits)
    final ovarPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    c.drawCircle(Offset(cx - 65, cy), 6, ovarPaint);
    c.drawCircle(Offset(cx + 65, cy), 6, ovarPaint);
  }

  void _drawFertileContent(Canvas c, double cx, double cy, Color color) {
    // Follicule en développement (cercles concentriques)
    final follPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    c.drawCircle(Offset(cx + 65, cy), 10, follPaint);
    c.drawCircle(
      Offset(cx + 65, cy),
      6,
      Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.fill,
    );
    c.drawCircle(Offset(cx - 65, cy), 5,
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.fill);

    // Endomètre épaissi (lignes horizontales internes)
    final linePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      c.drawLine(
        Offset(cx - 25, cy - 10 + (i * 10)),
        Offset(cx + 25, cy - 10 + (i * 10)),
        linePaint,
      );
    }
  }

  void _drawOvulationContent(Canvas c, double cx, double cy, Color color) {
    // Ovule libéré (grand cercle lumineux)
    final ovalePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final ovaleStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    c.drawCircle(Offset(cx + 65, cy - 5), 12, ovalePaint);
    c.drawCircle(Offset(cx + 65, cy - 5), 12, ovaleStroke);

    // Halo autour de l'ovule
    c.drawCircle(
      Offset(cx + 65, cy - 5),
      18,
      Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );

    // Flèche indiquant la libération
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    c.drawLine(
      Offset(cx + 50, cy - 5),
      Offset(cx + 47, cy - 5),
      arrowPaint,
    );
  }

  void _drawLutealContent(Canvas c, double cx, double cy, Color color) {
    // Corps jaune (cercle avec texture)
    c.drawCircle(
      Offset(cx + 65, cy),
      10,
      Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.fill,
    );
    c.drawCircle(
      Offset(cx + 65, cy),
      10,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Endomètre épaissi (remplissage interne)
    final innerPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final innerPath = Path()
      ..moveTo(cx - 35, cy - 15)
      ..quadraticBezierTo(cx, cy - 20, cx + 35, cy - 15)
      ..quadraticBezierTo(cx + 35, cy + 10, cx + 15, cy + 20)
      ..lineTo(cx - 15, cy + 20)
      ..quadraticBezierTo(cx - 35, cy + 10, cx - 35, cy - 15)
      ..close();

    c.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(_UterusPainter old) => old.phase != phase;
}