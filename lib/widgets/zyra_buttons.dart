import 'package:flutter/material.dart';
import 'package:zyra/theme/zyra_colors.dart';

class ZyraPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final Widget? icon;
  final bool isLoading;
  final Gradient? gradient;

  const ZyraPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height = 56,
    this.icon,
    this.isLoading = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (icon != null) ...[const SizedBox(width: 10), icon!],
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient ?? ZyraColors.mainGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: ZyraColors.primary.withOpacity(0.24),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            padding: EdgeInsets.zero,
          ),
          child: buttonChild,
        ),
      ),
    );
  }
}

class ZyraIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  final Color backgroundColor;
  final double size;
  final double borderRadius;
  final bool enabled;

  const ZyraIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.backgroundColor = ZyraColors.lightPink,
    this.size = 42,
    this.borderRadius = 14,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: enabled ? backgroundColor : ZyraColors.divider,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

class ZyraTextLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;

  const ZyraTextLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isSecondary ? ZyraColors.primary : Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
