import 'package:zyra/cycle1/data/models/cycle_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../viewmodels/education_viewmodel.dart';
import '../shared_header.dart';
import 'widgets/phase_tab_bar_widget.dart';
import 'widgets/phase_illustration_widget.dart';
import 'widgets/what_happens_widget.dart';
import 'widgets/symptoms_chips_widget.dart';
import 'widgets/tips_list_widget.dart';
import 'widgets/doctor_alert_widget.dart';

class PhaseEducationScreen extends StatelessWidget {
  const PhaseEducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StickyPregnancyHeader(
      title: 'Comprendre ton cycle',
      child: Consumer<EducationViewModel>(
        builder: (context, vm, _) {
          return SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                // ── Header fixe ──────────────────────────────────
                const _EducationHeader(),

                // ── Tab Bar fixe ─────────────────────────────────
                PhaseTabBarWidget(
                  selectedIndex: vm.selectedTabIndex,
                  onTabSelected: vm.selectTab,
                ),

                const SizedBox(height: AppDimensions.sm),

                // ── Contenu scrollable ───────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _EducationContent(
                      key: ValueKey(vm.selectedTabIndex),
                      vm: vm,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────
class _EducationHeader extends StatelessWidget {
  const _EducationHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md, AppDimensions.sm,
        AppDimensions.md, 0,
      ),
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
              Icons.menu_book_rounded,
              color: AppColors.pink,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Éducation',
                style: AppTextStyles.cardLabel.copyWith(
                  fontSize: 11,
                  color: AppColors.pink,
                ),
              ),
              Text(
                'Comprendre ton cycle',
                style: AppTextStyles.userName.copyWith(fontSize: 19),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Contenu éducatif (scrollable)
// ─────────────────────────────────────────────────────────────
class _EducationContent extends StatelessWidget {
  final EducationViewModel vm;

  const _EducationContent({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final content = vm.currentContent;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.sm),

          // 1. Illustration + titre + durée
          PhaseIllustrationWidget(content: content),

          const SizedBox(height: AppDimensions.md),

          // 2. Que se passe-t-il ?
          WhatHappensWidget(content: content),

          const SizedBox(height: AppDimensions.md),

          // 3. Symptômes (chips)
          SymptomsChipsWidget(
            content: content,
            selectedIndex: vm.selectedSymptomIndex,
            onToggle: vm.toggleSymptom,
          ),

          const SizedBox(height: AppDimensions.md),

          // 4. Conseils pratiques
          TipsListWidget(content: content),

          const SizedBox(height: AppDimensions.md),

          // 5. Alerte médicale
          DoctorAlertWidget(alert: content.medicalAlert),

          const SizedBox(height: AppDimensions.md),

          // Navigation entre phases
          _PhaseNavigationButtons(vm: vm),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Boutons navigation entre phases
// ─────────────────────────────────────────────────────────────
class _PhaseNavigationButtons extends StatelessWidget {
  final EducationViewModel vm;

  const _PhaseNavigationButtons({required this.vm});

  @override
  Widget build(BuildContext context) {
    final phase = vm.currentContent.phase;
    final color = phase.activeColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Row(
        children: [
          // Précédent
          Expanded(
            child: OutlinedButton.icon(
              onPressed: vm.previousPhase,
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
              label: const Text('Précédente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          // Suivant
          Expanded(
            child: ElevatedButton.icon(
              onPressed: vm.nextPhase,
              icon: const Text('Suivante'),
              label: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}