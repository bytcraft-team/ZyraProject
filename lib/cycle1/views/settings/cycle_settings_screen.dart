import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../viewmodels/settings_viewmodel.dart';
// Onboarding UI moved to a dedicated view: lib/cycle/views/onboarding
import 'widgets/settings/notifications_section_widget.dart';
import 'widgets/settings/history_section_widget.dart';

class CycleSettingsScreen extends StatelessWidget {
  const CycleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        if (vm.state == SettingsLoadState.loading ||
            vm.state == SettingsLoadState.idle) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.pink),
            ),
          );
        }

        if (vm.state == SettingsLoadState.error) {
          return Center(
            child: ElevatedButton(
              onPressed: vm.init,
              child: const Text('Réessayer'),
            ),
          );
        }

        // Show settings view (onboarding moved to dedicated screen)
        return _SettingsView(vm: vm);
      },
    );
  }
}


// ─────────────────────────────────────────────────────────────
// VUE PARAMÈTRES
// ─────────────────────────────────────────────────────────────
class _SettingsView extends StatelessWidget {
  final SettingsViewModel vm;
  const _SettingsView({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.sm),

                // ── Header ────────────────────────────────────
                const _SettingsHeader(),

                const SizedBox(height: AppDimensions.lg),

                // ── Notifications ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md),
                  child: NotificationsSectionWidget(vm: vm),
                ),

                const SizedBox(height: AppDimensions.lg),

                // ── Historique ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md),
                  child: HistorySectionWidget(vm: vm),
                ),

                const SizedBox(height: AppDimensions.lg),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Header paramètres
// ─────────────────────────────────────────────────────────────
class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.pinkSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: AppColors.pink,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paramètres',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11,
                  color: AppColors.pink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Mon cycle',
                style: AppTextStyles.userName.copyWith(fontSize: 19),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

