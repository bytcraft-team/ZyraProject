import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zyra/onboarding/cycle_dashboard.dart';
import 'package:zyra/onboarding/onboarding_model.dart';
import 'package:zyra/onboarding/onboarding_screen.dart';
import 'package:zyra/onboarding/onboarding_service.dart';
import 'package:zyra/pregnancy/pregnancy_tracker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
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

    return MaterialApp(
      title: 'Luna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFFFF8F1),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Color(0xFF4B4B4B)),
          foregroundColor: Color(0xFF4B4B4B),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
        ),
      ),
      home: const OnboardingRouter(),
    );
  }
}

class OnboardingRouter extends StatefulWidget {
  const OnboardingRouter({super.key});

  @override
  State<OnboardingRouter> createState() => _OnboardingRouterState();
}

class _OnboardingRouterState extends State<OnboardingRouter> {
  late final Future<UserProfileType?> _initialRoute;

  @override
  void initState() {
    super.initState();
    _initialRoute = OnboardingService.loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfileType?>(
      future: _initialRoute,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8F1),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profileType = snapshot.data;
        if (profileType == UserProfileType.pregnancy) {
          return const PregnancyHomePage();
        } else if (profileType == UserProfileType.cycle) {
          return const CycleDashboardPage();
        }

        return const OnboardingEntryPage();
      },
    );
  }
}
