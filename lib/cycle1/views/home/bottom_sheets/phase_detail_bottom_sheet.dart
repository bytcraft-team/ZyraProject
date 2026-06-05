import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_model.dart';

class PhaseDetailBottomSheet extends StatelessWidget {
  final CyclePhase phase;

  const PhaseDetailBottomSheet({super.key, required this.phase});

  static Future<void> show(BuildContext context, CyclePhase phase) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PhaseDetailBottomSheet(phase: phase),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupération de la durée indicative selon la phase sélectionnée
    final int averageDays = _getAverageDays(phase);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppDimensions.lg,
        right: AppDimensions.lg,
        top: AppDimensions.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle de glissement (Indicateur visuel)
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          
          // En-tête : Icône + Titre dynamique
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: phase.softColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(phase.icon, color: phase.activeColor, size: 28),
              ),
              const SizedBox(width: AppDimensions.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phase ${phase.label}',
                    style: AppTextStyles.userName.copyWith(fontSize: 20),
                  ),
                  Text(
                    '$averageDays jours en moyenne',
                    style: AppTextStyles.cardSubValue,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          
          // Corps de texte descriptif détaillé
          Text(
            phase.detailedDescription,
            style: AppTextStyles.ringSubText.copyWith(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          
          // Bouton d'action de fermeture principale
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: phase.activeColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
              child: const Text(
                'Fermer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper local pour associer une durée standard indicative à chaque phase
  int _getAverageDays(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.rules:
        return 5;
      case CyclePhase.fertile:
        return 6;
      case CyclePhase.ovulation:
        return 1;
      case CyclePhase.luteal:
        return 14;
    }
  }
}