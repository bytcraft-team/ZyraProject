import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Import crucial ajouté

import 'cycle/core/constants/app_colors.dart';
import 'cycle/data/repositories/cycle_repository.dart';
import 'cycle/data/repositories/daily_log_repository.dart';
import 'cycle/data/repositories/calendar_repository.dart';

import 'cycle/viewmodels/home_viewmodel.dart';
import 'cycle/viewmodels/daily_log_viewmodel.dart';
import 'cycle/viewmodels/calendar_viewmodel.dart';
import 'cycle/viewmodels/education_viewmodel.dart';

import 'cycle/data/repositories/settings_repository.dart';
import 'cycle/viewmodels/settings_viewmodel.dart';
import 'app_entry.dart';
import 'firebase_options.dart'; // Généré par FlutterFire CLI (indispensable)

Future<void> main() async {
  // 1. Liaison obligatoire avec le moteur Flutter pour les appels natifs/asynchrones
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation asynchrone de Firebase avant le lancement de l'UI
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Erreur critique lors de l'initialisation de Firebase : $e");
    // L'application continue, mais les dépôts distants s'appuieront sur leurs fallbacks locaux
  }

  // 3. Configuration de la barre d'état et du style système
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 4. Lancement global de l'application
  runApp(const CycleApp());
}

class CycleApp extends StatelessWidget {
  const CycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel(
            repository: CycleRepositoryImpl(),
          ),
        ),
        ChangeNotifierProvider<DailyLogViewModel>(
          create: (_) => DailyLogViewModel(
            repository: DailyLogRepositoryImpl(),
          ),
        ),
        ChangeNotifierProvider<CalendarViewModel>(
          create: (_) => CalendarViewModel(
            repository: CalendarRepositoryImpl(),
          ),
        ),
        ChangeNotifierProvider<EducationViewModel>(
          create: (_) => EducationViewModel(),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (_) => SettingsViewModel(
            repository: SettingsRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Cycle App',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
        ],
        locale: const Locale('fr', 'FR'),
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.pink,
            surface: AppColors.background,
          ),
        ),
        home: const AppEntry(),
      ),
    );
  }
}