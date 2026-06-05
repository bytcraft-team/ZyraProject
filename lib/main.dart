import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:zyra/l10n/app_localizations.dart';

import 'providers/user_provider.dart';
import 'providers/cycle_provider.dart';
import 'providers/appearance_provider.dart';
import 'viewmodel/notification_provider.dart';

import 'services/local_notification_service.dart';

import 'screens/pages/login_screen.dart';
import 'screens/pages/signup_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/pages/appearance_settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase
  await Firebase.initializeApp();

  // 🔔 Notifications
  await LocalNotificationService.init();

  // 📱 Status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class LunaApp extends StatelessWidget {
  const LunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CycleProvider(),
        ),

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
        ChangeNotifierProvider(
          create: (_) => EducationViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => PregnancyViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Luna',
        scaffoldMessengerKey: appScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
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

          // ================= LANGUAGE =================

          locale: appearance.locale,

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