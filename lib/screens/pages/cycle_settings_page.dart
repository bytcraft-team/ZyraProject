import 'package:flutter/material.dart';

class CycleSettingsPage extends StatefulWidget {
  const CycleSettingsPage({super.key});

  @override
  State<CycleSettingsPage> createState() => _CycleSettingsPageState();
}

class _CycleSettingsPageState extends State<CycleSettingsPage> {
  int _cycleDays = 28;
  int _rulesDays = 5;
  DateTime _lastPeriod = DateTime.now();
  int _selectedMode = 0; // 0 = cycle, 1 = grossesse

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FB),
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 40),
        children: [
          _buildHero(),
          const SizedBox(height: 16),
          _buildSectionLabel('Durée du cycle (jours)'),
          _buildStepperCard(
            label: 'Mon cycle dure',
            value: _cycleDays,
            min: 21,
            max: 45,
            onDecrement: () => setState(() => _cycleDays = (_cycleDays - 1).clamp(21, 45)),
            onIncrement: () => setState(() => _cycleDays = (_cycleDays + 1).clamp(21, 45)),
          ),
          _buildSectionLabel('Durée des règles (jours)'),
          _buildStepperCard(
            label: 'Mes règles durent',
            value: _rulesDays,
            min: 2,
            max: 10,
            onDecrement: () => setState(() => _rulesDays = (_rulesDays - 1).clamp(2, 10)),
            onIncrement: () => setState(() => _rulesDays = (_rulesDays + 1).clamp(2, 10)),
          ),
          _buildSectionLabel('Date de ma dernière période'),
          _buildDateCard(),
          _buildSectionLabel('Mode actuel'),
          _buildModeSelector(),
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
      title: const Text('Cycle & Profil',
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
            child: const Text('🩸', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cycle & Profil',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(height: 2),
                Text('Personnalise ton suivi menstruel',
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

  Widget _buildStepperCard({
    required String label,
    required int value,
    required int min,
    required int max,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF2D6E4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF3A1A28))),
          ),
          _stepBtn(Icons.remove, onDecrement),
          const SizedBox(width: 10),
          Text('$value',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF3A1A28))),
          const SizedBox(width: 10),
          _stepBtn(Icons.add, onIncrement),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFFDEEF4),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE8C5D5)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFFC8698A)),
      ),
    );
  }

  Widget _buildDateCard() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _lastPeriod,
          firstDate: DateTime.now().subtract(const Duration(days: 180)),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFFC8698A)),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _lastPeriod = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF2D6E4)),
        ),
        child: Row(
          children: [
            const Text('📅', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_lastPeriod.day}/${_lastPeriod.month}/${_lastPeriod.year}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF3A1A28)),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD4A0B8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(child: _modeCard(0, '🩸', 'Cycle normal', 'Suivi menstruel')),
        const SizedBox(width: 8),
        Expanded(child: _modeCard(1, '🤰', 'Grossesse', 'Suivi hebdomadaire')),
      ],
    );
  }

  Widget _modeCard(int index, String emoji, String title, String subtitle) {
    final selected = _selectedMode == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFDEEF4) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFC8698A) : const Color(0xFFF2D6E4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF3A1A28))),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFFB06080))),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres enregistrés !'),
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
