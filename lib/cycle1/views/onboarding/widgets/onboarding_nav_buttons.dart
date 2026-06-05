import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingNavButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool canProceed;
  final bool isLastStep;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onFinish;

  const OnboardingNavButtons({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.canProceed,
    required this.isLastStep,
    required this.isLoading,
    required this.onNext,
    required this.onPrevious,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.md,
        AppDimensions.md,
        AppDimensions.md + bottomPad,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            GestureDetector(
              onTap: onPrevious,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),

          if (currentStep > 0) const SizedBox(width: 12),

          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: isLoading ? null : (canProceed ? (isLastStep ? onFinish : onNext) : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canProceed && !isLoading ? AppColors.pink : Colors.grey.shade200,
                  disabledBackgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  elevation: canProceed && !isLoading ? 2 : 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isLastStep ? 'Commencer' : 'Continuer',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: canProceed ? Colors.white : Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
