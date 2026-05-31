import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zyra/firebase_options.dart';
import 'package:zyra/onboarding/cycle_dashboard.dart';
import 'package:zyra/onboarding/onboarding_model.dart';
import 'package:zyra/onboarding/onboarding_screen.dart';
import 'package:zyra/onboarding/onboarding_service.dart';
import 'package:zyra/pregnancy/pregnancy_tracker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ZyraApp());
}

class ZyraApp extends StatelessWidget {
  const ZyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zyra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E8C),
          primary: const Color(0xFFE91E8C),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF0F8),
        textTheme: GoogleFonts.poppinsTextTheme(),
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
            backgroundColor: Color(0xFFFFF0F8),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E8C)),
            ),
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