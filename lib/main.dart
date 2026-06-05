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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CycleProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AppearanceProvider(),
        ),

        // 🔔 Notifications Provider
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..load(),
        ),
      ],

      child: const AppRoot(),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppearanceProvider>(
      builder: (context, appearance, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Zyra',

          // ================= LANGUAGE =================

          locale: appearance.locale,

          supportedLocales: AppLocalizations.supportedLocales,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ================= THEME =================

          theme: appearance.lightTheme,

          darkTheme: appearance.darkTheme,

          themeMode: appearance.themeMode,

          // ================= START =================

          home: const SettingsScreen(),

          routes: {
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignupScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/appearance': (_) => const AppearanceSettingsPage(),
          },

          // ================= GLOBAL FONT =================

          builder: (context, child) {
            final theme = Theme.of(context);

            return Theme(
              data: theme.copyWith(
                textTheme: GoogleFonts.plusJakartaSansTextTheme(
                  theme.textTheme,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}