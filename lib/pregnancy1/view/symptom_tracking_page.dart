import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zyra/pregnancy1/repositories/user_repository.dart';
import 'package:zyra/pregnancy1/viewmodels/pregnancy_view_model.dart';
import 'package:zyra/pregnancy1/view/shared_navigation.dart';
import 'package:zyra/paramettres/services/local_notification_service.dart';



// ══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ══════════════════════════════════════════════════════════════════════════════
abstract class _C {
  // Brand
  static const primary = Color(0xFFD4639A); // rose profond
  static const secondary = Color(0xFF9B80CF); // lavande
  static const tertiary = Color(0xFF7BB8CF); // sky bleu doux

  // Surfaces
  static const bg = Color(0xFFF9F7FE);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVar = Color(0xFFF4F0FC);

  // Text
  static const onSurface = Color(0xFF1E1433);
  static const onSurfaceMid = Color(0xFF6B4F7A);
  static const onSurfaceLow = Color(0xFFAA98BC);

  // Symptom accents (muted, sophisticated)
  static const sNausea = Color(0xFF9B80CF);
  static const sFatigue = Color(0xFFCF80A8);
  static const sHeadache = Color(0xFFCF8080);
  static const sBack = Color(0xFF80A8CF);
  static const sCramps = Color(0xFFCFAF80);
  static const sMood = Color(0xFFAF80CF);
  static const sSleep = Color(0xFF80A0CF);
  static const sAppetite = Color(0xFFCF8898);
  static const sMovements = Color(0xFF80CFAA);

  // Bg tints (very light)
  static const bNausea = Color(0xFFF3F0FF);
  static const bFatigue = Color(0xFFFFF0F6);
  static const bHeadache = Color(0xFFFFF0F0);
  static const bBack = Color(0xFFF0F6FF);
  static const bCramps = Color(0xFFFFF8F0);
  static const bMood = Color(0xFFF8F0FF);
  static const bSleep = Color(0xFFF0F4FF);
  static const bAppetite = Color(0xFFFFF0F3);
  static const bMovements = Color(0xFFF0FFF8);

  // Intensity
  static const iLow = Color(0xFF80CFAA);
  static const iMid = Color.fromARGB(255, 227, 210, 183);
  static const iHigh = Color(0xFFCF8080);
}

// ══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════════════════════════════
class _SymptomData {
  final String id;
  final String label;
  final String sublabel;
  final IconData icon;
  final Color accent;
  final Color bg;
  double intensity = 0.4;
  bool selected = false;

  _SymptomData({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.accent,
    required this.bg,
  });
}

class _MoodData {
  final IconData icon;
  final String label;
  final Color color;
  const _MoodData(this.icon, this.label, this.color);
}

// ══════════════════════════════════════════════════════════════════════════════
// PAGE
// ══════════════════════════════════════════════════════════════════════════════
class SymptomTrackingPage extends StatefulWidget {
  const SymptomTrackingPage({super.key});
  @override
  State<SymptomTrackingPage> createState() => _SymptomTrackingPageState();
}

