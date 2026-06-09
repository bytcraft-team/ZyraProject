import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/paramettres/viewmodel/notification_provider.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NotificationProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F8),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)]),
          ),
        ),
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
              children: [
                _buildHero(),
                const SizedBox(height: 20),
                _buildSectionLabel('Préférences'),
                _card([
                  _switchTile("🩸 Règles", "Rappels pour le début du cycle", provider.settings.regles, provider.setRegles),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _switchTile("🌿 Fertilité", "Fenêtre de fertilité", provider.settings.fertile, provider.setFertile),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _switchTile("🌸 Ovulation", "Jour de l'ovulation", provider.settings.ovulation, provider.setOvulation),
                  const Divider(height: 1, indent: 16, endIndent: 16), // Divider إضافي
                  _switchTile("🤰 Grossesse", "Suivi hebdomadaire", provider.settings.grossesse, provider.setGrossesse), 
                  ]),
                const SizedBox(height: 24),
                _buildSaveButton(provider),
              ],
            ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: Colors.white, size: 30),
          SizedBox(width: 16),
          Text('Paramètres des alertes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5E6F5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D1B3D))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
      activeColor: const Color(0xFFE91E8C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSaveButton(NotificationProvider provider) {
    return ElevatedButton(
      onPressed: provider.saveAll,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: provider.isSaved 
          ? const Text('Enregistré !') 
          : const Text('Enregistrer les modifications'),
    );
  }
}