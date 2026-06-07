import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cycle1/core/constants/app_colors.dart';

import 'cycle1/viewmodels/home_viewmodel.dart';
import 'cycle1/viewmodels/daily_log_viewmodel.dart';
import 'cycle1/viewmodels/calendar_viewmodel.dart';

import 'cycle1/views/home/cycle_home_screen.dart';
import 'cycle1/views/daily_log/daily_log_screen.dart';
import 'cycle1/views/calendar/fertility_calendar_screen.dart';
import 'cycle1/views/education/phase_education_screen.dart';

import 'cycle1/views/settings/cycle_settings_screen.dart';
import 'cycle1/viewmodels/settings_viewmodel.dart';

import 'widgets/bottom_nav_bar.dart';
import 'app_tab_notifier.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  // Pour ne pas recharger inutilement les tabs déjà ouverts
  final Set<int> _initializedTabs = {};

  @override
  void initState() {
    super.initState();

    _pages = const [
      CycleHomeScreen(),
      DailyLogScreen(),
      FertilityCalendarScreen(),
      PhaseEducationScreen(),
      CycleSettingsScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeTabIfNeeded(0);
    });

    // Listen to external requests to change the active tab (from pushed screens)
    appTabNotifier.addListener(_handleExternalTabChange);
  }

  void _handleExternalTabChange() {
    final v = appTabNotifier.value;
    if (v == null) return;
    if (!mounted) return;
    _initializeTabIfNeeded(v);
    setState(() {
      _selectedIndex = v;
    });
    // reset notifier
    appTabNotifier.value = null;
  }

  @override
  void dispose() {
    appTabNotifier.removeListener(_handleExternalTabChange);
    super.dispose();
  }

  void _initializeTabIfNeeded(int index) {
    if (_initializedTabs.contains(index)) return;

    switch (index) {
      case 0:
        final homeVm = context.read<HomeViewModel>();
        if (homeVm.state == ViewState.idle || homeVm.state == ViewState.error) {
          homeVm.loadData();
        }
        break;

      case 1:
        context.read<DailyLogViewModel>().init();
        break;

      case 2:
        context.read<CalendarViewModel>().init();
        break;

      case 3:
        // EducationViewModel n'a pas besoin d'init async
        break;

      case 4:
        final settingsVm = context.read<SettingsViewModel>();
        if (settingsVm.state == SettingsLoadState.idle) {
          settingsVm.init();
        }
        break;
    }

    _initializedTabs.add(index);
  }

  void _onTap(int index) {
    debugPrint('MainShell onTap -> $index | current=$_selectedIndex');

    if (index == _selectedIndex) return;

    _initializeTabIfNeeded(index);

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MainShell build -> index=$_selectedIndex');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
