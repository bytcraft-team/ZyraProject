import 'package:flutter/material.dart';

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  int _selectedColor = 0;
  int _selectedMode = 0; // 0=clair, 1=sombre, 2=système
  int _selectedLang = 0; // 0=FR, 1=EN, 2=AR

  final List<Map<String, dynamic>> _colorThemes = [
    {'name': 'Rose doux', 'sub': 'Par défaut', 'bg': Color(0xFFFDEEF4), 'dot': Color(0xFFC8698A), 'text': Color(0xFF72243E), 'sub_c': Color(0xFF993556)},
    {'name': 'Lavande', 'sub': 'Violet doux', 'bg': Color(0xFFF0EEFE), 'dot': Color(0xFF7F77DD), 'text': Color(0xFF3C3489), 'sub_c': Color(0xFF534AB7)},
    {'name': 'Menthe', 'sub': 'Vert frais', 'bg': Color(0xFFE1F5EE), 'dot': Color(0xFF1D9E75), 'text': Color(0xFF085041), 'sub_c': Color(0xFF0F6E56)},
    {'name': 'Pêche', 'sub': 'Chaud & doux', 'bg': Color(0xFFFAECE7), 'dot': Color(0xFFD85A30), 'text': Color(0xFF712B13), 'sub_c': Color(0xFF993C1D)},
  ];

  final List<Map<String, String>> _languages = [
    {'flag': '🇫🇷', 'name': 'Français'},
    {'flag': '🇬🇧', 'name': 'English'},
    {'flag': '🇲🇦', 'name': 'العربية'},
  ];

  final List<Map<String, String>> _modes = [
    {'icon': '☀️', 'label': 'Clair'},
    {'icon': '🌙', 'label': 'Sombre'},
    {'icon': '⚙️', 'label': 'Système'},
  ];

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
          _buildSectionLabel('Thème de couleur'),
          _buildColorGrid(),
          _buildSectionLabel("Mode d'affichage"),
          _buildModeSelector(),
          _buildSectionLabel("Langue de l'application"),
          _buildLanguageList(),
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
      title: const Text('Apparence',
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
            child: const Text('🎨', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apparence',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(height: 2),
                Text('Personnalise les couleurs et la langue',
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

  Widget _buildColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: _colorThemes.length,
      itemBuilder: (context, i) {
        final t = _colorThemes[i];
        final selected = _selectedColor == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = i),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t['bg'] as Color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? const Color(0xFFC8698A) : const Color(0xFFF2D6E4),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: t['dot'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const Spacer(),
                Text(t['name'] as String,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: t['text'] as Color)),
                Text(t['sub'] as String,
                    style: TextStyle(fontSize: 11, color: t['sub_c'] as Color)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: List.generate(_modes.length, (i) {
        final selected = _selectedMode == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMode = i),
            child: Container(
              margin: EdgeInsets.only(right: i < _modes.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
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
                  Text(_modes[i]['icon']!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(_modes[i]['label']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? const Color(0xFFC8698A) : const Color(0xFF3A1A28),
                        fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                      )),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLanguageList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D6E4)),
      ),
      child: Column(
        children: List.generate(_languages.length, (i) {
          final selected = _selectedLang == i;
          return Column(
            children: [
              InkWell(
                onTap: () => setState(() => _selectedLang = i),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Text(_languages[i]['flag']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_languages[i]['name']!,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF3A1A28))),
                      ),
                      if (selected)
                        const Icon(Icons.check, color: Color(0xFFC8698A), size: 18),
                    ],
                  ),
                ),
              ),
              if (i < _languages.length - 1)
                const Divider(height: 0.5, thickness: 0.5, indent: 52, color: Color(0xFFF5E0EC)),
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
            content: Text('Apparence mise à jour !'),
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
