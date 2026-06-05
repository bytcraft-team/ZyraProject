import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/education_model.dart';

class DoctorAlertWidget extends StatefulWidget {
  final MedicalAlert alert;

  const DoctorAlertWidget({super.key, required this.alert});

  @override
  State<DoctorAlertWidget> createState() => _DoctorAlertWidgetState();
}

class _DoctorAlertWidgetState extends State<DoctorAlertWidget> {
  bool _expanded = false;

  static const _alertColor = Color(0xFFFF8C00);
  static const _alertBg    = Color(0xFFFFF3E0);
  static const _alertBorder = Color(0xFFFFCC80);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: _alertBg,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: _alertBorder, width: 1.5),
      ),
      child: Column(
        children: [
          // ── Header cliquable ──────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Row(
                children: [
                  // Icône
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _alertColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: _alertColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  // Titre
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.alert.title,
                          style: AppTextStyles.cardValue.copyWith(
                            fontSize: 14,
                            color: _alertColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Appuie pour voir les signaux',
                          style: AppTextStyles.cardSubValue.copyWith(
                            fontSize: 11,
                            color: _alertColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _alertColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenu expandable ─────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded
                ? _AlertContent(alert: widget.alert)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _AlertContent extends StatelessWidget {
  final MedicalAlert alert;
  const _AlertContent({required this.alert});

  static const _alertColor  = Color(0xFFFF8C00);
  static const _alertBorder = Color(0xFFFFCC80);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md, 0,
        AppDimensions.md, AppDimensions.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Séparateur
          const Divider(color: _alertBorder),
          const SizedBox(height: AppDimensions.sm),

          // Description
          Text(
            alert.description,
            style: AppTextStyles.ringSubText.copyWith(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF5D4037),
            ),
          ),

          const SizedBox(height: AppDimensions.md),

          // Signaux d'alarme
          Text(
            'Signaux d\'alarme :',
            style: AppTextStyles.cardLabel.copyWith(
              color: _alertColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          ...alert.warningSignals.map(
            (signal) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                signal,
                style: AppTextStyles.ringSubText.copyWith(
                  fontSize: 13,
                  height: 1.5,
                  color: const Color(0xFF5D4037),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.md),

          // Condition possible
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: _alertColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: _alertBorder),
            ),
            child: Text(
              alert.possibleCondition,
              style: AppTextStyles.ringSubText.copyWith(
                fontSize: 13,
                height: 1.55,
                color: const Color(0xFF5D4037),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}