import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notifRegles = true;
  bool _notifFertile = true;
  bool _notifOvulation = true;
  bool _notifMessages = false;
  bool _notifPosts = false;
  bool _notifIA = true;
  bool _notifSymptomes = true;

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
          _buildSectionLabel('Règles & Cycle'),
          _buildCard(children: [
            _buildToggleTile(
              emoji: '🩸',
              bg: const Color(0xFFFDEEF4),
              title: 'Rappel début de règles',
              subtitle: 'Notification 1 jour avant',
              value: _notifRegles,
              onChanged: (v) => setState(() => _notifRegles = v),
            ),
            _buildDivider(),
            _buildToggleTile(
              emoji: '🌿',
              bg: const Color(0xFFEEF9F3),
              title: 'Jours fertiles',
              subtitle: 'Alerte pendant la fenêtre fertile',
              value: _notifFertile,
              onChanged: (v) => setState(() => _notifFertile = v),
            ),
            _buildDivider(),
            _buildToggleTile(
              emoji: '🌸',
              bg: const Color(0xFFFDEEF4),
              title: "Jour d'ovulation",
              subtitle: 'Rappel le jour J',
              value: _notifOvulation,
              onChanged: (v) => setState(() => _notifOvulation = v),
              isLast: true,
            ),
          ]),
          _buildSectionLabel('Social & IA'),
          _buildCard(children: [
            _buildToggleTile(
              emoji: '💬',
              bg: const Color(0xFFEEF4FE),
              title: 'Nouveaux messages',
              subtitle: 'Notifications du chat',
              value: _notifMessages,
              onChanged: (v) => setState(() => _notifMessages = v),
            ),
            _buildDivider(),
            _buildToggleTile(
              emoji: '📝',
              bg: const Color(0xFFF0EEFE),
              title: 'Nouvelles publications',
              subtitle: 'Posts dans la communauté',
              value: _notifPosts,
              onChanged: (v) => setState(() => _notifPosts = v),
            ),
            _buildDivider(),
            _buildToggleTile(
              emoji: '🤖',
              bg: const Color(0xFFFEF7EE),
              title: "Conseils de l'assistant IA",
              subtitle: 'Suggestions personnalisées',
              value: _notifIA,
              onChanged: (v) => setState(() => _notifIA = v),
              isLast: true,
            ),
          ]),
          _buildSectionLabel('Rappel quotidien'),
          _buildCard(children: [
            _buildToggleTile(
              emoji: '📋',
              bg: const Color(0xFFFDEEF4),
              title: 'Enregistrer mes symptômes',
              subtitle: 'Chaque jour à 20h00',
              value: _notifSymptomes,
              onChanged: (v) => setState(() => _notifSymptomes = v),
              isLast: true,
            ),
          ]),
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
      title: const Text('Notifications',
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
            child: const Text('🔔', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(height: 2),
                Text('Gère tes alertes et rappels',
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

  Widget _buildDivider() {
    return const Divider(height: 0.5, thickness: 0.5, indent: 64, color: Color(0xFFF5E0EC));
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

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications mises à jour !'),
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
