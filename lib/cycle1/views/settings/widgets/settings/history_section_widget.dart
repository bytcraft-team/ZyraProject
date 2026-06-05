import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/settings_model.dart';
import '../../../../viewmodels/settings_viewmodel.dart';
import '../shared_widgets.dart';

class HistorySectionWidget extends StatelessWidget {
  final SettingsViewModel vm;

  const HistorySectionWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final history = vm.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          icon: Icons.history_rounded,
          title: 'Historique des cycles',
        ),
        const SizedBox(height: AppDimensions.sm),

        if (history.isEmpty)
          const _EmptyHistory()
        else
          ...history.map((entry) => _HistoryCard(
                entry: entry,
                onDelete: () => _confirmDelete(context, entry, vm),
                onEdit: () => _showEditDialog(context, entry, vm),
              )),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    CycleHistoryEntry entry,
    SettingsViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: const Text(
          'Supprimer ce cycle ?',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Cette action est irréversible.',
          style: TextStyle(fontFamily: AppTextStyles.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              vm.deleteHistoryEntry(entry.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    CycleHistoryEntry entry,
    SettingsViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (_) => _EditHistoryDialog(
        entry: entry,
        onSave: (updated) {
          vm.updateHistoryEntry(updated);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CycleHistoryEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _HistoryCard({
    required this.entry,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Vérification de l'état de régularité pour adapter la couleur du badge
    final bool isStrictlyRegular = entry.regularity == 'Régulier';

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // Gestion manuelle par boîte de dialogue
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha((0.1 * 255).round()),
          borderRadius:
              BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.04 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône calendrier
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.pinkSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  color: AppColors.pink, size: 20),
            ),
            const SizedBox(width: 12),

            // Contenu textuel et badges d'information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.startLabel} → ${entry.endLabel}',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (entry.duration != null)
                        _InfoChip(
                          label: '${entry.duration} jours',
                          color: AppColors.purple,
                        ),
                      const SizedBox(width: 6),
                      _InfoChip(
                        label: entry.regularity, // Utilisation de la nouvelle String textuelle
                        color: isStrictlyRegular
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bouton Édition
            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded,
                    size: 16, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            Text('📭', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text(
              'Aucun cycle enregistré',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditHistoryDialog extends StatefulWidget {
  final CycleHistoryEntry entry;
  final Function(CycleHistoryEntry) onSave;

  const _EditHistoryDialog({
    required this.entry,
    required this.onSave,
  });

  @override
  State<_EditHistoryDialog> createState() => _EditHistoryDialogState();
}

class _EditHistoryDialogState extends State<_EditHistoryDialog> {
  late int _duration;
  late String _regularity;

  // Liste des choix possibles basés sur l'extension du modèle
  final List<String> _regularityOptions = [
    'Régulier',
    'Légèrement irrégulier',
    'Très irrégulier'
  ];

  @override
  void initState() {
    super.initState();
    _duration = widget.entry.duration ?? 28;
    
    // Protection contre d'anciennes données ou des chaînes non reconnues
    if (_regularityOptions.contains(widget.entry.regularity)) {
      _regularity = widget.entry.regularity;
    } else {
      _regularity = 'Régulier';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      title: const Text(
        'Modifier ce cycle',
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Réglage de la durée du cycle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Durée (jours)'),
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        setState(() => _duration = (_duration - 1).clamp(15, 45)),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_duration',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pink,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _duration = (_duration + 1).clamp(15, 45)),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          
          // Sélection textuelle précise de la régularité
          const Text('Régularité du cycle', 
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _regularity,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: _regularityOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() => _regularity = newValue);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => widget.onSave(
            widget.entry.copyWith(
              duration: _duration,
              regularity: _regularity, // Sauvegarde de la chaîne textuelle
            ),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink),
          child: const Text('Sauvegarder', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}