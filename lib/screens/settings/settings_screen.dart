import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC8698A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _buildHero(context),
          const SizedBox(height: 8),
          _buildSectionLabel('Cycle & Profil'),
          _buildNavTile(
            context,
            emoji: '🩸',
            bg: const Color(0xFFFDEEF4),
            title: 'Cycle & Profil',
            subtitle: 'Durée du cycle, des règles, mode grossesse',
            page: const CycleSettingsPage(),
          ),
          _buildSectionLabel('Notifications'),
          _buildNavTile(
            context,
            emoji: '🔔',
            bg: const Color(0xFFEEEDFE),
            title: 'Notifications',
            subtitle: 'Alertes règles, fertilité, IA, messages',
            page: const NotificationSettingsPage(),
          ),
          _buildSectionLabel('Apparence'),
          _buildNavTile(
            context,
            emoji: '🎨',
            bg: const Color(0xFFF5EEFE),
            title: 'Apparence',
            subtitle: 'Thème, couleurs, langue',
            page: const AppearanceSettingsPage(),
          ),
          _buildSectionLabel('Assistant IA'),
          _buildNavTile(
            context,
            emoji: '🤖',
            bg: const Color(0xFFFEF7EE),
            title: 'Assistant IA',
            subtitle: 'Conseils personnalisés, suggestions intelligentes',
            page: const AiSettingsPage(),
          ),
          _buildSectionLabel('Confidentialité & Sécurité'),
          _buildNavTile(
            context,
            emoji: '🔒',
            bg: const Color(0xFFEEF4FE),
            title: 'Confidentialité & Sécurité',
            subtitle: 'Verrouillage, export, suppression',
            page: const SecuritySettingsPage(),
          ),
          _buildSectionLabel('À propos'),
          _buildNavTile(
            context,
            emoji: 'ℹ️',
            bg: const Color(0xFFE1F5EE),
            title: 'À propos',
            subtitle: 'Version, légal, équipe',
            page: const AboutSettingsPage(),
          ),
          const SizedBox(height: 16),
          _buildDivider(),
          _buildLogoutTile(context),
        ],
      ),
    );
  }
 
  Widget _buildHero(BuildContext context) {
    return Container(
      color: const Color(0xFFC8698A),
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
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              alignment: Alignment.center,
              child: const Text(
                'SA',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sara Saadi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  'sara@example.com',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          // ✅ Bouton Modifier avec navigation vers EditProfilePage
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.18),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.35)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            child: const Text('Modifier', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
 
  Widget _buildSectionLabel(String text) {
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
 
  Widget _buildNavTile(
    BuildContext context, {
    required String emoji,
    required Color bg,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D6E4), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF3A1A28))),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFB06080))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFD4A0B8), size: 20),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildDivider() {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2D6E4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
 
  Widget _buildLogoutTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D6E4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showLogoutDialog(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFFFDEEF4),
                    borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: const Text('🚪', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              const Text('Se déconnecter',
                  style: TextStyle(fontSize: 14, color: Color(0xFFC0406A))),
            ],
          ),
        ),
      ),
    );
  }
 
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Se déconnecter',
            style: TextStyle(color: Color(0xFF3A1A28))),
        content: const Text('Es-tu sûre de vouloir te déconnecter ?',
            style: TextStyle(color: Color(0xFFB06080))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler',
                  style: TextStyle(color: Color(0xFFB06080)))),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Déconnecter',
                  style: TextStyle(
                      color: Color(0xFFC0406A),
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
