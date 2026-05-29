import 'package:flutter/material.dart';
import 'package:zyra/pregnancy/shared_navigation.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Cairo'),
      home: const HealthyNutritionPage(),
    );
  }
}

// ─── Wave Clipper ────────────────────────────────────────────────────────────
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

// ─── Main Page ───────────────────────────────────────────────────────────────
class HealthyNutritionPage extends StatefulWidget {
  const HealthyNutritionPage({super.key});
  @override
  State<HealthyNutritionPage> createState() => _HealthyNutritionPageState();
}

class _HealthyNutritionPageState extends State<HealthyNutritionPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      navigateToPage(context, index);
    }
  }

  int _waterCups = 5;
  static const int _totalCups = 8;
  int _currentWeek = 24;

  static const _gradient = LinearGradient(
    colors: [Color(0xFF7871DC), Color(0xFFC47EDE), Color(0xFFE3437A)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  late AnimationController _animationController;
  late List<AnimationController> _cardAnimationControllers;

  final _goodFoods = const [
    {
      'emoji': '🥑',
      'name': 'Avocat',
      'desc': 'Bonnes graisses et acide folique',
      'bg': Color(0xFFE8F5E9),
    },
    {
      'emoji': '🥛',
      'name': 'Lait',
      'desc': 'Calcium pour les os de bébé',
      'bg': Color(0xFFE3F2FD),
    },
    {
      'emoji': '🍎',
      'name': 'Pomme',
      'desc': 'Vitamines et bonne digestion',
      'bg': Color(0xFFFCE4EC),
    },
  ];

  final _badFoods = const [
    {'emoji': '🧀', 'label': 'Fromages mous'},
    {'emoji': '🍔', 'label': 'Fast-food'},
    {'emoji': '☕', 'label': 'Caféine'},
    {'emoji': '🍣', 'label': 'Poisson cru'},
  ];

  // ── Nutrient Data by Week ─────────────────────────────────────────────────
  Map<String, dynamic> _getWeeklyNutrients(int week) {
    if (week <= 12) {
      return {
        'primary': {
          'name': 'Acide folique',
          'emoji': '🌿',
          'description': 'Essentiel pour le développement du cerveau et de la moelle épinière de bébé',
          'priority': 'Très élevée',
        },
        'nutrients': [
          {
            'name': 'Acide folique',
            'emoji': '🌿',
            'description': 'Développement du cerveau',
            'priority': 'Très élevée',
            'bg': Color(0xFFE8F5E9),
          },
          {
            'name': 'Calcium',
            'emoji': '🥛',
            'description': 'Os solides',
            'priority': 'Élevée',
            'bg': Color(0xFFE3F2FD),
          },
          {
            'name': 'Fer',
            'emoji': '❤️',
            'description': 'Santé du sang',
            'priority': 'Importante',
            'bg': Color(0xFFFCE4EC),
          },
        ],
        'foods': ['Épinards', 'Lait', 'Œufs', 'Haricots', 'Viande rouge'],
      };
    } else if (week <= 20) {
      return {
        'primary': {
          'name': 'Fer',
          'emoji': '❤️',
          'description': 'Indispensable pour la formation du sang et le bon développement du fœtus',
          'priority': 'Très élevée',
        },
        'nutrients': [
          {
            'name': 'Fer',
            'emoji': '❤️',
            'description': 'Formation du sang',
            'priority': 'Très élevée',
            'bg': Color(0xFFFCE4EC),
          },
          {
            'name': 'Protéines',
            'emoji': '🍗',
            'description': 'Croissance du fœtus',
            'priority': 'Élevée',
            'bg': Color(0xFFFFF3E0),
          },
          {
            'name': 'Calcium',
            'emoji': '🥛',
            'description': 'Os et dents',
            'priority': 'Élevée',
            'bg': Color(0xFFE3F2FD),
          },
        ],
        'foods': ['Viande rouge', 'Épinards', 'Lait', 'Poulet', 'Lentilles'],
      };
    } else if (week <= 30) {
      return {
        'primary': {
          'name': 'Calcium',
          'emoji': '🥛',
          'description': 'Favorise le bon développement des os et des dents du fœtus',
          'priority': 'Très élevée',
        },
        'nutrients': [
          {
            'name': 'Calcium',
            'emoji': '🥛',
            'description': 'Os solides',
            'priority': 'Très élevée',
            'bg': Color(0xFFE3F2FD),
          },
          {
            'name': 'Oméga-3',
            'emoji': '🐟',
            'description': 'Développement du cerveau',
            'priority': 'Très élevée',
            'bg': Color(0xFFE0F2F1),
          },
          {
            'name': 'Fer',
            'emoji': '❤️',
            'description': 'Prévention de l\'anémie',
            'priority': 'Élevée',
            'bg': Color(0xFFFCE4EC),
          },
        ],
        'foods': ['Lait', 'Fromage', 'Saumon', 'Noix', 'Riz complet'],
      };
    } else {
      return {
        'primary': {
          'name': 'Magnésium',
          'emoji': '🌾',
          'description': 'Aide à la détente et au repos avant l\'accouchement',
          'priority': 'Très élevée',
        },
        'nutrients': [
          {
            'name': 'Magnésium',
            'emoji': '🌾',
            'description': 'Relaxation',
            'priority': 'Très élevée',
            'bg': Color(0xFFFFF9C4),
          },
          {
            'name': 'Fer',
            'emoji': '❤️',
            'description': 'Préparation à l\'accouchement',
            'priority': 'Très élevée',
            'bg': Color(0xFFFCE4EC),
          },
          {
            'name': 'Protéines',
            'emoji': '🍗',
            'description': 'Force et énergie',
            'priority': 'Élevée',
            'bg': Color(0xFFFFF3E0),
          },
        ],
        'foods': ['Banane', 'Noix de cajou', 'Viandes', 'Poisson', 'Graines'],
      };
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );
    _animationController.forward();
    for (var controller in _cardAnimationControllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _cardAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  _buildWeekBadge(),
                  const SizedBox(height: 16),
                  _buildProgressCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Catégories'),
                  const SizedBox(height: 28),
                  _buildWeeklyNutrientsSection(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('Aliments bénéfiques'),
                  const SizedBox(height: 12),
                  _buildGoodFoods(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('Aliments à éviter'),
                  const SizedBox(height: 12),
                  _buildBadFoods(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('Hydratation'),
                  const SizedBox(height: 12),
                  _buildWaterTracker(),
                  const SizedBox(height: 22),
                  _buildTipCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 48),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Nutrition & Santé',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  child: _headerIcon(Icons.settings_outlined),
                ),
                Positioned(
                  right: 12,
                  child: _headerIcon(Icons.notifications_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      );

  // ── Week Badge ────────────────────────────────────────────────────────────
  Widget _buildWeekBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFCE4EC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE91E8C).withOpacity(0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.calendar_today, color: Color(0xFFD81B60), size: 15),
              SizedBox(width: 6),
              Text(
                'Semaine 24 de grossesse',
                style: TextStyle(
                  color: Color(0xFFD81B60),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Progress Card ─────────────────────────────────────────────────────────
  Widget _buildProgressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: CustomPaint(painter: _RingPainter(0.60)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Avancement de la grossesse',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '2ème trimestre · Semaine 24 / 40',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 6,
                      decoration: const BoxDecoration(gradient: _gradient),
                      width: double.infinity,
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

  // ── Section Title ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ),
      );

  // ── Good Foods ────────────────────────────────────────────────────────────
  Widget _buildGoodFoods() => SizedBox(
        height: 185,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _goodFoods.length,
          itemBuilder: (_, i) {
            final f = _goodFoods[i];
            return Container(
              width: 138,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 88,
                        decoration: BoxDecoration(
                          color: f['bg'] as Color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            f['emoji'] as String,
                            style: const TextStyle(fontSize: 44),
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f['name'] as String,
                          style: const TextStyle(
                            color: Color(0xFFC2185B),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          f['desc'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF999999),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

  // ── Bad Foods ─────────────────────────────────────────────────────────────
  Widget _buildBadFoods() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _badFoods
                .map(
                  (food) => Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3F3),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Center(
                              child: Text(
                                food['emoji'] as String,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF44336),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        food['label'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      );

  // ── Water Tracker ─────────────────────────────────────────────────────────
  Widget _buildWaterTracker() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop,
                            color: Color(0xFF5B9BD5), size: 24),
                        const SizedBox(width: 6),
                        Text(
                          '$_waterCups / $_totalCups verres',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B9BD5), Color(0xFF7EC8E3)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_waterCups < _totalCups) {
                          setState(() => _waterCups++);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                      ),
                      child: const Text(
                        '+ Ajouter un verre',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalCups,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Icons.water_drop,
                      color: i < _waterCups
                          ? const Color(0xFF5B9BD5)
                          : const Color(0xFFE0E0E0),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _waterCups / _totalCups,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEEF6FF),
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF5B9BD5)),
                ),
              ),
            ],
          ),
        ),
      );

  // ── Weekly Nutrients Section ──────────────────────────────────────────────
  Widget _buildWeeklyNutrientsSection() {
    final weeklyData = _getWeeklyNutrients(_currentWeek);
    final nutrients = weeklyData['nutrients'] as List<Map<String, dynamic>>;
    final foods = weeklyData['foods'] as List<String>;
    final primary = weeklyData['primary'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Besoins de cette semaine ✨',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 12),
              _buildPrimaryNutrientCard(primary),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: nutrients.length,
            itemBuilder: (context, index) {
              final nutrient = nutrients[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _cardAnimationControllers[index],
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.3, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _cardAnimationControllers[index],
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: _buildNutrientCard(
                      nutrient['emoji'] as String,
                      nutrient['name'] as String,
                      nutrient['description'] as String,
                      nutrient['priority'] as String,
                      nutrient['bg'] as Color,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Suggestions alimentaires',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: foods.map((food) => _buildFoodChip(food)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Primary Nutrient Card ─────────────────────────────────────────────────
  Widget _buildPrimaryNutrientCard(Map<String, dynamic> nutrient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFCE4EC).withOpacity(0.6),
            const Color(0xFFF8BBD0).withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFFE91E8C).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E8C).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeOut),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nutrient['emoji'] as String,
                  style: const TextStyle(fontSize: 32),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE91E8C).withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    'Priorité : ${nutrient['priority']}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD81B60),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              nutrient['name'] as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nutrient['description'] as String,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Nutrient Card ─────────────────────────────────────────────────────────
  Widget _buildNutrientCard(
    String emoji,
    String name,
    String description,
    String priority,
    Color bgColor,
  ) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bgColor.withOpacity(0.8),
                  bgColor.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF999999),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFB74D).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      priority,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF57C00),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Food Chip ─────────────────────────────────────────────────────────────
  Widget _buildFoodChip(String food) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE8F5E9).withOpacity(0.7),
            const Color(0xFFC8E6C9).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, size: 12, color: Color(0xFF66BB6A)),
          const SizedBox(width: 6),
          Text(
            food,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tip Card ──────────────────────────────────────────────────────────────
  Widget _buildTipCard() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7871DC).withOpacity(0.08),
                const Color(0xFFE3437A).withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFFC47EDE).withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7871DC), Color(0xFFE3437A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conseil du jour',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Prenez des petits repas sains tout au long de la journée et buvez suffisamment d\'eau pour préserver votre santé et celle de votre bébé.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                        height: 1.6,
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

// ─── Ring Progress Painter ────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeW = 7.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFF3E5F5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = const SweepGradient(
      startAngle: -1.5708,
      endAngle: 4.7124,
      colors: [Color(0xFF7871DC), Color(0xFFE3437A)],
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -1.5708, 6.2832 * progress, false, paint);

    final tp = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).round()}%',
        style: const TextStyle(
          color: Color(0xFF7871DC),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}