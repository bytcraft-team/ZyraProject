import 'package:flutter/material.dart';
import 'package:zyra/pregnancy/onboarding/onboarding_model.dart';
import 'package:zyra/pregnancy/onboarding/onboarding_service.dart';
import 'package:zyra/pregnancy/view/pregnancy_tracker_screen.dart';
import 'package:zyra/pregnancy/repositories/user_repository.dart';
import 'package:zyra/pregnancy/services/pregnancy_calculator.dart';
import 'package:zyra/cycle/views/onboarding/onboarding_screen.dart';

// ─── Thème couleurs ───────────────────────────────────────────────────────────
const _titleColor = Color(0xFFE91E8F);
const _accentColor = Color(0xFF9C27B0);
const _subColor = Color(0xFFC86CF3);
const _fillColor = Color(0xFFFFF5F8);
const _fillEnd = Color(0xFFF5E8FF);
const _arrowColor = Color(0xFFF4C0D1);
const _labelColor = Color(0xFF9C27B0);

// ─── Entrée principale ────────────────────────────────────────────────────────
class OnboardingEntryPage extends StatelessWidget {
  const OnboardingEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_fillColor, _fillEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Bienvenue sur Zyra',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [_titleColor, _accentColor],
                      ).createShader(const Rect.fromLTWH(0, 0, 220, 32)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre parcours vers un suivi serein de grossesse et de cycle commence ici.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _titleColor.withOpacity(0.78),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Color(0xFFFAEEFF)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26C86CF3),
                            blurRadius: 26,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [_titleColor, _accentColor],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.self_improvement,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Quel est votre but ?',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [_titleColor, _accentColor],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 260, 36),
                                ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Votre réponse nous permet de vous offrir l\'expérience la plus adaptée.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _titleColor.withOpacity(0.7),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ✅ OUI → questions grossesse
                          _LargeChoiceButton(
                            icon: Icons.pregnant_woman,
                            label: 'Suivi grossesse',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE91E8F), Color(0xFFC86CF3)],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PregnancyOnboardingFlow(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // ❌ NON → suivi de cycle
                          _LargeChoiceButton(
                            icon: Icons.calendar_month,
                            label: 'Suivi de cycle',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF06EC8), Color(0xFF9C27B0)],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OnboardingScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Onboarding doux et guidé par des experts.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _labelColor.withOpacity(0.85),
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
}

// ─── Flow grossesse uniquement (4 questions) ──────────────────────────────────
class PregnancyOnboardingFlow extends StatefulWidget {
  const PregnancyOnboardingFlow({super.key});

  @override
  State<PregnancyOnboardingFlow> createState() =>
      _PregnancyOnboardingFlowState();
}

class _PregnancyOnboardingFlowState extends State<PregnancyOnboardingFlow> {
  final _weekController = TextEditingController(text: '12');

  int _currentStep = 0;
  int _pregnancyWeek = 12;
  DateTime? _lmpDate;
  bool _firstPregnancy = false;
  bool _weeklyUpdates = true;
  bool _nutritionTips = true;

  static const int _totalSteps = 4;

  static const _titles = [
    'Quelle est votre semaine de grossesse actuelle ?',
    'Date de vos dernières règles (LMP) ?',
    'Est-ce votre première grossesse ?',
    'Souhaitez-vous des mises à jour hebdomadaires ?',
  ];

  static const _subtitles = [
    'Cela nous aide à personnaliser le suivi du développement de bébé.',
    'Une date LMP précise améliore la prédiction de votre date d\'accouchement.',
    'Nous pouvons personnaliser le soutien selon votre expérience.',
    'Des résumés hebdomadaires pour rester informée sans être submergée.',
  ];

  bool get _isStepValid {
    switch (_currentStep) {
      case 0:
        return _pregnancyWeek >= 1 && _pregnancyWeek <= 44;
      case 1:
        return _lmpDate != null;
      case 2:
        return true;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _titleColor,
            onPrimary: Colors.white,
            onSurface: _titleColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _lmpDate = picked);
  }

