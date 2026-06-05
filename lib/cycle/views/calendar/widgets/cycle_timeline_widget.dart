import 'package:flutter/material.dart';
import 'package:zyra/cycle/data/models/cycle_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/calendar_model.dart';

class CycleTimelineWidget extends StatefulWidget {
  final List<TimelineSegment> segments;
  final int currentDay;
  final int cycleDuration;

  const CycleTimelineWidget({
    super.key,
    required this.segments,
    required this.currentDay,
    required this.cycleDuration,
  });

  @override
  State<CycleTimelineWidget> createState() => _CycleTimelineWidgetState();
}

class _CycleTimelineWidgetState extends State<CycleTimelineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _cursorAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buildAnimation();
    _ctrl.forward();
  }

  void _buildAnimation() {
    final target = widget.cycleDuration > 0
        ? ((widget.currentDay - 1) / widget.cycleDuration).clamp(0.0, 1.0)
        : 0.0;
    _cursorAnim = Tween<double>(begin: 0.0, end: target).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(CycleTimelineWidget old) {
    super.didUpdateWidget(old);
    if (old.currentDay != widget.currentDay ||
        old.cycleDuration != widget.cycleDuration) {
      _ctrl.reset();
      _buildAnimation();
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
    // ── Responsive : adapter la hauteur selon l'écran ──────────
    final screenW = MediaQuery.of(context).size.width;
    final barHeight = screenW >= 600 ? 28.0 : 22.0;
    final fontSize  = screenW >= 600 ? 11.0 : 9.0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Titre + badge jour actuel ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cycle en cours',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              _DayBadge(
                currentDay: widget.currentDay,
                cycleDuration: widget.cycleDuration,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Barre + curseur ────────────────────────────────
          AnimatedBuilder(
            animation: _cursorAnim,
            builder: (_, __) {
              return _TimelineBarWithCursor(
                segments: widget.segments,
                cursorFraction: _cursorAnim.value,
                barHeight: barHeight,
                currentDay: widget.currentDay,
                cycleDuration: widget.cycleDuration,
              );
            },
          ),

          const SizedBox(height: 10),

          // ── Labels des phases ──────────────────────────────
          _PhaseLabelsRow(
            segments: widget.segments,
            fontSize: fontSize,
          ),

          const SizedBox(height: 8),

          // ── Numéros de jours (début / mi / fin) ───────────
          _DayNumbers(cycleDuration: widget.cycleDuration),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Badge "Jour X / Y"
// ─────────────────────────────────────────────────────────────
class _DayBadge extends StatelessWidget {
  final int currentDay;
  final int cycleDuration;

  const _DayBadge({
    required this.currentDay,
    required this.cycleDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pinkSoft,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        'Jour $currentDay / $cycleDuration',
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.pink,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Barre segmentée + curseur animé
// ─────────────────────────────────────────────────────────────
class _TimelineBarWithCursor extends StatelessWidget {
  final List<TimelineSegment> segments;
  final double cursorFraction; // 0.0 → 1.0
  final double barHeight;
  final int currentDay;
  final int cycleDuration;

  const _TimelineBarWithCursor({
    required this.segments,
    required this.cursorFraction,
    required this.barHeight,
    required this.currentDay,
    required this.cycleDuration,
  });

  @override
  Widget build(BuildContext context) {
    // Espace au-dessus pour le curseur (triangle + ligne)
    const cursorAboveHeight = 18.0;

    return LayoutBuilder(
      builder: (_, constraints) {
        final totalWidth = constraints.maxWidth;

        // Position X du curseur (centre)
        final cursorX = totalWidth * cursorFraction;

        return SizedBox(
          height: cursorAboveHeight + barHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Barre de segments ────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(barHeight / 2),
                  child: SizedBox(
                    height: barHeight,
                    child: Row(
                      children: segments.map((seg) {
                        return Flexible(
                          flex: (seg.widthFraction * 10000).round(),
                          child: Container(
                            color: seg.phase.activeColor,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── Trait de séparation entre segments ───────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: barHeight,
                  child: Row(
                    children: _buildSeparators(segments, barHeight),
                  ),
                ),
              ),

              // ── Curseur animé ────────────────────────────
              Positioned(
                left: cursorX - 8,
                top: 0,
                child: _CursorIndicator(
                  barHeight: barHeight,
                  cursorAboveHeight: cursorAboveHeight,
                  currentDay: currentDay,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSeparators(
    List<TimelineSegment> segs,
    double height,
  ) {
    final result = <Widget>[];
    for (int i = 0; i < segs.length; i++) {
      result.add(
        Flexible(
          flex: (segs[i].widthFraction * 10000).round(),
          child: i < segs.length - 1
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 1.5,
                    height: height,
                    color: Colors.white.withAlpha(128),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      );
    }
    return result;
  }
}

// ─────────────────────────────────────────────────────────────
// Curseur (triangle + ligne verticale + cercle)
// ─────────────────────────────────────────────────────────────
class _CursorIndicator extends StatelessWidget {
  final double barHeight;
  final double cursorAboveHeight;
  final int currentDay;

  const _CursorIndicator({
    required this.barHeight,
    required this.cursorAboveHeight,
    required this.currentDay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: cursorAboveHeight + barHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Triangle pointant vers le bas
          const CustomPaint(
            size: Size(14, 7),
            painter: _TrianglePainter(color: AppColors.textPrimary),
          ),
          // Ligne verticale
          Container(
            width: 2,
            height: cursorAboveHeight - 7,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // Cercle sur la barre
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: AppColors.textPrimary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(38),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Labels des phases sous la barre
// ─────────────────────────────────────────────────────────────
class _PhaseLabelsRow extends StatelessWidget {
  final List<TimelineSegment> segments;
  final double fontSize;

  const _PhaseLabelsRow({
    required this.segments,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: segments.map((seg) {
        return Flexible(
          flex: (seg.widthFraction * 10000).round(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Point coloré
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: seg.phase.activeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 3),
              // Label de la phase
              Flexible(
                child: Text(
                  seg.phase.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: seg.phase.activeColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Numéros de jours : 1 — mi — dernier
// ─────────────────────────────────────────────────────────────
class _DayNumbers extends StatelessWidget {
  final int cycleDuration;

  const _DayNumbers({required this.cycleDuration});

  @override
  Widget build(BuildContext context) {
    final mid = (cycleDuration / 2).round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _dayLabel('J.1'),
        _dayLabel('J.$mid'),
        _dayLabel('J.$cycleDuration'),
      ],
    );
  }

  Widget _dayLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Peintre du triangle (curseur)
// ─────────────────────────────────────────────────────────────
class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height) // pointe en bas
      ..lineTo(0, 0)                         // coin haut gauche
      ..lineTo(size.width, 0)               // coin haut droit
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}