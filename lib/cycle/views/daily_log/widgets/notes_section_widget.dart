import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/daily_log_model.dart';
import '_section_card.dart';

class NotesSectionWidget extends StatefulWidget {
  final String initialNotes;
  final List<NoteMedia> medias;
  final Function(String) onNotesChanged;
  final VoidCallback onAddImage;
  final VoidCallback onAddAudio;
  final Function(int) onRemoveMedia;

  const NotesSectionWidget({
    super.key,
    required this.initialNotes,
    required this.medias,
    required this.onNotesChanged,
    required this.onAddImage,
    required this.onAddAudio,
    required this.onRemoveMedia,
  });

  @override
  State<NotesSectionWidget> createState() => _NotesSectionWidgetState();
}

class _NotesSectionWidgetState extends State<NotesSectionWidget> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Notes personnelles',
      icon: Icons.edit_note_rounded,
      iconColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ texte
          TextField(
            controller: _ctrl,
            maxLines: 4,
            onChanged: widget.onNotesChanged,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Comment tu te sens aujourd\'hui ?',
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
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: const BorderSide(color: AppColors.pink, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(AppDimensions.md),
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Barre d'outils
          Row(
            children: [
              _ToolbarButton(
                icon: Icons.text_snippet_outlined,
                label: 'Texte',
                onTap: () => _ctrl.text += ' ',
              ),
              const SizedBox(width: AppDimensions.sm),
              _ToolbarButton(
                icon: Icons.photo_library_outlined,
                label: 'Photo',
                onTap: widget.onAddImage,
              ),
              const SizedBox(width: AppDimensions.sm),
              _ToolbarButton(
                icon: Icons.mic_outlined,
                label: 'Audio',
                onTap: widget.onAddAudio,
              ),
            ],
          ),

          // Miniatures médias
          if (widget.medias.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.sm),
            _MediaThumbnails(
              medias: widget.medias,
              onRemove: widget.onRemoveMedia,
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.pinkSoft,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.pink),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.pink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaThumbnails extends StatelessWidget {
  final List<NoteMedia> medias;
  final Function(int) onRemove;

  const _MediaThumbnails({required this.medias, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: medias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final media = medias[i];
          return _MediaThumb(
            media: media,
            onRemove: () => onRemove(i),
          );
        },
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  final NoteMedia media;
  final VoidCallback onRemove;

  const _MediaThumb({required this.media, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.purpleSoft,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Center(
            child: Icon(
              media.type == NoteMediaType.image
                  ? Icons.image_rounded
                  : Icons.mic_rounded,
              color: AppColors.purple,
              size: 28,
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}