import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/daily_log_model.dart';
import '../../viewmodels/daily_log_viewmodel.dart';
import 'widgets/date_strip_widget.dart';
import 'widgets/flow_intensity_widget.dart';
import 'widgets/symptoms_grid_widget.dart';
import 'widgets/mood_selector_widget.dart';
import 'widgets/temperature_input_widget.dart';
import 'widgets/cervical_mucus_widget.dart';
import 'widgets/notes_section_widget.dart';
import 'widgets/save_button_widget.dart';

class DailyLogScreen extends StatelessWidget {
  const DailyLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyLogViewModel>(
        builder: (context, vm, _) {
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────
                _LogHeader(date: vm.selectedDate),

                // ── Date strip ──────────────────────────────────
                DateStripWidget(
                  days: vm.weekDays,
                  selectedDate: vm.selectedDate,
                  onDateSelected: vm.selectDate,
                  hasData: vm.hasDataForDay,
                ),

                const SizedBox(height: AppDimensions.sm),

                // ── Corps ────────────────────────────────────────
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(AppColors.pink),
                          ),
                        )
                      : _LogBody(vm: vm),
                ),
              ],
            ),
          );
        },
      
    );
  }
}

// ── Header ─────────────────────────────────────────────────────
class _LogHeader extends StatelessWidget {
  final DateTime date;
  const _LogHeader({required this.date});

  String _label(DateTime d) {
    final n = DateTime.now();
    if (d.day == n.day && d.month == n.month && d.year == n.year) {
      return "Aujourd'hui";
    }
    const j = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const m = [
      '', 'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${j[d.weekday]} ${d.day} ${m[d.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Journal quotidien',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.pink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _label(date),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Body scrollable ────────────────────────────────────────────
class _LogBody extends StatelessWidget {
  final DailyLogViewModel vm;
  const _LogBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          FlowIntensityWidget(
            selected: vm.flowIntensity,
            onSelect: vm.selectFlow,
          ),
          const SizedBox(height: 8),
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
          MoodSelectorWidget(
            selectedMoods: vm.moods,
            onToggle: vm.toggleMood,
          ),
          const SizedBox(height: 8),
          TemperatureInputWidget(
            temperature: vm.basalTemperature,
            showWarning: vm.hasTemperatureWarning,
            warningMessage: vm.temperatureWarningMessage,
            onIncrease: vm.increaseTemperature,
            onDecrease: vm.decreaseTemperature,
          ),
          const SizedBox(height: 8),
          CervicalMucusWidget(
            selected: vm.cervicalMucus,
            onSelect: vm.selectCervicalMucus,
          ),
          const SizedBox(height: 8),
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
          SaveButtonWidget(
            saveState: vm.saveState,
            onSave: vm.saveLog, // ✅ pas de Navigator.pop()
          ),
        ],
      ),
    );
  }
}