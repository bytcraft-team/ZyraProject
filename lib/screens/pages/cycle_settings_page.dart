import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/user_provider.dart';
 
class CycleSettingsPage extends StatefulWidget {
  const CycleSettingsPage({super.key});
 
  @override
  State<CycleSettingsPage> createState() => _CycleSettingsPageState();
}
 
class _CycleSettingsPageState extends State<CycleSettingsPage> {
  late int _cycleDays;
  late int _rulesDays;
  late DateTime _lastPeriod;
  late int _selectedMode;
 
  bool _initialized = false;
 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pré-remplir les valeurs depuis le CycleProvider
    if (!_initialized) {
      final cycleProvider = context.read<CycleProvider>();
      _cycleDays    = cycleProvider.dureeCycle;
      _rulesDays    = cycleProvider.dureeRegles;
      _lastPeriod   = cycleProvider.derniereRegles;
      _selectedMode = cycleProvider.modeGrossesse ? 1 : 0;
      _initialized  = true;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFDF8FB),
          appBar: _buildAppBar(context),
          body: cycleProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFC8698A),
                  ),
                )
              : ListView(
                  padding:
                      const EdgeInsets.fromLTRB(14, 8, 14, 40),
                  children: [
                    _buildHero(),
                    const SizedBox(height: 16),
 
                    // ── Bannière erreur ───────────────
                    if (cycleProvider.errorMessage != null)
                      _buildErrorBanner(cycleProvider),
 
                    // ── Bannière succès ───────────────
                    if (cycleProvider.isSaved)
                      _buildSuccessBanner(),
 
                    _buildSectionLabel('Durée du cycle (jours)'),
                    _buildStepperCard(
                      label: 'Mon cycle dure',
                      value: _cycleDays,
                      min: 21,
                      max: 45,
                      onDecrement: () => setState(() =>
                          _cycleDays =
                              (_cycleDays - 1).clamp(21, 45)),
                      onIncrement: () => setState(() =>
                          _cycleDays =
                              (_cycleDays + 1).clamp(21, 45)),
                    ),
                    _buildSectionLabel('Durée des règles (jours)'),
                    _buildStepperCard(
                      label: 'Mes règles durent',
                      value: _rulesDays,
                      min: 2,
                      max: 10,
                      onDecrement: () => setState(() =>
                          _rulesDays =
                              (_rulesDays - 1).clamp(2, 10)),
                      onIncrement: () => setState(() =>
                          _rulesDays =
                              (_rulesDays + 1).clamp(2, 10)),
                    ),
                    _buildSectionLabel(
                        'Date de ma dernière période'),
                    _buildDateCard(),
                    _buildSectionLabel('Mode actuel'),
                    _buildModeSelector(),
 
                    // ── Info calculs ──────────────────
                    if (cycleProvider.cycle != null)
                      _buildInfoCard(cycleProvider),
 
                    const SizedBox(height: 24),
                    _buildSaveButton(cycleProvider),
                  ],
                ),
        );
      },
    );
  }
 
  // ─── AppBar ───────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFC8698A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Cycle & Profil',
          style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500)),
    );
  }
 
  // ─── Hero ─────────────────────────────────────────────────
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child:
                const Text('🩸', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cycle & Profil',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
                SizedBox(height: 2),
                Text('Personnalise ton suivi menstruel',
                    style: TextStyle(
                        fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  // ─── Bannière erreur ──────────────────────────────────────
  Widget _buildErrorBanner(CycleProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF2C0C0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFA32D2D), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(provider.errorMessage!,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFFA32D2D))),
          ),
          GestureDetector(
            onTap: () => provider.clearError(),
            child: const Icon(Icons.close,
                size: 16, color: Color(0xFFA32D2D)),
          ),
        ],
      ),
    );
  }
 
  // ─── Bannière succès ──────────────────────────────────────
  Widget _buildSuccessBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline,
              color: Color(0xFF2E7D32), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cycle enregistré dans SQLite et Firestore !',
              style:
                  TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }
 
  // ─── Section label ────────────────────────────────────────
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
 
  // ─── Stepper ──────────────────────────────────────────────
  Widget _buildStepperCard({
    required String label,
    required int value,
    required int min,
    required int max,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF2D6E4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF3A1A28))),
          ),
          _stepBtn(Icons.remove, onDecrement),
          const SizedBox(width: 10),
          Text('$value',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3A1A28))),
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFFDEEF4),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE8C5D5)),
        ),
        child:
            Icon(icon, size: 16, color: const Color(0xFFC8698A)),
      ),
    );
  }
 
  // ─── Date picker ──────────────────────────────────────────
  Widget _buildDateCard() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _lastPeriod,
          firstDate:
              DateTime.now().subtract(const Duration(days: 180)),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                  primary: Color(0xFFC8698A)),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _lastPeriod = picked);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF3A1A28)),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFFD4A0B8), size: 20),
          ],
        ),
      ),
    );
  }
 
  // ─── Mode selector ────────────────────────────────────────
  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(
            child:
                _modeCard(0, '🩸', 'Cycle normal', 'Suivi menstruel')),
        const SizedBox(width: 8),
        Expanded(
            child: _modeCard(
                1, '🤰', 'Grossesse', 'Suivi hebdomadaire')),
      ],
    );
  }
 
  Widget _modeCard(
      int index, String emoji, String title, String subtitle) {
    final selected = _selectedMode == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFDEEF4)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFFC8698A)
                : const Color(0xFFF2D6E4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3A1A28))),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFFB06080))),
          ],
        ),
      ),
    );
  }
 
  // ─── Info calculs automatiques ────────────────────────────
  Widget _buildInfoCard(CycleProvider provider) {
    final prochaine = provider.prochaineRegles;
    final ovulation = provider.dateOvulation;
    final jours     = provider.joursAvantRegles;
 
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEEF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF2D6E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 Calculs automatiques',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3A1A28))),
          const SizedBox(height: 10),
          if (prochaine != null)
            _infoRow('🩸 Prochaines règles',
                '${prochaine.day}/${prochaine.month}/${prochaine.year}'),
          if (ovulation != null)
            _infoRow('🌸 Ovulation',
                '${ovulation.day}/${ovulation.month}/${ovulation.year}'),
          if (jours != null)
            _infoRow('⏳ Jours restants',
                jours >= 0 ? '$jours jours' : 'En cours'),
        ],
      ),
    );
  }
 
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFFB06080))),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3A1A28))),
        ],
      ),
    );
  }
 
  // ─── Bouton enregistrer ───────────────────────────────────
  Widget _buildSaveButton(CycleProvider cycleProvider) {
    return ElevatedButton(
      onPressed: cycleProvider.isLoading
          ? null
          : () => _saveCycle(cycleProvider),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC8698A),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFE8C5D5),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: cycleProvider.isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : const Text('Enregistrer',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }
 
  // ─── Action save ─────────────────────────────────────────
  Future<void> _saveCycle(CycleProvider cycleProvider) async {
    // Récupérer l'userId depuis le UserProvider
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.uid;
 
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non connecté'),
          backgroundColor: Color(0xFFA32D2D),
        ),
      );
      return;
    }
 
    final success = await cycleProvider.saveCycle(
      userId: userId,
      dureeCycle: _cycleDays,
      dureeRegles: _rulesDays,
      derniereRegles: _lastPeriod,
      modeGrossesse: _selectedMode == 1,
    );
 
    if (!mounted) return;
 
    if (success) {
      // Bannière verte s'affiche automatiquement via provider
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    }
    // Si erreur → bannière rouge via provider
  }
}