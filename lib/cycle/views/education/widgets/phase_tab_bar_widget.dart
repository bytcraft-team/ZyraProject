import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_model.dart';

class PhaseTabBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const PhaseTabBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const List<String> _emojis = ['🩸', '🌸', '🔴', '🌙'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: List.generate(CyclePhase.values.length, (i) {
          final phase = CyclePhase.values[i];
          final isActive = i == selectedIndex;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTabSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? phase.activeColor : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: phase.activeColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _emojis[i],
                      style: TextStyle(
                        fontSize: isActive ? 18 : 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phase.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}