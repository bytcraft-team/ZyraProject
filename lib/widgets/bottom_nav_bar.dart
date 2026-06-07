import 'package:flutter/material.dart';
import '../cycle1/core/constants/app_colors.dart';
import 'package:zyra/screens/community/posts_feed_screen.dart';
import 'package:zyra/screens/community/articles_list_screen.dart';

// Labels and icons for the bottom nav (file-scope so state can access them)
const List<String> _labels = [
  'Accueil',
  'Journal',
  'Calendrier',
  'Éducation',
  'Paramaitre',
  'Posts',
  'Articles',
];

const List<IconData> _icons = [
  Icons.home_rounded,
  Icons.edit_note_rounded,
  Icons.calendar_month_rounded,
  Icons.today_rounded,
  Icons.menu_book_rounded,
  Icons.people_alt_outlined,
  Icons.article_outlined,
];

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

// ─────────────────────────────────────────────────────────────
// Item de navigation isolé
// ─────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final double iconSize;
  final double fontSize;
  final double iconPad;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.iconSize,
    required this.fontSize,
    required this.iconPad,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Icône ──────────────────────────────────────────────
        if (isActive)
          Container(
            padding: EdgeInsets.all(iconPad),
            decoration: BoxDecoration(
              color: AppColors.pinkSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: iconSize),
          )
        else
          Icon(icon, color: color, size: iconSize),

        const SizedBox(height: 3),

        // ── Label ──────────────────────────────────────────────
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: color,
            height: 1.0, // évite le line-height qui cause overflow
          ),
        ),
      ],
    );
  }
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    // Reuse original build logic but use widget.selectedIndex and _communityActiveIdx
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final barHeight = screenH < 700 ? 56.0 : 62.0;
    final iconSize = screenW < 360 ? 20.0 : 22.0;
    final fontSize = screenW < 360 ? 9.0 : 10.0;
    final iconPad = screenH < 700 ? 6.0 : 8.0;

    return Container(
      height: barHeight + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: barHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_labels.length, (i) {
                final isActive = i == widget.selectedIndex;
                final color = isActive
                    ? AppColors.pink
                    : AppColors.textSecondary;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      debugPrint('BottomNav tap -> $i');
                      if (i < 5) {
                        widget.onTap(i);
                        return;
                      }

                      if (i == widget.selectedIndex) {
                        return;
                      }

                      if (i == 5) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostsFeedScreen(showCycleNav: true),
                          ),
                        );
                        return;
                      }

                      if (i == 6) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ArticlesListScreen(showCycleNav: true),
                          ),
                        );
                        return;
                      }
                    },
                    child: _NavItem(
                      icon: _icons[i],
                      label: _labels[i],
                      isActive: isActive,
                      color: color,
                      iconSize: iconSize,
                      fontSize: fontSize,
                      iconPad: iconPad,
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}
