import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/daily_log_model.dart';
import '../../../viewmodels/daily_log_viewmodel.dart';

class JournalHistorySection extends StatelessWidget {
  final DailyLogViewModel viewModel;

  const JournalHistorySection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final selectedDate = viewModel.selectedDate;
    final journal = viewModel.getJournalByDate(selectedDate);
    final formattedDate = _formatDate(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Journal du jour',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.xs),
                            Text(
                              'Résumé du journal sélectionné',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pinkSoft,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(
                          journal != null ? 'Enregistré' : 'Aucun journal',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.pink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  if (journal == null) ...[
                    Text(
                      'Aucun journal n’est disponible pour cette date. Vous pouvez entrer les informations du jour et enregistrer pour en créer un.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ] else ...[
                    _SummaryRow(
                      label: 'Flux',
                      value: journal.flowIntensity?.label ?? 'Aucun',
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    _SummaryRow(
                      label: 'Symptômes',
                      value: journal.symptoms.isNotEmpty
                          ? journal.symptoms.map((s) => '${s.type.label} (${s.intensity})').join(', ')
                          : 'Aucun',
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    _SummaryRow(
                      label: 'Humeur',
                      value: journal.moods.isNotEmpty
                          ? journal.moods.map((m) => m.label).join(', ')
                          : 'Aucune',
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    _SummaryRow(
                      label: 'Mucus cervical',
                      value: journal.cervicalMucus?.label ?? 'Aucun',
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    _SummaryRow(
                      label: 'Notes',
                      value: journal.notes.isNotEmpty
                          ? journal.notes.join(' • ')
                          : 'Aucune',
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: viewModel.deleteCurrentLog,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error),
                              foregroundColor: AppColors.error,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Supprimer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = [
      '', 'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${days[date.weekday]} ${date.day} ${months[date.month]} ${date.year}';
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
