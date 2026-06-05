import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appearance_provider.dart';
import '../../l10n/app_localizations.dart';

import '../pages/cycle_settings_page.dart';
import '../pages/notification_settings_page.dart';
import '../pages/appearance_settings_page.dart';
import '../pages/security_settings_page.dart';
import '../pages/about_settings_page.dart';
import '../pages/ai_settings_page.dart';
import '../pages/edit_profile_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppearanceProvider>();
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ❌ FIX IMPORTANT: ne pas bloquer le dark mode
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: provider.currentPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settings,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _hero(context, provider),

          const SizedBox(height: 8),

          _section(l10n.cycleProfile),
          _tile(context,
              emoji: '🩸',
              bg: const Color(0xFFFDEEF4),
              title: l10n.cycleProfile,
              subtitle: l10n.cycleDescription,
              page: const CycleSettingsPage()),

          _section(l10n.notifications),
          _tile(context,
              emoji: '🔔',
              bg: const Color(0xFFEEEDFE),
              title: l10n.notifications,
              subtitle: l10n.notificationsDesc,
              page: const NotificationSettingsPage()),

          _section(l10n.appearance),
          _tile(context,
              emoji: '🎨',
              bg: const Color(0xFFF5EEFE),
              title: l10n.appearance,
              subtitle: l10n.customizeAppearance,
              page: const AppearanceSettingsPage()),

          _section(l10n.security),
          _tile(context,
              emoji: '🔒',
              bg: const Color(0xFFEEF4FE),
              title: l10n.security,
              subtitle: l10n.securityDesc,
              page: const SecuritySettingsPage()),

          _section(l10n.aiAssistant),
          _tile(context,
              emoji: '🤖',
              bg: const Color(0xFFFEF7EE),
              title: l10n.aiAssistant,
              subtitle: l10n.aiDesc,
              page: const AiSettingsPage()),

          _section(l10n.about),
          _tile(context,
              emoji: 'ℹ️',
              bg: const Color(0xFFE1F5EE),
              title: l10n.about,
              subtitle: l10n.aboutDesc,
              page: const AboutSettingsPage()),

          const SizedBox(height: 16),
          _divider(),
          _logout(context, l10n),
        ],
      ),
    );
  }

  // ================= HERO =================
  Widget _hero(BuildContext context, AppearanceProvider provider) {
    return Container(
      color: provider.currentPrimaryColor,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          // ✅ Avatar cliquable
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 2),
              ),
              alignment: Alignment.center,
              child: const Text('SA',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sara Saadi',
                    style: TextStyle(color: Colors.white, fontSize: 17)),
                SizedBox(height: 2),
                Text('sara@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFFB06080),
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget _tile(BuildContext context,
      {required String emoji,
      required Color bg,
      required String title,
      required String subtitle,
      required Widget page}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),

      // ✅ FIX dark mode border/background
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2D6E4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _logout(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text('🚪'),
              const SizedBox(width: 12),
              Text(l10n.logout,
                  style: const TextStyle(color: Color(0xFFC0406A))),
            ],
          ),
        ),
      ),
    );
  }
}