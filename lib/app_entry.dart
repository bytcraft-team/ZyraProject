import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cycle1/viewmodels/settings_viewmodel.dart';
import 'cycle1/views/onboarding/onboarding_screen.dart';
import 'pregnancy1/viewmodels/pregnancy_view_model.dart';
import 'main_shell.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Initialise les paramètres globaux
      final settingsVm = context.read<SettingsViewModel>();
      if (settingsVm.state == SettingsLoadState.idle) {
        settingsVm.init();
      }

      // Recalcule les données de grossesse à l'ouverture de l'application
      // pour s'assurer que les semaines et jours sont à jour
      try {
        context.read<PregnancyViewModel>().recalculateCurrentWeek();
      } catch (e) {
        debugPrint('Erreur lors du recalcul de la grossesse au démarrage: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, child) {
        if (vm.state == SettingsLoadState.loading ||
            vm.state == SettingsLoadState.idle) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (vm.state == SettingsLoadState.error) {
          debugPrint(
            'AppEntry: settings state error, affichage du bouton Réessayer.',
          );
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: vm.init,
                child: const Text('Réessayer'),
              ),
            ),
          );
        }

        if (!vm.hasCompletedCycleQuestions) {
          return const Scaffold(body: OnboardingScreen());
        }

        return const MainShell();
      },
    );
  }
}