class _SymptomTrackingPageState extends State<SymptomTrackingPage>
    with TickerProviderStateMixin {
  // ── Nav
  final int _selectedIndex = 3;
  void _onItemTapped(int i) {
    if (i != _selectedIndex) navigateToPage(context, i);
  }

  // ── Controllers
  final _notes = TextEditingController();
  final UserRepository _userRepository = UserRepository();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── State
  int _selectedMood = 2;
  bool _isSaving = false;

  // ── Moods (icon-based, no emojis)
  static const _moods = [
    _MoodData(
      Icons.sentiment_very_dissatisfied_rounded,
      'Difficile',
      Color(0xFFCF8080),
    ),
    _MoodData(
      Icons.sentiment_dissatisfied_rounded,
      'Fatigué',
      Color(0xFFCFAF80),
    ),
    _MoodData(Icons.sentiment_neutral_rounded, 'Neutre', Color(0xFF9B80CF)),
    _MoodData(Icons.sentiment_satisfied_rounded, 'Bien', Color(0xFF80A8CF)),
    _MoodData(
      Icons.sentiment_very_satisfied_rounded,
      'Radieuse',
      Color(0xFF80CFAA),
    ),
  ];

  // ── Symptoms
  final List<_SymptomData> _symptoms = [
    _SymptomData(
      id: 'nausea',
      label: 'Nausées',
      sublabel: 'Inconfort digestif',
      icon: Icons.sick_rounded,
      accent: _C.sNausea,
      bg: _C.bNausea,
    ),
    _SymptomData(
      id: 'fatigue',
      label: 'Fatigue',
      sublabel: 'Manque d\'énergie',
      icon: Icons.battery_3_bar_rounded,
      accent: _C.sFatigue,
      bg: _C.bFatigue,
    ),
    _SymptomData(
      id: 'headache',
      label: 'Maux de tête',
      sublabel: 'Céphalées, migraines',
      icon: Icons.psychology_rounded,
      accent: _C.sHeadache,
      bg: _C.bHeadache,
    ),
    _SymptomData(
      id: 'back',
      label: 'Douleurs dos',
      sublabel: 'Lombaires, tensions',
      icon: Icons.accessibility_new_rounded,
      accent: _C.sBack,
      bg: _C.bBack,
    ),
    _SymptomData(
      id: 'cramps',
      label: 'Crampes',
      sublabel: 'Contractions légères',
      icon: Icons.electric_bolt_rounded,
      accent: _C.sCramps,
      bg: _C.bCramps,
    ),
    _SymptomData(
      id: 'mood',
      label: 'Humeur',
      sublabel: 'Émotions, irritabilité',
      icon: Icons.mood_rounded,
      accent: _C.sMood,
      bg: _C.bMood,
    ),
    _SymptomData(
      id: 'sleep',
      label: 'Sommeil',
      sublabel: 'Qualité du repos',
      icon: Icons.bedtime_rounded,
      accent: _C.sSleep,
      bg: _C.bSleep,
    ),
    _SymptomData(
      id: 'appetite',
      label: 'Appétit',
      sublabel: 'Envies, fringales',
      icon: Icons.restaurant_rounded,
      accent: _C.sAppetite,
      bg: _C.bAppetite,
    ),
    _SymptomData(
      id: 'movements',
      label: 'Mouvements bébé',
      sublabel: 'Coups, activité',
      icon: Icons.child_friendly_rounded,
      accent: _C.sMovements,
      bg: _C.bMovements,
    ),
  ];

  // ── Lifecycle
  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadSavedSymptomsForToday();
  }

  Future<void> _loadSavedSymptomsForToday() async {
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    final saved = await _userRepository.loadPregnancySymptomsForDate(todayKey);
    if (!mounted || saved == null) return;

    final savedSymptoms = (saved['symptoms'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    setState(() {
      for (final symptom in _symptoms) {
        Map<String, dynamic>? entry;
        for (final item in savedSymptoms) {
          if (item['id'] == symptom.id) {
            entry = item;
            break;
          }
        }
        if (entry != null) {
          symptom.selected = true;
          symptom.intensity = ((entry['intensity'] as num?) ?? 1) / 5.0;
        }
      }
      _selectedMood = (saved['moodIndex'] as int?) ?? _selectedMood;
      _notes.text = (saved['notes'] as String?) ?? '';
    });
  }

  @override
  void dispose() {
    _notes.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Save
  Future<void> _save() async {
    if (_isSaving) return;
    HapticFeedback.mediumImpact();

    final tracking = context.read<PregnancyViewModel>().pregnancyTracking;
    final selectedSymptoms = _symptoms
        .where((symptom) => symptom.selected)
        .map(
          (symptom) => {
            'id': symptom.id,
            'label': symptom.label,
            'intensity': (symptom.intensity * 5).round().clamp(1, 5),
          },
        )
        .toList();

    if (selectedSymptoms.isEmpty && _notes.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ajoute au moins un symptôme ou une note avant d’enregistrer.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await LocalNotificationService.show(
        title: 'Bilan enregistré ! ✨',
        body: 'Vos symptômes d\'aujourd\'hui ont été sauvegardés avec succès.',
      );
      final dateKey = DateTime.now().toIso8601String().split('T').first;
      await _userRepository.savePregnancySymptoms(
        dateKey: dateKey,
        weekNumber: tracking?.currentWeek ?? 1,
        moodIndex: _selectedMood,
        notes: _notes.text,
        symptoms: selectedSymptoms,
        expectedDeliveryDate:
            tracking?.expectedDeliveryDate ??
            DateTime.now().add(const Duration(days: 280)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enregistrement impossible: $e')));
      setState(() => _isSaving = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1433),
        elevation: 0,
        content: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _C.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: _C.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bilan enregistré',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Prends soin de toi aujourd\'hui',
                    style: TextStyle(color: Color(0xFFAA98BC), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  

  // ══════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGreetingCard(),
                    const SizedBox(height: 16),
                    _buildMoodCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(),
                    const SizedBox(height: 12),
                    _buildEmptyState(),
                    ..._buildSymptomCards(),
                    const SizedBox(height: 24),
                    _buildNotesCard(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // HEADER — original code preserved exactly
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return ClipPath(
      clipper: _HeaderWaveClipper(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 120, 113, 220),
              Color.fromARGB(255, 202, 134, 224),
              Color.fromARGB(255, 227, 67, 134),
            ],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 44),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Suivi des symptômes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // BODY SECTIONS
  // ══════════════════════════════════════════════════════════════════════════════

  // ── Greeting ──────────────────────────────────────────────────────────────────
  Widget _buildGreetingCard() {
    final tracking = Provider.of<PregnancyViewModel>(
      context,
      listen: false,
    ).pregnancyTracking;
    return _PremiumCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _C.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: _C.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _todayStr(),
                            style: TextStyle(
                              color: _C.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Comment tu te\nsens aujourd\'hui ?',
                  style: TextStyle(
                    color: _C.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Note tes sensations avec douceur',
                  style: TextStyle(
                    color: _C.onSurfaceLow,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                // Pregnant week and remaining days based on real tracking data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.pregnant_woman_rounded,
                          size: 14,
                          color: _C.secondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          tracking?.weekDisplay ?? 'Semaine non définie',
                          style: const TextStyle(
                            color: _C.onSurfaceMid,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: tracking != null
                        ? (tracking.currentWeek / 40).clamp(0.0, 1.0)
                        : 0.55,
                    minHeight: 6,
                    backgroundColor: _C.surfaceVar,
                    valueColor: const AlwaysStoppedAnimation(_C.secondary),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tracking != null
                      ? 'Trimestre ${tracking.trimester} • DDP ${_formatDate(tracking.expectedDeliveryDate)}'
                      : 'Données de grossesse indisponibles',
                  style: const TextStyle(
                    color: _C.onSurfaceLow,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Decorative side illustration
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _C.primary.withOpacity(0.12),
                      _C.secondary.withOpacity(0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.pregnant_woman_rounded,
                  color: _C.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 64,
                height: 36,
                decoration: BoxDecoration(
                  color: _C.surfaceVar,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_rounded, size: 14, color: _C.primary),
                    const SizedBox(width: 4),
                    const Text(
                      'Zyra',
                      style: TextStyle(
                        color: _C.onSurfaceMid,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mood Selector ─────────────────────────────────────────────────────────────
  Widget _buildMoodCard() {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.auto_awesome_rounded,
            label: 'Humeur du moment',
            iconColor: _C.secondary,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_moods.length, (i) {
              final m = _moods[i];
              final active = _selectedMood == i;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedMood = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutBack,
                  width: active ? 60 : 50,
                  height: active ? 60 : 50,
                  decoration: BoxDecoration(
                    color: active ? m.color.withOpacity(0.12) : _C.surfaceVar,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? m.color : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: m.color.withOpacity(0.25),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    m.icon,
                    color: active ? m.color : _C.onSurfaceLow,
                    size: active ? 30 : 24,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Container(
                key: ValueKey(_selectedMood),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _moods[_selectedMood].color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _moods[_selectedMood].label,
                  style: TextStyle(
                    color: _moods[_selectedMood].color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    final count = _symptoms.where((s) => s.selected).length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Symptômes du jour',
                style: TextStyle(
                  color: _C.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Appuie pour activer · glisse pour l\'intensité',
                style: TextStyle(color: _C.onSurfaceLow, fontSize: 11.5),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: count > 0 ? _C.secondary.withOpacity(0.12) : _C.surfaceVar,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 13,
                color: count > 0 ? _C.secondary : _C.onSurfaceLow,
              ),
              const SizedBox(width: 5),
              Text(
                count > 0
                    ? '$count sélectionné${count > 1 ? 's' : ''}'
                    : 'Aucun',
                style: TextStyle(
                  color: count > 0 ? _C.secondary : _C.onSurfaceLow,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final hasSelected = _symptoms.any((s) => s.selected);
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: hasSelected
          ? const SizedBox.shrink()
          : Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _C.primary.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _C.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: _C.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Active un ou plusieurs symptômes pour commencer ton suivi quotidien',
                      style: TextStyle(
                        color: _C.onSurfaceMid,
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Symptom cards ──────────────────────────────────────────────────────────────
  List<Widget> _buildSymptomCards() {
    return List.generate(_symptoms.length, (i) {
      final s = _symptoms[i];
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 350 + i * 45),
        curve: Curves.easeOutCubic,
        builder: (ctx, v, child) => Opacity(
          opacity: v.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - v)),
            child: child,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SymptomCard(
            symptom: s,
            onToggle: () {
              HapticFeedback.selectionClick();
              setState(() => s.selected = !s.selected);
            },
            onIntensityChanged: (v) => setState(() => s.intensity = v),
          ),
        ),
      );
    });
  }

  // ── Notes ──────────────────────────────────────────────────────────────────────
  Widget _buildNotesCard() {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.edit_note_rounded,
            label: 'Notes personnelles',
            iconColor: _C.tertiary,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notes,
            maxLines: 4,
            style: const TextStyle(
              color: _C.onSurface,
              fontSize: 14,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText:
                  'Décris tes ressentis, ce qui t\'a aidée, ou ce à partager avec ton médecin…',
              hintStyle: const TextStyle(
                color: _C.onSurfaceLow,
                fontSize: 13.5,
                height: 1.6,
              ),
              filled: true,
              fillColor: _C.surfaceVar,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _C.secondary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  // ── Save button ────────────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        gradient: _isSaving
            ? null
            : const LinearGradient(
                colors: [Color(0xFFD4639A), Color(0xFF9B80CF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: _isSaving ? _C.surfaceVar : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _isSaving
            ? null
            : [
                BoxShadow(
                  color: _C.primary.withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: _save,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withOpacity(0.15),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isSaving
                  ? Row(
                      key: const ValueKey('loading'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              _C.secondary.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Enregistrement…',
                          style: TextStyle(
                            color: _C.onSurfaceMid,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      key: const ValueKey('save'),
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Enregistrer mon bilan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers
  String _todayStr() {
    final n = DateTime.now();
    const m = [
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sep',
      'oct',
      'nov',
      'déc',
    ];
    return '${n.day} ${m[n.month - 1]}. ${n.year}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'janv',
      'fév',
      'mars',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sept',
      'oct',
      'nov',
      'déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SYMPTOM CARD
// ══════════════════════════════════════════════════════════════════════════════
class _SymptomCard extends StatelessWidget {
  final _SymptomData symptom;
  final VoidCallback onToggle;
  final ValueChanged<double> onIntensityChanged;

  const _SymptomCard({
    required this.symptom,
    required this.onToggle,
    required this.onIntensityChanged,
  });

  String get _intensityLabel {
    if (symptom.intensity < 0.34) return 'Léger';
    if (symptom.intensity < 0.67) return 'Modéré';
    return 'Intense';
  }

  Color get _intensityColor {
    if (symptom.intensity < 0.34) return _C.iLow;
    if (symptom.intensity < 0.67) return _C.iMid;
    return _C.iHigh;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: symptom.selected ? symptom.bg : _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: symptom.selected
                ? symptom.accent.withOpacity(0.3)
                : const Color(0xFFF0ECFF),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: symptom.selected
                  ? symptom.accent.withOpacity(0.1)
                  : const Color(0x089B85D4),
              blurRadius: symptom.selected ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: symptom.selected
                        ? symptom.accent.withOpacity(0.15)
                        : _C.surfaceVar,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    symptom.icon,
                    color: symptom.selected ? symptom.accent : _C.onSurfaceLow,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symptom.label,
                        style: TextStyle(
                          color: symptom.selected
                              ? _C.onSurface
                              : _C.onSurfaceMid,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      symptom.selected
                          ? Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _intensityColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _intensityLabel,
                                    style: TextStyle(
                                      color: _intensityColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              symptom.sublabel,
                              style: const TextStyle(
                                color: _C.onSurfaceLow,
                                fontSize: 12,
                              ),
                            ),
                    ],
                  ),
                ),
                // Toggle button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: symptom.selected ? symptom.accent : _C.surfaceVar,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: symptom.selected
                        ? [
                            BoxShadow(
                              color: symptom.accent.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    symptom.selected ? Icons.check_rounded : Icons.add_rounded,
                    color: symptom.selected ? Colors.white : _C.onSurfaceLow,
                    size: 16,
                  ),
                ),
              ],
            ),

            // Intensity slider — animated reveal
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              child: symptom.selected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          // Divider line
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  symptom.accent.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 13,
                                color: _C.onSurfaceLow,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Intensité',
                                style: TextStyle(
                                  color: _C.onSurfaceLow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              // Segment bar (5 dots)
                              Row(
                                children: List.generate(5, (i) {
                                  final filled = (symptom.intensity * 5)
                                      .round();
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: i < filled ? 16 : 8,
                                    height: 6,
                                    margin: const EdgeInsets.only(left: 3),
                                    decoration: BoxDecoration(
                                      color: i < filled
                                          ? symptom.accent
                                          : symptom.accent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: symptom.accent,
                              inactiveTrackColor: symptom.accent.withOpacity(
                                0.12,
                              ),
                              thumbColor: symptom.accent,
                              overlayColor: symptom.accent.withOpacity(0.1),
                            ),
                            child: Material(
                              type: MaterialType.transparency,
                              child: Slider(
                                value: symptom.intensity,
                                onChanged: onIntensityChanged,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C9B80CF),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _CardHeader({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: _C.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ORIGINAL HEADER CLIPPER — preserved exactly
// ══════════════════════════════════════════════════════════════════════════════
class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height - 30,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
