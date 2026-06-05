import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/pregnancy/view/nutrition_page.dart';
import 'package:zyra/pregnancy/view/shared_navigation.dart';
import 'package:zyra/pregnancy/viewmodels/pregnancy_view_model.dart';
import 'baby_growth_page.dart';
import 'symptom_tracking_page.dart';

// ============================================================
// TRIMESTER THEME
// ============================================================
class _TrimesterTheme {
  final Color iconBg,
      titleColor,
      subColor,
      ringColor,
      fillColor,
      labelColor,
      arrowColor;
  const _TrimesterTheme({
    required this.iconBg,
    required this.titleColor,
    required this.subColor,
    required this.ringColor,
    required this.fillColor,
    required this.labelColor,
    required this.arrowColor,
  });
}

const _t1 = _TrimesterTheme(
  iconBg: Color(0xFFF1E7FA), // Light lavender
  titleColor: Color(0xFF9C27E8), // Purple
  subColor: Color(0xFFC86CF3), // Soft purple
  ringColor: Color(0xFFC86CF3), // Soft purple
  fillColor: Color(0xFFF1E7FA), // Light lavender
  labelColor: Color(0xFF9C27E8), // Purple
  arrowColor: Color(0xFFC86CF3), // Soft purple
);

const _t2 = _TrimesterTheme(
  iconBg: Color(0xFFFDECF5), // Light pink background
  titleColor: Color(0xFFE91E8F), // Primary pink
  subColor: Color(0xFFFF2DA3), // Gradient pink
  ringColor: Color(0xFFFF2DA3), // Gradient pink
  fillColor: Color(0xFFFFF5F8), // Very light pink
  labelColor: Color(0xFFE91E8F), // Primary pink
  arrowColor: Color(0xFFF8DDE8), // Calendar pink circles
);

const _t3 = _TrimesterTheme(
  iconBg: Color(0xFFFAD7E8), // Bottom navbar active bg
  titleColor: Color(0xFFE91E8F), // Primary pink
  subColor: Color(0xFFC86CF3), // Soft purple
  ringColor: Color(0xFFF8DDE8), // Calendar pink circles
  fillColor: Color(0xFFFFF5F8), // Very light pink
  labelColor: Color(0xFF9C27E8), // Purple
  arrowColor: Color(0xFFF8DDE8), // Calendar pink circles
);

// ============================================================
// WAVE CLIPPER
// ============================================================
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height - 30,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ============================================================
// APP
// ============================================================
class PregnancyTrackerApp extends StatelessWidget {
  const PregnancyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color.fromARGB(255, 251, 250, 251),
      ),
      home: const PregnancyHomePage(),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================
class PregnancyHomePage extends StatefulWidget {
  const PregnancyHomePage({super.key});

  @override
  State<PregnancyHomePage> createState() => _PregnancyHomePageState();
}

