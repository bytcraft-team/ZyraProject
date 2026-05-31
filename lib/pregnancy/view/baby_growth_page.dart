import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/pregnancy/view/shared_navigation.dart';
import 'package:zyra/pregnancy/viewmodels/pregnancy_view_model.dart';
import 'mother_week_page.dart';
import 'baby_week_page.dart';
import 'conseil_week_page.dart';
import 'package:zyra/pregnancy/models/week_info.dart';

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
// DESIGN TOKENS
// ============================================================
class _Colors {
  static const Color bgTop = Color(0xFFF3EEFF);
  static const Color bgBottom = Color(0xFFFDF0F7);
  static const Color deepIndigo = Color(0xFF2D1A5E);
  static const Color violet = Color(0xFF9B7AB8);
  static const Color violetLight = Color(0xFFB07FCC);
  static const Color violetSoft = Color(0xFFC07FCC);

  static const Color divider = Color(0x26B482D2);
  static const Color arcTrack = Color(0x26B482D2);
}

const _gradientPrimary = LinearGradient(
  colors: [Color(0xFF9B7FD4), Color(0xFFE3437D)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const _gradientHeader = LinearGradient(
  colors: [Color(0xFF7B70D8), Color(0xFFC57AD8), Color(0xFFE3437D)],
  stops: [0.0, 0.5, 1.0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ============================================================
// BABY GROWTH PAGE
// ============================================================
class BabyGrowthPage extends StatefulWidget {
  const BabyGrowthPage({super.key});

  @override
  State<BabyGrowthPage> createState() => _BabyGrowthPageState();
}

class _BabyGrowthPageState extends State<BabyGrowthPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index != _selectedIndex) navigateToPage(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const BabyGrowthContent(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ============================================================
// BABY GROWTH CONTENT
// ============================================================
class BabyGrowthContent extends StatefulWidget {
  const BabyGrowthContent({super.key});

  @override
  State<BabyGrowthContent> createState() => _BabyGrowthContentState();
}

class _BabyGrowthContentState extends State<BabyGrowthContent> {
  int? _selectedWeek;
  final ScrollController _timelineScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentWeek =
          context.read<PregnancyViewModel>().pregnancyTracking?.currentWeek ??
              19;
      final offset = (currentWeek - 1) * 76.0 - 40;
      if (_timelineScrollController.hasClients) {
        _timelineScrollController.animateTo(
          offset.clamp(0, _timelineScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timelineScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PregnancyViewModel>(
      builder: (context, viewModel, child) {
        final currentWeek = viewModel.pregnancyTracking?.currentWeek ?? 19;
        final weekInfo = viewModel.currentWeekInfo;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_Colors.bgTop, _Colors.bgBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWeekHero(currentWeek, weekInfo),
                      const SizedBox(height: 28),
                      _buildProgressSection(currentWeek, weekInfo),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildTimeline(currentWeek),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildPregnancyInfoCards(context, weekInfo),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildGrowthTimelineDetailed(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const _t1 = _TrimesterTheme(
    iconBg: Color(0xFFF1E7FA), // Light lavender
    titleColor: Color(0xFF9C27E8), // Purple
    subColor: Color(0xFFC86CF3), // Soft purple
    ringColor: Color(0xFFC86CF3), // Soft purple
    fillColor: Color(0xFFF1E7FA), // Light lavender
    labelColor: Color(0xFF9C27E8), // Purple
    arrowColor: Color(0xFFC86CF3), // Soft purple
  );

  static const _t2 = _TrimesterTheme(
    iconBg: Color(0xFFFDECF5), // Light pink background
    titleColor: Color(0xFFE91E8F), // Primary pink
    subColor: Color(0xFFFF2DA3), // Gradient pink
    ringColor: Color(0xFFFF2DA3), // Gradient pink
    fillColor: Color(0xFFFFF5F8), // Very light pink
    labelColor: Color(0xFFE91E8F), // Primary pink
    arrowColor: Color(0xFFF8DDE8), // Calendar pink circles
  );

  static const _t3 = _TrimesterTheme(
    iconBg: Color(0xFFFAD7E8), // Bottom navbar active bg
    titleColor: Color(0xFFE91E8F), // Primary pink
    subColor: Color(0xFFC86CF3), // Soft purple
    ringColor: Color(0xFFF8DDE8), // Calendar pink circles
    fillColor: Color(0xFFFFF5F8), // Very light pink
    labelColor: Color(0xFF9C27E8), // Purple
    arrowColor: Color(0xFFF8DDE8), // Calendar pink circles
  );
  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        decoration: const BoxDecoration(gradient: _gradientHeader),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 44),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Croissance bébé',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  child: _headerIconBtn(Icons.settings_outlined),
                ),
                Positioned(
                  right: 16,
                  child: _headerIconBtn(Icons.notifications_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerIconBtn(IconData icon) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      );

  // ─────────────────────────────────────────────
  // WEEK HERO
  // ─────────────────────────────────────────────
  Widget _buildWeekHero(int currentWeek, WeekInfo? weekInfo) {
    final babySize = weekInfo?.babyFruitComparison ?? 'taille';
    return Column(
      children: [
        const SizedBox(height: 28),
        _sectionLabel('SEMAINE ACTUELLE'),
        const SizedBox(height: 4),
        Text(
          'Semaine $currentWeek',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _Colors.deepIndigo,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Votre bébé a la taille d\'une mangue 🥭',
          style: TextStyle(fontSize: 14, color: _Colors.violet),
        ),
        const SizedBox(height: 28),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC47AD8).withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF0D9FF), Color(0xFFFFC8E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  babyWeekAsset(currentWeek),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('🫶', style: TextStyle(fontSize: 48)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: _inlineStat(
                    '${weekInfo?.babyWeightGrams.toStringAsFixed(0) ?? '193'} g',
                    'Poids')),
            const SizedBox(width: 8),
            Flexible(
                child: _inlineStat(
                    '${weekInfo?.babyLengthCm.toStringAsFixed(1) ?? '15.3'} cm',
                    'Taille')),
            const SizedBox(width: 8),
            Flexible(child: _inlineStat('2ème', 'Trimestre')),
          ],
        ),
      ],
    );
  }

  Widget _inlineStat(String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 235, 206, 245),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Color.fromARGB(255, 226, 156, 227), width: 1),
          boxShadow: [
            BoxShadow(
              color: Color(0x33E91E8F),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3A2032),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: Color(0xFFB39AAA),
              ),
            ),
          ],
        ),
      );

  // ─────────────────────────────────────────────
  // PROGRESS
  // ─────────────────────────────────────────────
  Widget _buildProgressSection(int currentWeek, WeekInfo? weekInfo) {
    final double progress = currentWeek / 40;
    final remainingWeeks = (40 - currentWeek).clamp(0, 40);
    final percentage = (progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('PROGRESSION'),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      backgroundColor: _Colors.arcTrack,
                      valueColor: const AlwaysStoppedAnimation(
                        Color.fromARGB(255, 140, 36, 205),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$currentWeek',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _Colors.deepIndigo,
                          height: 1,
                        ),
                      ),
                      const Text(
                        '/ 40',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _Colors.violetLight,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  _progressRow('Restant', '$currentWeek semaines'),
                  const SizedBox(height: 8),
                  _progressRow('Avancement', '$percentage%'),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF9C27E8), // Purple
                            Color(0xFFE91E8F), // Pink
                            Color(0xFFFF2DA3), // Gradient pink
                          ],
                        ).createShader(bounds),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: _Colors.arcTrack,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _progressRow(String k, String v) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 13, color: _Colors.violet)),
          Text(
            v,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _Colors.deepIndigo,
            ),
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // TIMELINE (pill scroll)
  // ─────────────────────────────────────────────
  Widget _buildTimeline(int currentWeek) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Évolution semaine par semaine',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _Colors.deepIndigo,
              ),
            ),
            Text(
              'Voir tout',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _Colors.violetSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 92,
          child: ListView.builder(
            controller: _timelineScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: 40,
            itemBuilder: (context, index) {
              final week = index + 1;
              final isActive = week == (_selectedWeek ?? currentWeek);
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedWeek = (_selectedWeek == week) ? null : week;
                }),
                child: Container(
                  width: 64,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isActive ? _gradientPrimary : null,
                          color:
                              isActive ? null : Colors.white.withOpacity(0.65),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFC57AD8,
                                    ).withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _weekEmoji(week),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'S$week',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w600,
                          color: isActive
                              ? _Colors.deepIndigo
                              : _Colors.violetLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getBabySize(week).split(' ').first,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: _Colors.violetLight.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SizeTransition(sizeFactor: anim, child: child),
          ),
          child: _selectedWeek != null
              ? _buildWeekDetailInline(_selectedWeek!)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildWeekDetailInline(int week) {
    return Container(
      key: ValueKey(week),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Semaine $week',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _Colors.deepIndigo,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _selectedWeek = null),
                child: const Text(
                  'Fermer ↑',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _Colors.violetSoft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Taille d\'une ${_getBabySize(week)} ${_weekEmoji(week)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _Colors.violetSoft,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _getDevelopmentDescription(week),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7A5A90),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DETAILED GROWTH TIMELINE (replaces old card timeline)
  // ─────────────────────────────────────────────
  Widget _buildGrowthTimelineDetailed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('PARCOURS DE CROISSANCE'),
        const SizedBox(height: 6),
        const Text(
          'Touchez une semaine pour voir le détail',
          style: TextStyle(
            fontSize: 13,
            color: _Colors.violet,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),

        // ── Premier trimestre – Violet ───────────────────────
        _buildTrimesterBlock(
          theme: _t1,
          icon: '🤰',
          title: 'Premier trimestre',
          subtitle: 'Semaines 1 - 13',
          groups: const [
            [1],
            [2],
            [3, 4],
            [5, 6],
            [7, 8, 9, 10, 11, 12, 13],
          ],
        ),

        const SizedBox(height: 20),
        Container(height: 0.8, color: const Color(0xFFF0F0F0)),
        const SizedBox(height: 20),

        // ── Deuxième trimestre – Vert ────────────────────────
        _buildTrimesterBlock(
          theme: _t2,
          icon: '🤱',
          title: 'Deuxième trimestre',
          subtitle: 'Semaines 14 - 27',
          groups: const [
            [14],
            [15, 16],
            [17, 18, 19],
            [20, 21, 22],
            [23, 24, 25, 26, 27],
          ],
        ),

        const SizedBox(height: 20),
        Container(height: 0.8, color: const Color(0xFFF0F0F0)),
        const SizedBox(height: 20),

        // ── Troisième trimestre – Orange ─────────────────────
        _buildTrimesterBlock(
          theme: _t3,
          icon: '👶',
          title: 'Troisième trimestre',
          subtitle: 'Semaines 28 - 40',
          groups: const [
            [28],
            [29, 30, 31],
            [34],
            [35, 36, 37],
            [38, 39, 40],
          ],
        ),
      ],
    );
  }

  Widget _buildTrimesterBlock({
    required _TrimesterTheme theme,
    required String icon,
    required String title,
    required String subtitle,
    required List<List<int>> groups,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: theme.iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.titleColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: theme.subColor),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Scrollable circles
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int gi = 0; gi < groups.length; gi++) ...[
                _buildWeekCircleGroup(groups[gi], theme),
                if (gi < groups.length - 1) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: Text(
                      '›',
                      style: TextStyle(
                        fontSize: 22,
                        color: theme.arrowColor,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCircleGroup(List<int> weeks, _TrimesterTheme theme) {
    final midWeek = weeks[weeks.length ~/ 2];
    final String topLine =
        weeks.length == 1 ? '${weeks.first}' : '${weeks.last} - ${weeks.first}';
    final String bottomLine = weeks.length == 1 ? 'Semaine' : 'Semaines';

    return GestureDetector(
      onTap: () => _showWeekBottomSheet(context, {
        'week': midWeek,
        'size': _getBabySize(midWeek),
        'description': _getDevelopmentDescription(midWeek),
      }),
      child: Column(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.fillColor,
              border: Border.all(color: theme.ringColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: theme.ringColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                babyWeekAsset(midWeek),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    _weekEmoji(midWeek),
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            topLine,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.labelColor,
              height: 1.2,
            ),
          ),
          Text(
            bottomLine,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: theme.labelColor.withOpacity(0.8),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Premium bottom sheet — replaces old showDialog
  void _showWeekBottomSheet(BuildContext context, Map<String, dynamic> week) {
    final int w = week['week'] as int;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _Colors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),

            // Baby image
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFEDD9FF), Color(0xFFFFCCE8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC47AD8).withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  babyWeekAsset(w),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      _weekEmoji(w),
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Week number
            Text(
              'Semaine $w',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _Colors.deepIndigo,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),

            // Size badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '${week['size']}  ${_weekEmoji(w)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9B5FCC),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            Text(
              week['description'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7A5A90),
                height: 1.7,
              ),
            ),
            const SizedBox(height: 28),

            // Close button — gradient pill
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B7FD4), Color(0xFFE3437D)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Fermer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GUIDE ROWS
  // ─────────────────────────────────────────────
  Widget _buildPregnancyInfoCards(BuildContext context, WeekInfo? weekInfo) {
    final cards = [
      {
        'title': 'Maman',
        'week': 'Semaine ${weekInfo?.weekNumber ?? 1}',
        'image': 'assets/images/women1.png',
        'page': const MotherWeekPage(),
      },
      {
        'title': 'Bébé',
        'week': 'Semaine ${weekInfo?.weekNumber ?? 1}',
        'image': 'assets/images/baby.png',
        'page': const BabyWeekPage(),
      },
      {
        'title': 'Conseils',
        'week': 'Semaine ${weekInfo?.weekNumber ?? 1}',
        'image': 'assets/images/baby_mom2.png',
        'page': const TipsWeekPage(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Guide de Grossesse",
          style: TextStyle(
            color: AppColors.deepIndigo,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        ...cards.map(
          (card) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => card['page'] as Widget),
                );
              },
              child: Hero(
                tag: card['title'] as String,
                child: Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    image: DecorationImage(
                      image: AssetImage(card['image'] as String),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                card['week'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  card['title'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SHARED
  // ─────────────────────────────────────────────
  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: _Colors.violetLight,
        ),
      );

  Widget _buildDivider() => Container(height: 0.5, color: _Colors.divider);

  // ─────────────────────────────────────────────
  // DATA HELPERS
  // ─────────────────────────────────────────────
  String babyWeekAsset(int week) {
    if (week == 1 || week == 2) return 'assets/imagesBaby/baby1_2.jpg';
    return 'assets/imagesBaby/baby$week.jpg';
  }

  String _weekEmoji(int week) {
    const emojis = [
      '🌱', // 1
      '🌱', // 2
      '🫘', // 3
      '🫘', // 4
      '🫛', // 5
      '🫛', // 6
      '🫐', // 7
      '🫐', // 8
      '🍇', // 9
      '🍓', // 10
      '🍊', // 11
      '🍋', // 12
      '🍎', // 13
      '🍐', // 14
      '🥑', // 15
      '🥭', // 16
      '🍌', // 17
      '🥕', // 18
      '🌽', // 19
      '🍠', // 20
      '🥦', // 21
      '🍆', // 22
      '🥥', // 23
      '🍍', // 24
      '🍈', // 25
      '🍈', // 26
      '🥬', // 27
      '🥬', // 28
      '🎃', // 29
      '🎃', // 30
      '🍉', // 31
      '🍉', // 32
      '🍉', // 33
      '🍉', // 34
      '🎃', // 35
      '🎃', // 36
      '🎃', // 37
      '👶', // 38
      '👶', // 39
      '👶', // 40
    ];

    if (week < 1 || week > 40) return '👶';
    return emojis[week - 1];
  }

  String _getBabySize(int week) {
    const sizes = {
      1: 'Graine de pavot',
      2: 'Graine de sésame',
      3: 'Lentille',
      4: 'Petit pois',
      5: 'Graine de pomme',
      6: 'Pois sucré',
      7: 'Myrtille',
      8: 'Haricot rouge',
      9: 'Raisin',
      10: 'Kumquat',
      11: 'Figue',
      12: 'Lime',
      13: 'Citron',
      14: 'Pomme',
      15: 'Orange',
      16: 'Avocat',
      17: 'Poire',
      18: 'Patate douce',
      19: 'Mangue',
      20: 'Banane',
      21: 'Carotte',
      22: 'Courge spaghetti',
      23: 'Grande mangue',
      24: 'Épi de maïs',
      25: 'Rutabaga',
      26: 'Cive',
      27: 'Chou-fleur',
      28: 'Aubergine',
      29: 'Courge butternut',
      30: 'Chou',
      31: 'Noix de coco',
      32: 'Jicama',
      33: 'Ananas',
      34: 'Cantaloup',
      35: 'Melon honeydew',
      36: 'Laitue romaine',
      37: 'Bette à carde',
      38: 'Poireau',
      39: 'Pastèque',
      40: 'Citrouille',
    };
    return sizes[week] ?? 'Bébé en croissance';
  }

  String _getDevelopmentDescription(int week) {
    if (week <= 4) {
      return 'L\'embryon s\'implante dans la paroi utérine. Les premières cellules commencent à se diviser et les structures fondamentales de la vie se mettent en place.';
    } else if (week <= 8) {
      return 'Les organes majeurs et les systèmes corporels se forment. Le cœur commence à battre et les bourgeons des membres apparaissent.';
    } else if (week <= 12) {
      return 'Les doigts et les orteils se développent. Bébé peut bouger, avaler et les premiers réflexes apparaissent.';
    } else if (week <= 16) {
      return 'L\'ouïe de bébé se développe. Les traits du visage deviennent plus définis. Les mouvements deviennent plus coordonnés.';
    } else if (week <= 20) {
      return 'Bébé peut entendre votre voix. Les mouvements deviennent plus forts et vous pouvez les ressentir distinctement.';
    } else if (week <= 24) {
      return 'Les poumons se développent et bébé s\'entraîne à respirer. Les sens continuent de mûrir rapidement.';
    } else if (week <= 28) {
      return 'Les yeux peuvent s\'ouvrir et se fermer. Le cerveau se développe très rapidement. Bébé reconnaît votre voix.';
    } else if (week <= 32) {
      return 'Bébé prend du poids rapidement. Les poumons arrivent à maturité. La peau devient plus lisse et moins translucide.';
    } else if (week <= 36) {
      return 'La peau de bébé s\'adoucit. La croissance finale se poursuit. Bébé se positionne en vue de la naissance.';
    } else {
      return 'Bébé est prêt pour la naissance. Tous les systèmes sont pleinement développés. L\'accouchement peut survenir à tout moment.';
    }
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
