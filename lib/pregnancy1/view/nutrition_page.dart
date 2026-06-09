import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/nutrition_model.dart';
import '../viewmodels/nutrition_view_model.dart';
import '../viewmodels/pregnancy_view_model.dart';
import 'food_avoid.dart';
import 'nutrition_detail_page.dart';
import 'shared_header.dart';
import 'shared_navigation.dart';

// ── Palette rose-violet ───────────────────────────────────────────────────────
const Color kViolet = Color(0xFF7C3AED);
const Color kVioletMid = Color(0xFF9B5CF6);
const Color kVioletLight = Color(0xFFEDE9FE);
const Color kPink = Color(0xFFEC4899);
const Color kPinkDeep = Color(0xFFBE185D);
const Color kPinkLight = Color(0xFFFCE7F3);
const Color kPinkBorder = Color(0xFFFBCFE8);
const Color kPageBg = Color(0xFFFDF8FF);
const Color kTextPrimary = Color(0xFF1A0A2E);
const Color kTextMuted = Color(0xFF6B6880);
const Color kTextHint = Color(0xFF9590A8);

// Gradient helpers
const _kGradientMain = LinearGradient(
  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const _kGradientSoft = LinearGradient(
  colors: [Color(0xFFF5F0FF), Color(0xFFFCE7F3)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const _kGradientCard = LinearGradient(
  colors: [Color(0xFFEDE9FE), Color(0xFFFCE7F3)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class HealthyNutritionPage extends StatefulWidget {
  const HealthyNutritionPage({super.key});

  @override
  State<HealthyNutritionPage> createState() => _HealthyNutritionPageState();
}

class _HealthyNutritionPageState extends State<HealthyNutritionPage> {
  late NutritionViewModel _viewModel;
  late PregnancyViewModel _pregnancyViewModel;
  bool _isInitialized = false;
  bool _hasPregnancyListener = false;
  final int _selectedIndex = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    _pregnancyViewModel = Provider.of<PregnancyViewModel>(
      context,
      listen: false,
    );
    final currentWeek = _pregnancyViewModel.pregnancyTracking?.currentWeek ?? 4;
    final nutritionEnabled = _pregnancyViewModel.pregnancyTracking != null;
    _viewModel = NutritionViewModel(
      currentWeek: currentWeek,
      nutritionTipsEnabled: nutritionEnabled,
    );
    _viewModel.addListener(_onViewModelChanged);
    _pregnancyViewModel.addListener(_onPregnancyChanged);
    _hasPregnancyListener = true;
    _viewModel.initialize();
    _isInitialized = true;
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _onPregnancyChanged() {
    if (!_isInitialized) return;
    final currentWeek = _pregnancyViewModel.pregnancyTracking?.currentWeek ?? 4;
    final nutritionEnabled = _pregnancyViewModel.pregnancyTracking != null;
    _viewModel.setPregnancyState(
      currentWeek: currentWeek,
      enabled: nutritionEnabled,
    );
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _viewModel.removeListener(_onViewModelChanged);
      _viewModel.dispose();
    }
    if (_hasPregnancyListener) {
      _pregnancyViewModel.removeListener(_onPregnancyChanged);
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) navigateToPage(context, index);
  }

  void _openDetail(NutritionModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NutritionDetailPage(item: item)),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBg,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Column(
        children: [
          const PregnancyModuleHeader(title: 'Nutrition de Grossesse'),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow(),
                      const SizedBox(height: 18),
                      _buildSummaryCard(),
                      const SizedBox(height: 14),
                      _buildAvoidFoodsCard(context),
                      const SizedBox(height: 28),
                      _buildSectionLabel('Catégorie nutritionnelle'),
                      const SizedBox(height: 12),
                      _buildCategoryChips(),
                      const SizedBox(height: 28),
                      _buildSectionLabel('Recommandations de la semaine'),
                      const SizedBox(height: 12),
                      _buildNutritionItemList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Row ───────────────────────────────────────────────────────────────

  Widget _buildStatRow() {
    return Row(
      children: [
        _StatPill(
          value: '+300',
          label: 'kcal / jour',
          icon: Icons.local_fire_department_rounded,
          iconColor: kViolet,
          iconBg: kVioletLight,
        ),
        const SizedBox(width: 10),
        _StatPill(
          value: '71g',
          label: 'protéines',
          icon: Icons.egg_alt_outlined,
          iconColor: kPink,
          iconBg: kPinkLight,
        ),
        const SizedBox(width: 10),
        _StatPill(
          value: '27mg',
          label: 'fer',
          icon: Icons.opacity_rounded,
          iconColor: kViolet,
          iconBg: kVioletLight,
        ),
      ],
    );
  }

  // ── Summary card ───────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _kGradientMain,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: kViolet.withOpacity(0.30),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: kPink.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative orbs
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GradientLabel('Résumé nutritionnel'),
                          const SizedBox(height: 5),
                          Text(
                            _viewModel.currentSummary,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _viewModel.headerSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.80),
                              height: 1.55,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _WeekProgressBar(week: _viewModel.effectiveWeek),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Avoid foods card ───────────────────────────────────────────────────────

  Widget _buildAvoidFoodsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FoodAvoidListScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: _kGradientCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kPinkBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: kPink.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                bottom: -18,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [kPink.withOpacity(0.15), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: kPink.withOpacity(0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.no_food_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GradientTextLabel('Aliments à éviter'),
                          const SizedBox(height: 4),
                          const Text(
                            'Risques pendant la grossesse',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Protégez votre bébé en évitant ces aliments.',
                            style: TextStyle(
                              fontSize: 12,
                              color: kTextMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _GradientCircleArrow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category chips ─────────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: NutritionViewModel.categories.map((cat) {
          final selected = _viewModel.selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => _viewModel.updateCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: selected
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          gradient: _kGradientMain,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: kViolet.withOpacity(0.30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _categoryIcon(cat),
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _categoryLabel(cat),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: kPinkBorder, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (b) =>
                                  _kGradientMain.createShader(b),
                              child: Icon(
                                _categoryIcon(cat),
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            ShaderMask(
                              shaderCallback: (b) =>
                                  _kGradientMain.createShader(b),
                              child: Text(
                                _categoryLabel(cat),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'protein':
        return 'Protéine';
      case 'vegetable':
        return 'Légume';
      case 'fruit':
        return 'Fruit';
      default:
        return category;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'protein':
        return Icons.egg_alt_outlined;
      case 'vegetable':
        return Icons.spa_outlined;
      case 'fruit':
        return Icons.apple_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  // ── Nutrition item list ────────────────────────────────────────────────────

  Widget _buildNutritionItemList() {
    final items = _viewModel.filteredList;
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: _kGradientSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPinkBorder, width: 1),
        ),
        child: Row(
          children: const [
            Icon(Icons.inbox_outlined, color: kTextHint, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucun élément pour cette catégorie cette semaine.',
                style: TextStyle(color: kTextMuted, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(items.length, (i) {
        final item = items[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _NutritionItemCard(
            item: item,
            index: i,
            onTap: () => _openDetail(item),
          ),
        );
      }),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (b) => _kGradientMain.createShader(b),
          child: Container(
            width: 3,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kTextMuted,
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }
}

// ── Nutrition Item Card ───────────────────────────────────────────────────────

class _NutritionItemCard extends StatelessWidget {
  final NutritionModel item;
  final VoidCallback onTap;
  final int index;
  const _NutritionItemCard({
    required this.item,
    required this.onTap,
    required this.index,
  });

  // Alternating accent: odd = more rose, even = more violet
  Color get _accentColor =>
      index.isEven ? const Color(0xFF7C3AED) : const Color(0xFFEC4899);
  Color get _accentBg =>
      index.isEven ? const Color(0xFFEDE9FE) : const Color(0xFFFCE7F3);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: index.isEven ? const Color(0xFFEDE9FE) : kPinkBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image side with gradient overlay strip
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                  child: SizedBox(
                    width: 90,
                    height: 98,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _accentBg,
                        child: Icon(
                          Icons.restaurant_outlined,
                          color: _accentColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                // Thin gradient strip on right edge of image
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          _accentBg.withOpacity(0.5),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: kTextPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.shortBenefit,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextMuted,
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _GradientTag(
                          label: item.categoryLabel,
                          gradient: _kGradientMain,
                        ),
                        const SizedBox(width: 6),
                        _PlainTag(
                          label: item.mealTypeLabel,
                          bg: _accentBg,
                          fg: _accentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: _kGradientMain,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Week Progress Bar ─────────────────────────────────────────────────────────

class _WeekProgressBar extends StatelessWidget {
  final int week;
  const _WeekProgressBar({required this.week});

  @override
  Widget build(BuildContext context) {
    final progress = (week / 40).clamp(0.0, 1.0);
    final trimester = week <= 13
        ? '1er'
        : week <= 27
        ? '2e'
        : '3e';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Semaine $week · $trimester trimestre',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Track
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Fill
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.50),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Stat Pill ─────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  const _StatPill({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: _kGradientSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPinkBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: kPink.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: _kGradientMain,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kViolet.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (b) => _kGradientMain.createShader(b),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: kTextHint,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient circle arrow ─────────────────────────────────────────────────────

class _GradientCircleArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: _kGradientMain,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: kPink.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

// ── Gradient tag (pill with gradient bg) ─────────────────────────────────────

class _GradientTag extends StatelessWidget {
  final String label;
  final Gradient gradient;
  const _GradientTag({required this.label, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PlainTag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _PlainTag({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ── Gradient text label ───────────────────────────────────────────────────────

class _GradientTextLabel extends StatelessWidget {
  final String text;
  const _GradientTextLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (b) => _kGradientMain.createShader(b),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GradientLabel extends StatelessWidget {
  final String text;
  const _GradientLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Colors.white.withOpacity(0.65),
      ),
    );
  }
}
