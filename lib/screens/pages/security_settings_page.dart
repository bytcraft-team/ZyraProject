import 'package:flutter/material.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _fingerprint = false;
  bool _pinCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FB),
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 40),
        children: [
          _buildHero(),
          const SizedBox(height: 8),
          _buildSectionLabel("Accès à l'application"),
          _buildCard(children: [
            _buildToggleTile(
              emoji: '👆',
              bg: const Color(0xFFEEF4FE),
              title: 'Verrouillage par empreinte',
              subtitle: 'Touch ID / Face ID',
              value: _fingerprint,
              onChanged: (v) => setState(() => _fingerprint = v),
            ),
            const Divider(height: 0.5, thickness: 0.5, indent: 64, color: Color(0xFFF5E0EC)),
            _buildToggleTile(
              emoji: '🔢',
              bg: const Color(0xFFFDEEF4),
              title: 'Code PIN',
              subtitle: '4 ou 6 chiffres',
              value: _pinCode,
              onChanged: (v) => setState(() => _pinCode = v),
              isLast: true,
            ),
          ]),
          _buildSectionLabel('Mes données'),
          _buildCard(children: [
            _buildInfoRow('Données stockées', 'Localement (SQLFLite DB)'),
            const Divider(height: 0.5, thickness: 0.5, indent: 16, color: Color(0xFFF5E0EC)),
            _buildInfoRow('Synchronisation', 'Firebase (profil)'),
            const Divider(height: 0.5, thickness: 0.5, indent: 16, color: Color(0xFFF5E0EC)),
            _buildInfoRow('Images', '100% local'),
          ]),
          _buildSectionLabel('Actions'),
          _buildActionCard(
            emoji: '📤',
            bg: const Color(0xFFF0EEFE),
            label: 'Exporter mes données (CSV)',
            color: const Color(0xFF993556),
            onTap: _showExportDialog,
          ),
          const SizedBox(height: 8),
          _buildActionCard(
            emoji: '🗑️',
            bg: const Color(0xFFFCEBEB),
            label: 'Supprimer toutes mes données',
            color: const Color(0xFFA32D2D),
            onTap: () => _showDeleteDialog(context),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFC8698A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Confidentialité & Sécurité',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFC8698A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text('🔒', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Confidentialité & Sécurité',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(height: 2),
                Text('Protège tes données personnelles',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: Color(0xFFB06080), letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D6E4)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleTile({
    required String emoji,
    required Color bg,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF3A1A28))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFFB06080))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFC8698A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE8C5D5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontSize: 13, color: Color(0xFFB06080))),
          Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF3A1A28), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String emoji,
    required Color bg,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF2D6E4)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Exporter mes données', style: TextStyle(color: Color(0xFF3A1A28))),
        content: const Text('Tes données seront exportées au format CSV.',
            style: TextStyle(color: Color(0xFFB06080))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFFB06080)))),
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Exporter', style: TextStyle(color: Color(0xFFC8698A), fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Supprimer toutes mes données', style: TextStyle(color: Color(0xFF3A1A28))),
        content: const Text('Cette action est irréversible. Toutes tes données seront supprimées.',
            style: TextStyle(color: Color(0xFFB06080))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFFB06080)))),
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Supprimer', style: TextStyle(color: Color(0xFFA32D2D), fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sécurité mise à jour !'),
            backgroundColor: Color(0xFFC8698A),
          ),
        );
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC8698A),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: const Text('Enregistrer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }
}
