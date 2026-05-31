import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/user_model.dart';

class HeaderWidget extends StatelessWidget {
  final UserModel user;
  final String greeting;
  final VoidCallback onAvatarTap;

  const HeaderWidget({
    super.key,
    required this.user,
    required this.greeting,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Salutation + Prénom
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: AppTextStyles.greeting),
              const SizedBox(height: 2),
              Text(user.firstName, style: AppTextStyles.userName),
            ],
          ),
          // Avatar avec badge
          _AvatarWithBadge(
            user: user,
            onTap: onAvatarTap,
          ),
        ],
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _AvatarWithBadge({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar Circle
          Container(
            width: AppDimensions.avatarSize,
            height: AppDimensions.avatarSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.avatarGradient,
            ),
            child: user.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.profileImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTextStyles.fontFamily,
                      ),
                    ),
                  ),
          ),
          // Badge notification
          if (user.hasUnreadNotifications)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: AppDimensions.badgeSize,
                height: AppDimensions.badgeSize,
                decoration: const BoxDecoration(
                  color: AppColors.notificationBadge,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}