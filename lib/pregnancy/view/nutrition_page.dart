import 'package:flutter/material.dart';

import '../models/nutrition_model.dart';
import '../viewmodels/nutrition_view_model.dart';
import 'shared_navigation.dart';
import 'nutrition_detail_page.dart';

class HealthyNutritionPage extends StatefulWidget {
  const HealthyNutritionPage({super.key});

  @override
  State<HealthyNutritionPage> createState() => _HealthyNutritionPageState();
}

class _HealthyNutritionPageState extends State<HealthyNutritionPage> {
  final NutritionViewModel _viewModel = NutritionViewModel();
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      navigateToPage(context, index);
    }
  }

  void _openDetail(NutritionModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NutritionDetailPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FCF8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF475357),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          _buildWeekCard(),
          const SizedBox(height: 16),
          _buildCategoryFilter(),
          const SizedBox(height: 16),
          Expanded(child: _buildFoodList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F7A67), Color(0xFF6FBC9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Nutrition',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Des conseils sains et adaptés à votre grossesse',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F7F2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  '${_viewModel.selectedWeek}',
                  style: const TextStyle(
                    color: Color(0xFF1F7A67),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week ${_viewModel.selectedWeek} de grossesse',
                    style: const TextStyle(
                      color: Color(0xFF102A16),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cette semaine, explorez des aliments recommandés selon votre évolution.',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 13,
                      height: 1.5,
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

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: NutritionViewModel.categories.map((category) {
          final selected = _viewModel.selectedCategory == category;
          return ChoiceChip(
            labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            label: Text(
              _categoryLabel(category),
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF1F7A67),
                fontWeight: FontWeight.w700,
              ),
            ),
            selected: selected,
            selectedColor: const Color(0xFF1F7A67),
            backgroundColor: const Color(0xFFE9F7F2),
            onSelected: (_) => _viewModel.updateCategory(category),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFoodList() {
    final items = _viewModel.filteredList;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Aucun aliment trouvé pour la semaine ${_viewModel.selectedWeek} et la catégorie ${_viewModel.selectedCategory}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _buildFoodCard(items[index]);
      },
    );
  }

  Widget _buildFoodCard(NutritionModel item) {
    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFEAF7F1),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: Color(0xFF1F7A67),
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F7F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      item.categoryLabel,
                      style: const TextStyle(
                        color: Color(0xFF1F7A67),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF102A16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.shortBenefit,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.nutrientList
                        .take(3)
                        .map((nutrient) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9F7F2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                nutrient,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1F7A67),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _openDetail(item),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE9F7F2),
                        foregroundColor: const Color(0xFF1F7A67),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Voir les détails'),
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

  String _categoryLabel(String category) {
    switch (category) {
      case 'protein':
        return '🍖 Protein';
      case 'vegetable':
        return '🥦 Vegetables';
      case 'fruit':
        return '🍎 Fruits';
      default:
        return category;
    }
  }
}
