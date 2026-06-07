import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '_section_card.dart';

/// SIMPLE Notes Section (NO CRUD - ONE NOTE PER DAY ONLY)
class NotesSectionWidget extends StatefulWidget {
  final String? note;
  final ValueChanged<String> onNoteChanged;

  const NotesSectionWidget({
    super.key,
    required this.note,
    required this.onNoteChanged,
  });

  @override
  State<NotesSectionWidget> createState() => _NotesSectionWidgetState();
}

class _NotesSectionWidgetState extends State<NotesSectionWidget> {
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.note ?? '');
  }

  @override
  void didUpdateWidget(covariant NotesSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.note != widget.note) {
      _inputController.text = widget.note ?? '';
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasNote = widget.note != null && widget.note!.trim().isNotEmpty;

    return SectionCard(
      title: 'Notes personnelles',
      icon: Icons.edit_note_rounded,
      iconColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// INPUT
          TextField(
            controller: _inputController,
            maxLines: 4,
            onChanged: widget.onNoteChanged,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hasNote
                  ? 'Modifier votre note...'
                  : 'Entrez votre note personnelle...',
              hintStyle: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: const BorderSide(color: AppColors.pink),
              ),
              contentPadding: const EdgeInsets.all(AppDimensions.md),
            ),
          ),

          const SizedBox(height: AppDimensions.sm),

          /// STATUS ONLY
          
        ],
      ),
    );
  }
}