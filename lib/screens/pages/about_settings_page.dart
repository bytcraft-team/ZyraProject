import 'package:flutter/material.dart';

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

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
          _buildSectionLabel('Application'),
          _buildCard(children: [
            _buildInfoRow('Nom', 'ZyraApp'),
            _divider(),
            _buildInfoRowWithBadge('Version', 'v1.0.0'),
            _divider(),
            _buildInfoRow('Plateforme', 'Flutter'),
            _divider(),
            _buildInfoRow('Langage', 'Dart'),
          ]),
          _buildSectionLabel('Légal'),
          _buildCard(children: [
            _buildLinkRow(context, 'Politique de confidentialité'),
            _divider(),
            _buildLinkRow(context, "Conditions d'utilisation"),
          ]),
          _buildSectionLabel('Équipe'),
          _buildCard(children: [
            _buildInfoRow('SOUR Ahlam', 'Design UI/UX Global'),
            _divider(),
            _buildInfoRow('ETTABTI Hajar', 'Design UI/UX Modules'),
            _divider(),
            _buildInfoRow('LAAFAR Aziza', 'Backend Pregnancy & IA'),
            _divider(),
            _buildInfoRow('SAADI Sara', 'Backend Users & Symptoms'),
            _divider(),
            _buildInfoRow('ESSADIKI Ezzahraa', 'Backend Cycle & chat '),
          ]),
          _buildSectionLabel('Session'),
          _buildLogoutButton(context),
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
      title: const Text('À propos',
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
            child: const Text('ℹ️', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('À propos',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(height: 2),
                Text("Informations sur l'application",
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

  Widget _divider() =>
      const Divider(height: 0.5, thickness: 0.5, indent: 16, color: Color(0xFFF5E0EC));

  Widget _buildInfoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontSize: 13, color: Color(0xFFB06080))),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 13, color: Color(0xFF3A1A28), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithBadge(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontSize: 13, color: Color(0xFFB06080))),
          Row(
            children: [
              Text(value,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF3A1A28), fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEEF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Nouveau',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF993556))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(BuildContext context, String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF3A1A28))),
            const Text('Voir →', style: TextStyle(fontSize: 13, color: Color(0xFFC8698A))),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
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
              decoration: BoxDecoration(
                  color: const Color(0xFFFDEEF4), borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: const Text('🚪', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            const Text('Se déconnecter',
                style: TextStyle(fontSize: 14, color: Color(0xFFC0406A))),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Se déconnecter', style: TextStyle(color: Color(0xFF3A1A28))),
        content: const Text('Es-tu sûre de vouloir te déconnecter ?',
            style: TextStyle(color: Color(0xFFB06080))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFFB06080)))),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Déconnecter',
                  style: TextStyle(color: Color(0xFFC0406A), fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
