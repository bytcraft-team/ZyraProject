import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/nutrition_model.dart';
import '../viewmodels/nutrition_view_model.dart';
import '../viewmodels/pregnancy_view_model.dart';
import 'food_avoid.dart';
import 'nutrition_detail_page.dart';
import 'shared_header.dart';
import 'shared_navigation.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const Color kDeepViolet = Color(0xFF7C3AED);
const Color kLavenderLight = Color(0xFFF5F0FF);
const Color kPageBg = Color(0xFFFDF7FF);
const Color kCardBorder = Color(0xFFF0E6FA);
const Color kTextPrimary = Color(0xFF1C1C2E);
const Color kTextMuted = Color(0xFF6B6880);
const Color kTextHint = Color(0xFF9590A8);

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
  int _selectedIndex = 2;

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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ← header original inchangé
              const PregnancyModuleHeader(title: 'Nutrition de Grossesse'),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(),
                    const SizedBox(height: 16),
                    _buildSummaryCard(),
                    const SizedBox(height: 14),
                    _buildAvoidFoodsCard(context),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Catégorie nutritionnelle'),
                    const SizedBox(height: 10),
                    _buildCategoryChips(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Recommandations de la semaine'),
                    const SizedBox(height: 10),
                    _buildNutritionItemList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stat pills ─────────────────────────────────────────────────────────────

  Widget _buildStatRow() {
    return Row(
      children: [
        _StatPill(value: '+300', label: 'kcal/jour'),
        const SizedBox(width: 10),
        _StatPill(value: '71g', label: 'protéines'),
        const SizedBox(width: 10),
        _StatPill(value: '27mg', label: 'fer'),
      ],
    );
  }

  // ── Summary card ───────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    return _NiceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconPill(
                icon: Icons.eco_outlined,
                bg: kLavenderLight,
                color: kDeepViolet,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardLabel('Résumé nutritionnel'),
                    const SizedBox(height: 4),
                    Text(
                      _viewModel.currentSummary,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _viewModel.headerSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextMuted,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
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
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF0F7), Color(0xFFFDF4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFBCFE8), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE879A0).withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _IconPill(
              icon: Icons.warning_amber_rounded,
              bg: Color(0xFFFFE4EF),
              color: Color(0xFFE11D6A),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardLabel(
                    'Aliments à éviter',
                    color: Color(0xFFE11D6A),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Risques pendant la grossesse',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Découvrez les aliments qui peuvent présenter un risque pour vous et votre bébé.',
                    style: TextStyle(
                      fontSize: 13,
                      color: kTextMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: kDeepViolet,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Voir la liste complète →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _viewModel.updateCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? kDeepViolet : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? kDeepViolet : const Color(0xFFE9D5FF),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _categoryLabel(cat),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : kDeepViolet,
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

  // ── Nutrition item list ────────────────────────────────────────────────────

  Widget _buildNutritionItemList() {
    final items = _viewModel.filteredList;
    if (items.isEmpty) {
      return _NiceCard(
        child: Row(
          children: const [
            Icon(Icons.inbox_outlined, color: kTextHint, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aucun élément trouvé pour cette catégorie cette semaine.',
                style: TextStyle(color: kTextMuted, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _openDetail(item),
            child: _NiceCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 76,
                      height: 76,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFFF3E8FF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: kTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.shortBenefit,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kTextHint,
                            height: 1.45,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _FoodTag(
                              label: item.categoryLabel,
                              bg: const Color(0xFFFDF2F8),
                              fg: const Color(0xFFBE185D),
                            ),
                            const SizedBox(width: 6),
                            _FoodTag(
                              label: item.mealTypeLabel,
                              bg: const Color(0xFFEEF2FF),
                              fg: const Color(0xFF4338CA),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Color(0xFFD4AEFB),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _trimesterLabel(int? week) {
    final w = week ?? _viewModel.effectiveWeek;
    if (w <= 13) return '1er trimestre';
    if (w <= 27) return '2e trimestre';
    return '3e trimestre';
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kTextMuted,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF5F0FF), Color(0xFFFFF0F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDE9FE), width: 0.8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kDeepViolet,
              ),
            ),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 11, color: kTextHint)),
          ],
        ),
      ),
    );
  }
}

class _NiceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _NiceCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kCardBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB06AE3).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;
  const _IconPill({required this.icon, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _CardLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const _CardLabel(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: color ?? kDeepViolet,
      ),
    );
  }
}

class _FoodTag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _FoodTag({required this.label, required this.bg, required this.fg});

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
