import 'package:flutter/material.dart';

class AppColors {
  // Primaires
  static const Color pink = Color(0xFFE91E8C);
  static const Color pinkLight = Color(0xFFF48CB6);
  static const Color pinkSoft = Color(0xFFFCE4EC);
  static const Color purple = Color(0xFF7B2D8B);
  static const Color purpleLight = Color(0xFFCE93D8);
  static const Color purpleSoft = Color(0xFFF3E5F5);

  // Phases
  static const Color phaseRules = Color(0xFFE91E8C);
  static const Color phaseFertile = Color(0xFFFF8A65);
  static const Color phaseOvulation = Color(0xFF7B2D8B);
  static const Color phaseLuteal = Color(0xFF9C27B0);

  // Phases soft (transparentes)
  static const Color phaseRulesSoft = Color(0x33E91E8C);
  static const Color phaseFertileSoft = Color(0x33FF8A65);
  static const Color phaseOvulationSoft = Color(0x337B2D8B);
  static const Color phaseLutealSoft = Color(0x339C27B0);

  // Background
  static const Color background = Color(0xFFFFF0F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFCE4EC);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Utilitaires
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color notificationBadge = Color(0xFFF44336);

  // Gradients
  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Color(0xFFE91E8C), Color(0xFF7B2D8B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient avatarGradient = LinearGradient(
    colors: [Color(0xFFE91E8C), Color(0xFF7B2D8B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ringActiveGradient = LinearGradient(
    colors: [Color(0xFFE91E8C), Color(0xFF7B2D8B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}