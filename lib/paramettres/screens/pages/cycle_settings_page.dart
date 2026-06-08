import 'package:flutter/material.dart';

class CycleSettingsPage extends StatefulWidget {
  const CycleSettingsPage({super.key});

  @override
  State<CycleSettingsPage> createState() => _CycleSettingsPageState();
}

class _CycleSettingsPageState extends State<CycleSettingsPage> {
  int _selectedMode = 0; // 0: Normal, 1: Grossesse
  int _cycleDuration = 28;
  int _periodDuration = 5;
  DateTime _lastPeriodDate = DateTime.now();
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    int jours = _lastPeriodDate.add(Duration(days: _cycleDuration)).difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F8),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)],
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paramètres du cycle',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
        children: [
          _buildSectionLabel('Mode de suivi'),
          Row(
            children: [
              Expanded(child: _modeCard(0, '🩸', 'Cycle Normal', 'Suivi menstruel classique')),
              const SizedBox(width: 12),
              Expanded(child: _modeCard(1, '🤰', 'Grossesse', 'Suivi hebdomadaire')),
            ],
          ),
          const SizedBox(height: 16),

          _buildSectionLabel('Durée du cycle'),
          _buildDropdownCard(
            label: 'Mon cycle dure généralement :',
            value: '$_cycleDuration jours',
            onTap: () => _showNumberPicker(20, 45, _cycleDuration, (val) {
              setState(() => _cycleDuration = val);
            }),
          ),
          const SizedBox(height: 12),

          _buildSectionLabel('Durée des règles'),
          _buildDropdownCard(
            label: 'Mes règles durent environ :',
            value: '$_periodDuration jours',
            onTap: () => _showNumberPicker(3, 10, _periodDuration, (val) {
              setState(() => _periodDuration = val);
            }),
          ),
          const SizedBox(height: 12),

          _buildSectionLabel('Dernières règles'),
          _buildDropdownCard(
            label: 'Date de début des dernières règles',
            value: '${_lastPeriodDate.day}/${_lastPeriodDate.month}/${_lastPeriodDate.year}',
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _lastPeriodDate,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _lastPeriodDate = picked);
              }
            },
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF5E6F5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 Calculs automatiques',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D1B3D)),
                ),
                const SizedBox(height: 12),
                _infoRow('🩸 Prochaines règles', 'Dans $jours jours'),
                const Divider(color: Color(0xFFF5E6F5)),
                _infoRow('🌸 Ovulation prévue', '${_lastPeriodDate.add(Duration(days: _cycleDuration - 14)).day}/${_lastPeriodDate.add(Duration(days: _cycleDuration - 14)).month}'),
                const Divider(color: Color(0xFFF5E6F5)),
                _infoRow('⏳ Jours restants', jours >= 0 ? '$jours jours' : 'En cours'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              setState(() => _isSaved = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cycle enregistré avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Enregistrer le cycle'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF9B59B6), letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildDropdownCard({required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF5E6F5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF2D1B3D))),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFFE91E8C)),
          ],
        ),
      ),
    );
  }

  Widget _modeCard(int index, String emoji, String title, String subtitle) {
    bool isSelected = _selectedMode == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = index),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFFE91E8C) : const Color(0xFFF5E6F5), width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D1B3D))),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF999999))),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2D1B3D))),
        ],
      ),
    );
  }

  void _showNumberPicker(int min, int max, int current, ValueChanged<int> onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: ListView.builder(
            itemCount: max - min + 1,
            itemBuilder: (context, i) {
              int val = min + i;
              return ListTile(
                title: Center(
                  child: Text(
                    '$val jours',
                    style: TextStyle(
                      fontWeight: val == current ? FontWeight.bold : FontWeight.normal,
                      color: val == current ? const Color(0xFFE91E8C) : Colors.black,
                    ),
                  ),
                ),
                onTap: () {
                  onSelected(val);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}