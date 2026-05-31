import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/daily_log_model.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../../viewmodels/daily_log_viewmodel.dart';
import 'widgets/flow_intensity_widget.dart';
import 'widgets/symptoms_grid_widget.dart';
import 'widgets/mood_selector_widget.dart';
import 'widgets/temperature_input_widget.dart';
import 'widgets/cervical_mucus_widget.dart';
import 'widgets/notes_section_widget.dart';
import 'widgets/save_button_widget.dart';

class DailyLogBottomSheet extends StatelessWidget {
  final DateTime date;
  final VoidCallback? onSaved;

  const DailyLogBottomSheet({
    super.key,
    required this.date,
    this.onSaved,
  });

  // ── Ouverture ─────────────────────────────────────────────────
  static Future<void> show({
    required BuildContext context,
    required DateTime date,
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,     // ✅ obligatoire pour clavier
      backgroundColor: Colors.transparent,
      enableDrag: true,
      useSafeArea: false,           // on gère SafeArea manuellement
      builder: (ctx) => ChangeNotifierProvider(
        create: (_) => DailyLogViewModel(
          repository: DailyLogRepositoryImpl(),
        ),
        child: DailyLogBottomSheet(date: date, onSaved: onSaved),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DailyLogSheetBody(date: date, onSaved: onSaved);
  }
}

// ─────────────────────────────────────────────────────────────
// Corps principal
// ─────────────────────────────────────────────────────────────
class _DailyLogSheetBody extends StatefulWidget {
  final DateTime date;
  final VoidCallback? onSaved;

  const _DailyLogSheetBody({required this.date, this.onSaved});

  @override
  State<_DailyLogSheetBody> createState() => _DailyLogSheetBodyState();
}

class _DailyLogSheetBodyState extends State<_DailyLogSheetBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyLogViewModel>().initWithDate(widget.date);
    });
  }

  Future<void> _onSave() async {
    final vm = context.read<DailyLogViewModel>();
    final ok = await vm.saveLog();
    if (ok && mounted) {
      // Attendre l'animation de succès
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.of(context).pop(); // ferme DailyLogBottomSheet
        widget.onSaved?.call();      // callback vers DayDetail
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Dimensions responsives ──────────────────────────────────
    final screenH      = MediaQuery.of(context).size.height;
    final keyboardH    = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafeH  = MediaQuery.of(context).padding.bottom;
    final topSafeH     = MediaQuery.of(context).padding.top;

    // Hauteur du sheet : 90% de l'écran max, ajustée pour le clavier
    final sheetH = (screenH * 0.92).clamp(500.0, screenH - topSafeH);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: sheetH + keyboardH,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // ── Handle ──────────────────────────────────────
            const _SheetHandle(),

            // ── Header ──────────────────────────────────────
            _SheetHeader(date: widget.date),

            // ── Contenu scrollable ───────────────────────────
            Expanded(
              child: Consumer<DailyLogViewModel>(
                builder: (_, vm, __) {
                  if (vm.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.pink),
                      ),
                    );
                  }
                  return _LogForm(
                    vm: vm,
                    onSave: _onSave,
                    bottomPad: bottomSafeH + keyboardH,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Handle
// ─────────────────────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Header du sheet
// ─────────────────────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  final DateTime date;
  const _SheetHeader({required this.date});

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final isToday = d.day == now.day &&
        d.month == now.month &&
        d.year == now.year;
    if (isToday) return "Aujourd'hui";

    const days = [
      '', 'Lundi', 'Mardi', 'Mercredi',
      'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
    ];
    const months = [
      '', 'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${days[d.weekday]} ${d.day} ${months[d.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.pinkSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: AppColors.pink,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Textes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Journal du jour',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pink,
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Bouton fermer
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Formulaire scrollable
// ─────────────────────────────────────────────────────────────
class _LogForm extends StatelessWidget {
  final DailyLogViewModel vm;
  final VoidCallback onSave;
  final double bottomPad;

  const _LogForm({
    required this.vm,
    required this.onSave,
    required this.bottomPad,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: bottomPad + AppDimensions.md,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.sm),

          // 1. Flux
          FlowIntensityWidget(
            selected: vm.flowIntensity,
            onSelect: vm.selectFlow,
          ),
          const SizedBox(height: 8),

          // 2. Symptômes
          SymptomsGridWidget(
            symptoms: vm.visibleSymptoms,
            isSelected: vm.isSymptomSelected,
            getIntensity: vm.symptomIntensity,
            onToggle: vm.toggleSymptom,
            onIntensityChange: vm.setSymptomIntensity,
            showAll: vm.showAllSymptoms,
            onToggleShowAll: vm.toggleShowAllSymptoms,
          ),
          const SizedBox(height: 8),

          // 3. Humeur
          MoodSelectorWidget(
            selectedMoods: vm.moods,
            onToggle: vm.toggleMood,
          ),
          const SizedBox(height: 8),

          // 4. Température
          TemperatureInputWidget(
            temperature: vm.basalTemperature,
            showWarning: vm.hasTemperatureWarning,
            warningMessage: vm.temperatureWarningMessage,
            onIncrease: vm.increaseTemperature,
            onDecrease: vm.decreaseTemperature,
          ),
          const SizedBox(height: 8),

          // 5. Mucus
          CervicalMucusWidget(
            selected: vm.cervicalMucus,
            onSelect: vm.selectCervicalMucus,
          ),
          const SizedBox(height: 8),

          // 6. Notes
          NotesSectionWidget(
            initialNotes: vm.notes,
            medias: vm.medias,
            onNotesChanged: vm.updateNotes,
            onAddImage: () => vm.addMedia(
              const NoteMedia(
                type: NoteMediaType.image,
                path: '/mock/image.jpg',
              ),
            ),
            onAddAudio: () => vm.addMedia(
              const NoteMedia(
                type: NoteMediaType.audio,
                path: '/mock/audio.mp3',
                audioDuration: Duration(seconds: 12),
              ),
            ),
            onRemoveMedia: vm.removeMedia,
          ),
          const SizedBox(height: 8),

          // 7. Bouton Save
          SaveButtonWidget(
            saveState: vm.saveState,
            onSave: onSave,
          ),
        ],
      ),
    );
  }
}