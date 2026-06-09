import 'package:flutter/material.dart';
import 'package:zyra/paramettres/models/aiconfig.dart';
import 'package:zyra/paramettres/services/ai_settings_storage.dart';
import 'package:zyra/paramettres/services/ai_firestore_service.dart';

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
  int _selectedNiveau = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final config = await AiSettingsStorage.load();
    setState(() {
      _aiActif = config.aiActif;
      _suggestionsPersonnalisees = config.suggestions;
      _conseilsCycle = config.cycle;
      _conseilsGrossesse = config.grossesse;
      _conseilsSymptomes = config.symptomes;
      _selectedNiveau = config.niveau;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final config = AiConfig(
      aiActif: _aiActif,
      suggestions: _suggestionsPersonnalisees,
      cycle: _conseilsCycle,
      grossesse: _conseilsGrossesse,
      symptomes: _conseilsSymptomes,
      niveau: _selectedNiveau,
    );

    await AiSettingsStorage.save(config);
    try {
      await AiFirestoreService().saveAiConfig(data: {
        'aiActif': config.aiActif,
        'cycle': config.cycle,
        'grossesse': config.grossesse,
        'symptomes': config.symptomes,
        'suggestions': config.suggestions,
        'niveau': config.niveau,
      });
    } catch (e) {
      debugPrint("❌ Firestore error: $e");
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paramètres IA enregistrés !')));
    Navigator.pop(context, config);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F8),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)]),
          ),
        ),
        title: const Text("Assistant IA", style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
        children: [
          _buildSectionLabel("Activation"),
          _card([_toggle("Assistant IA", "Activer l'assistant", _aiActif, (v) => setState(() => _aiActif = v), "🤖")]),
          
          _buildSectionLabel("Domaines de conseils"),
          _card([
            _toggle("Conseils cycle", "Analyse du cycle", _conseilsCycle, (v) => setState(() => _conseilsCycle = v), "🩸"),
            _divider(),
            _toggle("Conseils grossesse", "Suivi grossesse", _conseilsGrossesse, (v) => setState(() => _conseilsGrossesse = v), "🤰"),
            _divider(),
            _toggle("Symptômes", "Analyse symptômes", _conseilsSymptomes, (v) => setState(() => _conseilsSymptomes = v), "📋"),
          ]),

          _buildSectionLabel("Personnalisation"),
          _card([_toggle("Suggestions", "Basées sur vos données", _suggestionsPersonnalisees, (v) => setState(() => _suggestionsPersonnalisees = v), "✨")]),

          _buildSectionLabel("Niveau de réponse"),
          _buildNiveauSelector(),

          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  // UI Components
  Widget _buildSectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
    child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
  );

  Widget _card(List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF5E6F5))),
    child: Column(children: children),
  );

  Widget _toggle(String title, String subtitle, bool value, Function(bool) onChanged, String emoji) => ListTile(
    leading: Text(emoji, style: const TextStyle(fontSize: 22)),
    title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
    trailing: Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFFE91E8C)),
  );

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16);

  Widget _buildNiveauSelector() => Row(
    children: List.generate(3, (i) {
      final labels = ["Basique", "Normal", "Détaillé"];
      final selected = _selectedNiveau == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedNiveau = i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE91E8C) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF5E6F5)),
            ),
            child: Center(child: Text(labels[i], style: TextStyle(color: selected ? Colors.white : Colors.black))),
          ),
        ),
      );
    }),
  );

  Widget _buildSaveButton() => ElevatedButton(
    onPressed: _saveSettings,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE91E8C),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: const Text("Enregistrer"),
  );
}