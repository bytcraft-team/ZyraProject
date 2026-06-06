import 'package:flutter/material.dart';
 
class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});
 
  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}
 
class _AiSettingsPageState extends State<AiSettingsPage> {
  bool _aiActif = true;
  bool _suggestionsPersonnalisees = true;
  bool _conseilsCycle = true;
  bool _conseilsGrossesse = true;
  bool _conseilsSymptomes = true;
  bool _notifIA = true;
  int _selectedNiveau = 1; // 0=basique, 1=normal, 2=détaillé
 
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
          _buildSectionLabel("Activation"),
          _buildCard(children: [
            _buildToggleTile(
              emoji: '🤖',
              bg: const Color(0xFFFEF7EE),
              title: "Assistant IA actif",
              subtitle: "Activer ou désactiver l'assistant IA",
              value: _aiActif,
              onChanged: (v) => setState(() => _aiActif = v),
              isLast: true,
            ),
          ]),
          _buildSectionLabel("Domaines de conseils"),
          _buildCard(children: [
            _buildToggleTile(
              emoji: '🩸',
              bg: const Color(0xFFFDEEF4),
              title: "Conseils sur le cycle",
              subtitle: "Analyse et recommandations du cycle menstruel",
              value: _conseilsCycle,
              onChanged: (v) => setState(() => _conseilsCycle = v),
            ),
            _divider(),
            _buildToggleTile(
              emoji: '🤰',
              bg: const Color(0xFFE1F5EE),
              title: "Conseils grossesse",
              subtitle: "Informations semaine par semaine",
              value: _conseilsGrossesse,
              onChanged: (v) => setState(() => _conseilsGrossesse = v),
            ),
            _divider(),
            _buildToggleTile(
              emoji: '📋',
              bg: const Color(0xFFF0EEFE),
              title: "Analyse des symptômes",
              subtitle: "Interprétation des symptômes enregistrés",
              value: _conseilsSymptomes,
              onChanged: (v) => setState(() => _conseilsSymptomes = v),
              isLast: true,
            ),
          ]),
          _buildSectionLabel("Personnalisation"),
          _buildCard(children: [
            _buildToggleTile(
              emoji: '✨',
              bg: const Color(0xFFFEF7EE),
              title: "Suggestions personnalisées",
              subtitle: "Basées sur tes données enregistrées",
              value: _suggestionsPersonnalisees,
              onChanged: (v) => setState(() => _suggestionsPersonnalisees = v),
              isLast: true,
            ),
          ]),
          _buildSectionLabel("Niveau de détail des réponses"),
          _buildNiveauSelector(),
          _buildSectionLabel("Notifications IA"),
          _buildCard(children: [
            _buildToggleTile(
              emoji: '🔔',
              bg: const Color(0xFFEEEDFE),
              title: "Alertes de l'assistant",
              subtitle: "Recevoir des conseils et rappels de l'IA",
              value: _notifIA,
              onChanged: (v) => setState(() => _notifIA = v),
              isLast: true,
            ),
          ]),
          _buildSectionLabel("Données utilisées par l'IA"),
          _buildInfoCard(),
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
      title: const Text(
        'Assistant IA',
        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
      ),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text('🤖', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistant IA',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  'Conseils intelligents et personnalisés',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
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
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFFB06080),
          letterSpacing: 0.7,
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
 
  Widget _divider() => const Divider(
      height: 0.5, thickness: 0.5, indent: 64, color: Color(0xFFF5E0EC));
 
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
 
  Widget _buildNiveauSelector() {
    final niveaux = [
      {'label': 'Basique', 'sub': 'Réponses courtes', 'emoji': '💬'},
      {'label': 'Normal', 'sub': 'Équilibré', 'emoji': '📝'},
      {'label': 'Détaillé', 'sub': 'Explications complètes', 'emoji': '📚'},
    ];
 
    return Row(
      children: List.generate(niveaux.length, (i) {
        final selected = _selectedNiveau == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedNiveau = i),
            child: Container(
              margin: EdgeInsets.only(right: i < niveaux.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFDEEF4) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? const Color(0xFFC8698A) : const Color(0xFFF2D6E4),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(niveaux[i]['emoji']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 6),
                  Text(
                    niveaux[i]['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected ? const Color(0xFFC8698A) : const Color(0xFF3A1A28),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    niveaux[i]['sub']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Color(0xFFB06080)),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
 
  Widget _buildInfoCard() {
    final items = [
      {'icon': '🩸', 'text': 'Données du cycle menstruel'},
      {'icon': '🤰', 'text': 'Données de grossesse'},
      {'icon': '📋', 'text': 'Symptômes enregistrés'},
      {'icon': '📅', 'text': 'Historique des périodes'},
    ];
 
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D6E4)),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(items[i]['icon']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Text(items[i]['text']!,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF3A1A28))),
                    const Spacer(),
                    const Icon(Icons.check_circle, color: Color(0xFFC8698A), size: 16),
                  ],
                ),
              ),
              if (i < items.length - 1)
                const Divider(
                    height: 0.5, thickness: 0.5, indent: 46, color: Color(0xFFF5E0EC)),
            ],
          );
        }),
      ),
    );
  }
 
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres IA enregistrés !'),
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
      child: const Text('Enregistrer',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }
}
