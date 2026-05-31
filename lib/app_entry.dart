import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cycle/viewmodels/settings_viewmodel.dart';
import 'cycle/views/onboarding/onboarding_screen.dart';
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
      final settingsVm = context.read<SettingsViewModel>();
      if (settingsVm.state == SettingsLoadState.idle) {
        settingsVm.init();
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (vm.state == SettingsLoadState.error) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: vm.init,
                child: const Text('Réessayer'),
              ),
            ),
          );
        }

        if (!vm.onboardingCompleted) {
          return const Scaffold(
            body: OnboardingScreen(),
          );
        }

        return const MainShell();
      },
    );
  }
}
