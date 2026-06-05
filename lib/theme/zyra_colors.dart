import 'package:flutter/material.dart';

class ZyraColors {
  static const Color primary    = Color(0xFFE91E8C);
  static const Color purple     = Color(0xFF9B59B6);
  static const Color lightPink  = Color(0xFFFFE4F3);
  static const Color background = Color(0xFFFFF0F8);
  static const Color darkText   = Color(0xFF2D1B3D);
  static const Color greyText   = Color(0xFF999999);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color divider    = Color(0xFFF5E6F5);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, primary],
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFE91E8C).withOpacity(0.07),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );
}