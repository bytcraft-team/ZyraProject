import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/l10n/app_localizations.dart';
import 'package:zyra/paramettres/providers/appearance_provider.dart';
import 'package:zyra/paramettres/providers/user_provider.dart';

import 'package:zyra/paramettres/screens/pages/cycle_settings_page.dart';
import 'package:zyra/paramettres/screens/pages/notification_settings_page.dart';
import 'package:zyra/paramettres/screens/pages/appearance_settings_page.dart';
import 'package:zyra/paramettres/screens/pages/security_settings_page.dart';
import 'package:zyra/paramettres/screens/pages/about_settings_page.dart';
import 'package:zyra/paramettres/screens/pages/ai_settings_page.dart';
import 'package:zyra/paramettres/screens/pages/edit_profile_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppearanceProvider?>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F8), 
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)],
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.settings, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
        children: [
          _buildHero(context),
          const SizedBox(height: 16),

          _buildSectionLabel(l10n.cycleProfile),
          _tile(context, '🩸', const Color(0xFFFDEEF4), l10n.cycleProfile, l10n.cycleDescription,  CycleSettingsPage()),
          
          _buildSectionLabel(l10n.notifications),
          _tile(context, '🔔', const Color(0xFFEEEDFE), l10n.notifications, l10n.notificationsDesc,  NotificationSettingsPage()),

          _buildSectionLabel(l10n.appearance),
          _tile(context, '🎨', const Color(0xFFF5EEFE), l10n.appearance, l10n.customizeAppearance, AppearanceSettingsPage()),

          _buildSectionLabel(l10n.security),
          _tile(context, '🔒', const Color(0xFFEEF4FE), l10n.security, l10n.securityDesc,  SecuritySettingsPage()),

          _buildSectionLabel(l10n.aiAssistant),
          _tile(context, '🤖', const Color(0xFFFEF7EE), l10n.aiAssistant, l10n.aiDesc, AiSettingsPage()),

          _buildSectionLabel(l10n.about),
          _tile(context, 'ℹ️', const Color(0xFFE1F5EE), l10n.about, l10n.aboutDesc, AboutSettingsPage()),

          const SizedBox(height: 24),
          _buildLogoutButton(context, l10n),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
            child: CircleAvatar(radius: 28, backgroundColor: Colors.white.withOpacity(0.2), child: const Text('SA', style: TextStyle(color: Colors.white, fontSize: 20))),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sara Saadi', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              Text('sara@example.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF9B59B6), letterSpacing: 0.8)),
    );
  }

  Widget _tile(BuildContext context, String emoji, Color bg, String title, String subtitle, Widget page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5E6F5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: Text(emoji, style: const TextStyle(fontSize: 18))),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D1B3D))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFE91E8C)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) => ElevatedButton(
        onPressed: () => _showLogoutDialog(context, userProvider, l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE91E8C),
          elevation: 0,
          side: const BorderSide(color: Color(0xFFF5E6F5)),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(l10n.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.logout, style: const TextStyle(fontWeight: FontWeight.w600)),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () async {
            Navigator.pop(context);
            await userProvider.logout();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          }, child: const Text('Se déconnecter', style: TextStyle(color: Color(0xFFE91E8C), fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}