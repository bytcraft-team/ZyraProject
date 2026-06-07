import 'package:flutter/material.dart';
import 'package:zyra/screens/community/articles_list_screen.dart';
import 'package:zyra/screens/community/posts_feed_screen.dart';
import 'baby_growth_page.dart';
import 'package:zyra/pregnancy1/view/nutrition_page.dart';
import 'package:zyra/pregnancy1/view/pregnancy_tracker_screen.dart';
import 'package:zyra/pregnancy1/view/symptom_tracking_page.dart';

// ============================================================
// 🎨 APP COLORS — Blush Modern Theme
// ============================================================
class AppColors {
  static const deepIndigo = Color(0xFF1E1B4B);
  static const violet = Color(0xFF7C3AED);
  static const pink = Color(0xFFEC4899);
  static const offWhite = Color(0xFFF9F7FF);
  static const muted = Color(0xFF94A3B8);
  static const blush = Color(0xFFFBCFE8);
}

// ============================================================
// NAVIGATION ITEMS CONFIGURATION
// ============================================================
class NavItem {
  final IconData icon;
  final String label;
  final Widget? page;

  const NavItem({required this.icon, required this.label, this.page});
}

final List<NavItem> navigationItems = [
  NavItem(
    icon: Icons.home_rounded,
    label: 'Home',
    page: const PregnancyHomePage(),
  ),
  NavItem(
    icon: Icons.child_care,
    label: 'Growth',
    page: const BabyGrowthPage(),
  ),
  NavItem(
    icon: Icons.restaurant_menu,
    label: 'Nutrition',
    page: const HealthyNutritionPage(),
  ),
  NavItem(
    icon: Icons.sick_outlined,
    label: 'Symptoms',
    page: const SymptomTrackingPage(),
  ),
  NavItem(
    icon: Icons.people_alt_outlined,
    label: 'Posts',
    page: const PostsFeedScreen(),
  ),
  NavItem(
    icon: Icons.article_outlined,
    label: 'Articles',
    page: const ArticlesListScreen(),
  ),
];

// ============================================================
// CUSTOM BOTTOM NAVIGATION BAR
// ============================================================
class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(navigationItems.length, (index) {
              final item = navigationItems[index];
              final isActive = index == widget.currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    _animationController.forward().then((_) {
                      _animationController.reverse();
                    });
                    widget.onTap(index);
                  },
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isActive ? _scaleAnimation.value : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: isActive
                                ? LinearGradient(
                                    colors: [
                                      AppColors.violet.withOpacity(0.1),
                                      AppColors.pink.withOpacity(0.1),
                                    ],
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isActive
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.violet,
                                            AppColors.pink,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isActive ? null : Colors.transparent,
                                ),
                                child: Icon(
                                  item.icon,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.muted,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isActive
                                      ? AppColors.deepIndigo
                                      : AppColors.muted,
                                  fontSize: 10,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NAVIGATION HELPER FUNCTIONS
// ============================================================
void navigateToPage(BuildContext context, int index) {
  final item = navigationItems[index];
  if (item.page != null) {
    if (item.page is PostsFeedScreen || item.page is ArticlesListScreen) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => item.page!));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => item.page!),
      );
    }
  } else {
    // Handle pages that don't exist yet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.label} page is coming soon!'),
        backgroundColor: AppColors.violet,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
