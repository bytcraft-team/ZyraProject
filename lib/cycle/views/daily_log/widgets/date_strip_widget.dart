import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class DateStripWidget extends StatefulWidget {
  final List<DateTime> days;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool Function(DateTime) hasData;

  const DateStripWidget({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
    required this.hasData,
  });

  @override
  State<DateStripWidget> createState() => _DateStripWidgetState();
}

class _DateStripWidgetState extends State<DateStripWidget> {
  late final ScrollController _scrollCtrl;

  static const List<String> _dayNames = [
    '',
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim'
  ];

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToSelected();
    });
  }

  void _scrollToSelected() {
    final idx = widget.days.indexWhere((d) => _isSame(d, widget.selectedDate));
    if (idx < 0) return;
    const itemWidth = 56.0 + 8.0; // width + margin
    final offset = (idx * itemWidth) -
        (MediaQuery.of(context).size.width / 2) +
        itemWidth / 2;
    _scrollCtrl.animateTo(
      offset.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  bool _isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSame(d, DateTime.now());

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      color: Colors.transparent,
      child: ListView.separated(
        controller: _scrollCtrl,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: 4,
        ),
        itemCount: widget.days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final day = widget.days[i];
          final isSelected = _isSame(day, widget.selectedDate);
          final isToday = _isToday(day);
          final hasLog = widget.hasData(day);

          return _DayCard(
            date: day,
            dayName: _dayNames[day.weekday],
            isSelected: isSelected,
            isToday: isToday,
            hasData: hasLog,
            onTap: () => widget.onDateSelected(day),
          );
        },
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime date;
  final String dayName;
  final bool isSelected;
  final bool isToday;
  final bool hasData;
  final VoidCallback onTap;

  const _DayCard({
    required this.date,
    required this.dayName,
    required this.isSelected,
    required this.isToday,
    required this.hasData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pink : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.pink.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nom du jour
            Text(
              dayName,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            // Numéro du jour
            Text(
              '${date.day}',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            // Indicateur
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasData
                    ? (isSelected ? Colors.white : AppColors.pink)
                    : (isToday
                        ? AppColors.pink.withOpacity(0.4)
                        : Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