  Future<void> _finish() async {
    if (_lmpDate == null) return;

    // Calcule les données de suivi de grossesse
    final currentWeek = PregnancyCalculator.calculateCurrentWeek(_lmpDate!);
    final adjustedWeek = PregnancyCalculator.validateWeekNumber(currentWeek);
    final daysRemaining = PregnancyCalculator.calculateDaysRemaining(_lmpDate!);
    final expectedDeliveryDate =
        PregnancyCalculator.calculateExpectedDeliveryDate(_lmpDate!);
    final trimester = PregnancyCalculator.calculateTrimester(adjustedWeek);

    // Crée les données d'onboarding
    final data = OnboardingData(
      profileType: UserProfileType.pregnancy,
      pregnancyWeek: _pregnancyWeek,
      lastMenstrualPeriodDate: _lmpDate,
      firstPregnancy: _firstPregnancy,
      weeklyUpdates: _weeklyUpdates,
      nutritionTips: _nutritionTips,
      averageCycleLength: 28,
      periodDuration: 5,
      lastPeriodDate: null,
      cycleRegular: true,
      remindersEnabled: false,
    );

    try {
      // Sauvegarde les données d'onboarding
      final userRepo = UserRepository();
      await userRepo.saveOnboardingData(data);

      // Calcule et sauvegarde les données de suivi de grossesse
      // Sauvegarde UNIQUEMENT la date des dernières règles
      // Les semaines, jours restants, trimestre seront recalculés à chaque ouverture
      final trackingData = <String, dynamic>{
        'pregnancyStartDate': _lmpDate!.toIso8601String(),
        // NE PAS sauvegarder : currentWeek, daysRemaining, trimester
        // Ces valeurs sont recalculées dynamiquement
        'username': userRepo.currentUser?.displayName ?? '',
        'name': userRepo.currentUser?.displayName ?? '',
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await userRepo.savePregnancyTracking(trackingData);
    } catch (e) {
      debugPrint('Erreur Firestore onboarding grossesse : $e');
    }

    await OnboardingService.saveOnboardingData(data);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PregnancyHomePage()),
      (route) => false,
    );
  }

  void _next() {
    if (_currentStep == _totalSteps - 1) {
      _finish();
      return;
    }
    setState(() => _currentStep++);
  }

  void _back() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _currentStep--);
  }

  @override
  void dispose() {
    _weekController.dispose();
    super.dispose();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_fillColor, _fillEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar custom ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      color: _titleColor,
                      onPressed: _back,
                    ),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [_titleColor, _accentColor],
                        ).createShader(bounds),
                        child: Text(
                          'Suivi grossesse',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Indicateur de progression ──────────────────────────
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [_titleColor, _accentColor],
                        ).createShader(bounds),
                        child: Text(
                          'Étape ${_currentStep + 1} sur $_totalSteps',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            // Fond
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: _arrowColor,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            // Barre gradient
                            FractionallySizedBox(
                              widthFactor: (_currentStep + 1) / _totalSteps,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_titleColor, _subColor],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Contenu de l'étape ─────────────────────────────────
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.2, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: SingleChildScrollView(
                            key: ValueKey(_currentStep),
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [_titleColor, _accentColor],
                                  ).createShader(
                                    Rect.fromLTWH(
                                      0,
                                      0,
                                      bounds.width,
                                      bounds.height,
                                    ),
                                  ),
                                  child: Text(
                                    _titles[_currentStep],
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  _subtitles[_currentStep],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: _accentColor.withOpacity(0.75),
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 26),
                                Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: BorderSide(
                                      color: _subColor.withOpacity(0.25),
                                    ),
                                  ),
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(22),
                                    child: _buildInput(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Bouton Continuer ───────────────────────────────────
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: _isStepValid
                                ? const LinearGradient(
                                    colors: [_titleColor, _accentColor],
                                  )
                                : null,
                            color: _isStepValid ? null : _arrowColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ElevatedButton(
                            onPressed: _isStepValid ? _next : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              _currentStep == _totalSteps - 1
                                  ? 'Terminer et continuer'
                                  : 'Continuer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _isStepValid
                                    ? Colors.white
                                    : _labelColor.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Input selon l'étape ───────────────────────────────────────────────────
  Widget _buildInput() {
    switch (_currentStep) {
      // Semaine de grossesse
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [_titleColor, _accentColor],
              ).createShader(bounds),
              child: Text(
                'Semaine de grossesse',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _weekController,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  setState(() => _pregnancyWeek = int.tryParse(v) ?? 0),
              cursorColor: _titleColor,
              decoration: InputDecoration(
                suffixText: 'semaines',
                suffixStyle: const TextStyle(
                  color: _subColor,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: _fillEnd,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: _subColor, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: _subColor.withOpacity(0.3)),
                ),
                hintText: 'Entrez un nombre',
                hintStyle: TextStyle(color: _labelColor.withOpacity(0.4)),
              ),
            ),
          ],
        );

      // Date LMP
      case 1:
        return InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_fillColor, _fillEnd],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _subColor.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [_titleColor, _accentColor],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _lmpDate == null
                        ? 'Sélectionner la date LMP'
                        : 'Date LMP : ${_fmt(_lmpDate!)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _lmpDate == null
                              ? _labelColor.withOpacity(0.5)
                              : _accentColor,
                        ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [_titleColor, _accentColor],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );

      // Première grossesse
      case 2:
        return _ToggleGroup(
          options: const ['Oui', 'Non'],
          labels: const ['Première grossesse', 'Pas la première'],
          selectedIndex: _firstPregnancy ? 0 : 1,
          onSelected: (i) => setState(() => _firstPregnancy = i == 0),
        );

      // Mises à jour hebdomadaires
      case 3:
        return _ToggleGroup(
          options: const ['Oui', 'Non'],
          labels: const ['Mises à jour activées', 'Mises à jour désactivées'],
          selectedIndex: _weeklyUpdates ? 0 : 1,
          onSelected: (i) => setState(() => _weeklyUpdates = i == 0),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _fmt(DateTime d) {
    const m = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
  }
}

// ─── Widget toggle réutilisable ───────────────────────────────────────────────
class _ToggleGroup extends StatelessWidget {
  const _ToggleGroup({
    required this.options,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> options;
  final List<String> labels;
  final int selectedIndex;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(options.length, (i) {
        final sel = selectedIndex == i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            onTap: () => onSelected(i),
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              decoration: BoxDecoration(
                gradient: sel
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE91E8F), Color(0xFF9C27B0)],
                      )
                    : null,
                color: sel ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: sel ? _subColor : _arrowColor,
                  width: sel ? 1.5 : 1.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Icon(
                      sel ? Icons.check_circle : Icons.circle_outlined,
                      color: sel ? Colors.white : _subColor,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            options[i],
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: sel ? Colors.white : _titleColor,
                                    ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            labels[i],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: sel
                                      ? Colors.white.withOpacity(0.8)
                                      : _labelColor.withOpacity(0.75),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Bouton choix principal ───────────────────────────────────────────────────
class _LargeChoiceButton extends StatelessWidget {
  const _LargeChoiceButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            height: 72,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: Colors.purple),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.purpleAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
