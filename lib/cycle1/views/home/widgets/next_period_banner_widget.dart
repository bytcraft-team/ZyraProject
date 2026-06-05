import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class NextPeriodBannerWidget extends StatelessWidget {
  final String nextPeriodDate;
  final int daysUntilPeriod;
  final int expectedDuration;
  final double cycleProgress;

  const NextPeriodBannerWidget({
    super.key,
    required this.nextPeriodDate,
    required this.daysUntilPeriod,
    required this.expectedDuration,
    required this.cycleProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          gradient: AppColors.bannerGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prochaines règles', style: AppTextStyles.bannerLabel),
                    const SizedBox(height: 4),
                    Text(
                      '$nextPeriodDate · dans $daysUntilPeriod jours',
                      style: AppTextStyles.bannerTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Durée prévue : $expectedDuration jours',
                      style: AppTextStyles.bannerSubtitle,
                    ),
                  ],
                ),
                Text(
                  '${(cycleProgress * 100).round()}%',
                  style: AppTextStyles.bannerPercent,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            // Progress bar
            _ProgressBar(progress: cycleProgress),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatefulWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => LayoutBuilder(
        builder: (_, constraints) {
          return Stack(
            children: [
              // Track
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.3 * 255).round()),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Fill
              Container(
                height: 6,
                width: constraints.maxWidth * _anim.value,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}