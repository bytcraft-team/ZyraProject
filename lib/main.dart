import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/firebase_options.dart';
import 'package:zyra/core/global_keys.dart';
import 'package:zyra/pregnancy1/view/pregnancy_tracker_screen.dart';
//import 'package:zyra/pregnancy1/view/postpartum_page.dart';
import 'package:zyra/pregnancy1/onboarding/onboarding_screen.dart';
import 'package:zyra/auth/login_screen.dart';
import 'package:zyra/auth/signup_screen.dart';
import 'package:zyra/auth/viewmodels/authentication_view_model.dart';
import 'package:zyra/pregnancy1/repositories/user_repository.dart';
import 'package:zyra/splash/first_page.dart';
import 'package:zyra/splash/splash_screen.dart' as splash;
import 'package:zyra/app_entry.dart';
import 'package:zyra/cycle1/viewmodels/settings_viewmodel.dart';
import 'package:zyra/cycle1/data/repositories/settings_repository.dart';
import 'package:zyra/cycle1/viewmodels/home_viewmodel.dart';
import 'package:zyra/cycle1/data/repositories/cycle_repository.dart';
import 'package:zyra/cycle1/viewmodels/daily_log_viewmodel.dart';
import 'package:zyra/cycle1/data/repositories/daily_log_repository.dart';
import 'package:zyra/cycle1/viewmodels/calendar_viewmodel.dart';
import 'package:zyra/cycle1/viewmodels/education_viewmodel.dart';
import 'package:zyra/cycle1/data/repositories/calendar_repository.dart';
import 'package:zyra/pregnancy1/viewmodels/pregnancy_view_model.dart';
import 'package:zyra/pregnancy1/viewmodels/user_phase_view_model.dart';
//import 'package:zyra/models/user_phase.dart';
import 'package:zyra/paramettres/providers/appearance_provider.dart';
import 'package:zyra/paramettres/providers/cycle_provider.dart';
import 'package:zyra/paramettres/providers/user_provider.dart';
import 'package:zyra/paramettres/screens/settings/settings_screen.dart';
import 'package:zyra/l10n/app_localizations.dart';
import 'package:zyra/paramettres/viewmodel/notification_provider.dart';
import 'package:zyra/paramettres/services/local_notification_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.init();
  runApp(const LunaApp());
}

class LunaApp extends StatelessWidget {
  const LunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8EA88D),
      primary: const Color(0xFF8EA88D),
      onPrimary: Colors.white,
      secondary: const Color(0xFF7FBFC0),
      background: const Color(0xFFFFF8F1),
      surface: const Color(0xFFFFFFFF),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthenticationViewModel(userRepository: UserRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SettingsViewModel(repository: SettingsRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(repository: CycleRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DailyLogViewModel(repository: DailyLogRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CalendarViewModel(repository: CalendarRepositoryImpl()),
        ),
        ChangeNotifierProvider(create: (_) => EducationViewModel()),

        ChangeNotifierProvider(create: (_) => PregnancyViewModel()),
        ChangeNotifierProvider(create: (_) => AppearanceProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Luna',
        scaffoldMessengerKey: appScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: const Color(0xFFFFF8F1),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Color(0xFF4B4B4B)),
            foregroundColor: Color(0xFF4B4B4B),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const splash.SplashScreen(),
          '/': (_) => const AuthGate(),
          '/first': (_) => const SplashScreen(),
          '/home': (_) => const AuthGate(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationViewModel>(
      builder: (context, authVm, child) {
        if (authVm.status == AuthStatus.initializing || authVm.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8F1),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authVm.status == AuthStatus.error) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Erreur d\'authentification'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Se connecter'),
                  ),
                  if (authVm.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(authVm.errorMessage!),
                    ),
                ],
              ),
            ),
          );
        }

        if (!authVm.isAuthenticated) {
          return const LoginScreen();
        }

        return const OnboardingRouter();
      },
    );
  }
}

class OnboardingRouter extends StatefulWidget {
  const OnboardingRouter({super.key});

  @override
  State<OnboardingRouter> createState() => _OnboardingRouterState();
}

class _OnboardingRouterState extends State<OnboardingRouter> {
  late final Future<Map<String, dynamic>?> _initialUserProfile;

  @override
  void initState() {
    super.initState();
    _initialUserProfile = UserRepository().loadCurrentUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _initialUserProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8F1),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userProfile = snapshot.data;
        if (userProfile != null && (userProfile['isOnboarded'] == true)) {
          final mode = (userProfile['mode'] as String?) ?? 'cycle';
          if (mode == 'pregnancy') {
            return const PregnancyHomePage();
          }
          return const AppEntry();
        }

        return const OnboardingEntryPage();
      },
    );
  }
}
