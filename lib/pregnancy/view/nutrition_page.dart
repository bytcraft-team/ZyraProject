import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/nutrition_model.dart';
import '../viewmodels/nutrition_view_model.dart';
import '../viewmodels/pregnancy_view_model.dart';
import 'food_avoid.dart';
import 'nutrition_detail_page.dart';
import 'shared_header.dart';
import 'shared_navigation.dart';

// Clean, responsive Nutrition page built to avoid overflows and layout issues.
// Structure: SafeArea -> SingleChildScrollView -> Padding(24) -> Column

const Color kPinkPastel = Color(0xFFFF7EB6);
const Color kPinkSoft = Color(0xFFFFB6D9);
const Color kLavender = Color(0xFFA78BFA);
const Color kDeepViolet = Color(0xFF7C3AED);
const Color kOffWhite = Color(0xFFFFF9FC);

class HealthyNutritionPage extends StatefulWidget {
  const HealthyNutritionPage({super.key});

  @override
  State<HealthyNutritionPage> createState() => _HealthyNutritionPageState();
}

class _HealthyNutritionPageState extends State<HealthyNutritionPage> {
  late NutritionViewModel _viewModel;
  late PregnancyViewModel _pregnancyViewModel;
  bool _isInitialized = false;
  int _selectedIndex = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    _pregnancyViewModel =
        Provider.of<PregnancyViewModel>(context, listen: false);
    final currentWeek = _pregnancyViewModel.pregnancyTracking?.currentWeek ?? 4;
    final nutritionEnabled = _pregnancyViewModel.pregnancyTracking != null;
    _viewModel = NutritionViewModel(
        currentWeek: currentWeek, nutritionTipsEnabled: nutritionEnabled);
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize();
    _isInitialized = true;
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _viewModel.removeListener(_onViewModelChanged);
      _viewModel.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) navigateToPage(context, index);
  }

  void _openDetail(NutritionModel item) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => NutritionDetailPage(item: item)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOffWhite,
      bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex, onTap: _onItemTapped),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildMainNutritionCard(context),
                    const SizedBox(height: 24),
                    _buildAvoidFoodsCard(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Catégorie nutritionnelle'),
                    const SizedBox(height: 12),
                    _buildCategoryChips(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Recommandations de la semaine'),
                    const SizedBox(height: 12),
                    _buildNutritionItemList(),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const PregnancyModuleHeader(title: 'Nutrition de Grossesse');
  }

  Widget _buildMainNutritionCard(BuildContext context) {
    // Card adapts to its content; no fixed heights
    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: [kPinkPastel, kDeepViolet]),
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.restaurant_menu,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Résumé nutritionnel',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text(
                      _viewModel.currentSummary,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Conseil principal',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text(_viewModel.headerSubtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildAvoidFoodsCard(BuildContext context) {
    return _CardWrapper(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FoodAvoidListScreen(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPinkSoft, kPinkPastel],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aliments à éviter pendant la grossesse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Découvrez les aliments qui peuvent présenter un risque pour vous et votre bébé.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: kLavender.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Voir la liste complète',
                        style: TextStyle(
                          color: kDeepViolet,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: NutritionViewModel.categories.map((category) {
          final isSelected = _viewModel.selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(_categoryLabel(category)),
              selected: isSelected,
              selectedColor: kLavender,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              onSelected: (_) => _viewModel.updateCategory(category),
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

  Widget _buildNutritionItemList() {
    final items = _viewModel.filteredList;
    if (items.isEmpty) {
      return _CardWrapper(
        child: const Text(
          'Aucun élément trouvé pour cette catégorie cette semaine.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _CardWrapper(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _openDetail(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.network(item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: kPinkSoft)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Text(item.shortBenefit,
                              style: const TextStyle(color: Colors.black54),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildTag(item.categoryLabel),
                              const SizedBox(width: 8),
                              _buildTag(item.mealTypeLabel),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.black38),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kPinkSoft.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF47295F))),
    );
  }

  String _trimesterLabel(int? week) {
    final w = week ?? _viewModel.effectiveWeek;
    if (w <= 13) return '1er trimestre';
    if (w <= 27) return '2e trimestre';
    return '3e trimestre';
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87));
  }
}

// Reusable Card wrapper that enforces padding, radius, shadow and dynamic height
class _CardWrapper extends StatelessWidget {
  final Widget child;
  const _CardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8))
          ],
        ),
        child: child,
      ),
    );
  }
}
