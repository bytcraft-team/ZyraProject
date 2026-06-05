import 'package:zyra/cycle1/data/models/cycle_model.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/education_model.dart';

class WhatHappensWidget extends StatelessWidget {
  final PhaseEducationContent content;

  const WhatHappensWidget({super.key, required this.content});

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
          // ── Titre de section ──────────────────────────────
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
                  Icons.science_rounded,
                  color: color,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  content.whatHappensTitle,
                  style: AppTextStyles.cardValue.copyWith(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.md),

          // ── Paragraphes ────────────────────────────────────
          ...content.whatHappensParagraphs.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < content.whatHappensParagraphs.length - 1
                    ? AppDimensions.sm
                    : 0,
              ),
              child: _ParagraphItem(
                text: entry.value,
                index: entry.key,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParagraphItem extends StatelessWidget {
  final String text;
  final int index;
  final Color color;

  const _ParagraphItem({
    required this.text,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numéro
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1, right: 8),
          decoration: BoxDecoration(
            color: color.withAlpha((0.12 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        // Texte
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.ringSubText.copyWith(
              fontSize: 13,
              height: 1.65,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}