class _PregnancyHomePageState extends State<PregnancyHomePage> {
  int _selectedIndex = 0; // Home page is index 0

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PregnancyViewModel>().loadTrackingFromFirestore();
    });
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      navigateToPage(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const PregnancyHomePageContent(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ============================================================
// HOME PAGE CONTENT (Original Content)
// ============================================================
class PregnancyHomePageContent extends StatelessWidget {
  const PregnancyHomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PregnancyViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.pregnancyTracking == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.pregnancyTracking == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Aucune donnée de grossesse disponible.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage ??
                          'Veuillez compléter votre profil de grossesse pour afficher le suivi.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Container(
            child: Column(
              children: [
                // HEADER
                _buildHeader(),

                // BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainStats(viewModel),
                        const SizedBox(height: 28),
                        _buildWeekCalendar(viewModel),
                        const SizedBox(height: 28),
                        _buildTodayTip(viewModel),
                        const SizedBox(height: 28),
                        _buildQuickAccessGrid(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // HEADER — gradient wave, no change
  // ----------------------------------------------------------
  Widget _buildHeader() {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 120, 113, 220),
              Color.fromARGB(255, 202, 134, 224),
              Color.fromARGB(255, 227, 67, 134),
            ],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 44),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Suivi de Grossesse',
                    style: TextStyle(
                      color: AppColors.offWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.offWhite,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.offWhite,
                      size: 20,
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

  // ----------------------------------------------------------
  // MAIN STATS — flat on background, no card
  // ----------------------------------------------------------
  Widget _buildMainStats(PregnancyViewModel viewModel) {
    final tracking = viewModel.pregnancyTracking!;
    final weekInfo = viewModel.currentWeekInfo;
    final babyLength = weekInfo?.babyLengthCm.toStringAsFixed(2) ?? '39';
    final babyWeight = weekInfo?.babyWeightGrams.toStringAsFixed(2) ?? '460';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Week label + title
        Center(
          child: Column(
            children: [
              Text(
                tracking.weekDisplay.toUpperCase(),
                style: TextStyle(
                  color: AppColors.violet.withValues(alpha: 0.7),
                  fontSize: 12,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Grossesse',
                style: TextStyle(
                  color: AppColors.deepIndigo,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    color: AppColors.pink.withValues(alpha: 0.5),
                    size: 9,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 1.5,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppColors.pink.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.favorite,
                    color: AppColors.pink.withValues(alpha: 0.5),
                    size: 9,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Baby image + stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildStatItem('Taille', babyLength, 'cm', Icons.straighten),
            // Baby avatar — gradient ring, no card
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: Image.asset(
                  viewModel.getLocalImagePath() ??
                      'assets/imagesBaby/baby19.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            _buildStatItem(
                'Poids', babyWeight, 'g', Icons.monitor_weight_outlined),
          ],
        ),
        const SizedBox(height: 22),

        // Days left pill — minimal pill, flat
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 180, 150, 233),
                  Color.fromARGB(255, 227, 87, 157),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white70, size: 13),
                const SizedBox(width: 8),
                const Text(
                  'Plus que ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${tracking.daysRemaining}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  ' jours',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.violet.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.violet, size: 20),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(255, 97, 99, 102),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: AppColors.deepIndigo,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  color: Color.fromARGB(255, 115, 120, 127),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // WEEK CALENDAR — flat on background, no card container
  // ----------------------------------------------------------
  Widget _buildWeekCalendar(PregnancyViewModel viewModel) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    final pregnancyWeek = viewModel.pregnancyTracking?.currentWeek;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header — flat, no card
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cette Semaine',
                  style: TextStyle(
                    color: AppColors.deepIndigo,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_getMonthName(now.month)} ${now.year}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 113, 116, 121),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 208, 132, 234),
                    Color.fromARGB(255, 195, 116, 227),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Semaine ${pregnancyWeek ?? _getWeekNumber(now)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Days row — no container, just the row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final date = weekStart.add(Duration(days: index));
            final isToday = date.day == now.day &&
                date.month == now.month &&
                date.year == now.year;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: isToday
                          ? const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 223, 108, 200),
                                Color(0xFFEC4899),
                              ],
                            )
                          : null,
                      color: isToday ? null : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isToday ? Colors.white : AppColors.deepIndigo,
                          fontWeight:
                              isToday ? FontWeight.w800 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _weekdayLabel(date.weekday),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isToday
                          ? AppColors.violet
                          : const Color.fromARGB(255, 114, 118, 124),
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        // Thin divider
        Divider(color: AppColors.muted.withValues(alpha: 0.15), thickness: 1),
      ],
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa'];
    return labels[weekday % 7];
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysElapsed =
        date.difference(firstDayOfYear).inDays + firstDayOfYear.weekday;
    return ((daysElapsed - 1) / 7).floor() + 1;
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return months[month - 1];
  }

  // ----------------------------------------------------------
  // TODAY TIP — flat on background, no card
  // ----------------------------------------------------------
  Widget _buildTodayTip(PregnancyViewModel viewModel) {
    final tip = viewModel.currentWeekInfo?.motherTips ??
        'Restez hydratée tout au long de la journée et prenez des pauses courtes pour vous détendre. Votre corps a besoin de repos et de soins pendant la grossesse.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pink.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 210, 115, 178), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.tips_and_updates_rounded,
              color: Color.fromARGB(255, 238, 194, 238),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Conseil du Jour",
                      style: TextStyle(
                        color: AppColors.deepIndigo,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.favorite,
                      color: AppColors.pink.withValues(alpha: 0.55),
                      size: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // QUICK ACCESS GRID — only these 3 are cards
  // ----------------------------------------------------------
  Widget _buildQuickAccessGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accès Rapide',
          style: TextStyle(
            color: AppColors.deepIndigo,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildModernCard(
                context: context,
                icon: Icons.menu_book_rounded,
                title: 'Guide',
                subtitle: 'Mère & Bébé',
                colors: [_t1.fillColor, _t1.iconBg],
                iconColors: [_t1.titleColor, _t1.labelColor],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BabyGrowthPage()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildModernCard(
                context: context,
                icon: Icons.favorite_rounded,
                title: 'Santé',
                subtitle: 'Nutrition',
                colors: [_t2.fillColor, _t2.iconBg],
                iconColors: [_t2.titleColor, _t2.labelColor],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HealthyNutritionPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildModernCard(
                context: context,
                icon: Icons.monitor_heart_rounded,
                title: 'Symptômes',
                subtitle: 'Suivi',
                colors: [_t3.fillColor, _t3.iconBg],
                iconColors: [_t3.titleColor, _t3.labelColor],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SymptomTrackingPage()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required List<Color> iconColors,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.9, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: iconColors),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.deepIndigo,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.55),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
