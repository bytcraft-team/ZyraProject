import 'package:zyra/cycle/data/models/cycle_model.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/education_model.dart';

class TipsListWidget extends StatelessWidget {
  final PhaseEducationContent content;

  const TipsListWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final color = content.phase.activeColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre ──────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withAlpha((0.12 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: color,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Conseils pratiques',
                style: AppTextStyles.cardValue.copyWith(fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.md),

          // ── Liste des conseils ─────────────────────────────
          ...content.tips.asMap().entries.map((entry) {
            final i = entry.key;
            final tip = entry.value;
            final isLast = i == content.tips.length - 1;

            return Column(
              children: [
                _TipItem(tip: tip, color: color),
                if (!isLast)
                  Divider(
                    height: AppDimensions.md + 4,
                    color: Colors.grey.shade100,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final PracticalTip tip;
  final Color color;

  const _TipItem({required this.tip, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha((0.08 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              tip.emoji,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Catégorie
              Text(
                tip.category,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              // Conseil
              Text(
                tip.tip,
                style: AppTextStyles.ringSubText.copyWith(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}