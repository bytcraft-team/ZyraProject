import 'package:flutter/material.dart';

// ── Palette (cohérente avec HealthyNutritionPage) ─────────────────────────────
const Color kDeepViolet = Color(0xFF7C3AED);
const Color kRose = Color(0xFFE879A0);
const Color kPageBg = Color(0xFFFDF7FF);
const Color kCardBorder = Color(0xFFF0E6FA);
const Color kTextPrimary = Color(0xFF1C1C2E);
const Color kTextMuted = Color(0xFF6B6880);
const Color kTextHint = Color(0xFF9590A8);

class FoodAvoidListScreen extends StatelessWidget {
  const FoodAvoidListScreen({super.key});

  final List<Map<String, String>> foodData = const [
    {
      "name": "Viande crue ou insuffisamment cuite",
      "description": "Risque de toxoplasmose et d'infections bactériennes.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780676180/cover-r4x3w1200-5a58eaeba4206-043-belpress-00118164-007_bnuoib.jpg",
    },
    {
      "name": "Viande hachée insuffisamment cuite",
      "description":
          "Peut contenir des bactéries dangereuses pour la grossesse.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Sushi et sashimi",
      "description":
          "Contiennent du poisson cru pouvant transmettre des parasites ou bactéries.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Huîtres crues",
      "description": "Risque élevé d'infections alimentaires.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Moules crues",
      "description": "Peuvent contenir des microorganismes nocifs.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Foie cru",
      "description":
          "Très riche en vitamine A, potentiellement dangereuse en excès.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Œufs crus ou peu cuits",
      "description": "Risque de contamination par la salmonelle.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Mayonnaise maison à base d'œufs crus",
      "description": "Peut contenir des bactéries dangereuses.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Tiramisu traditionnel",
      "description": "Souvent préparé avec des œufs crus.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Lait cru",
      "description": "Risque de listériose et autres infections.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Brie non pasteurisé",
      "description": "Peut contenir la bactérie Listeria.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Camembert non pasteurisé",
      "description": "Risque de listériose.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Roquefort non pasteurisé",
      "description":
          "À éviter s'il est fabriqué à partir de lait non pasteurisé.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Gorgonzola",
      "description": "Peut présenter un risque microbiologique.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Requin",
      "description": "Contient une forte concentration de mercure.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Espadon",
      "description":
          "Taux élevé de mercure pouvant affecter le développement du fœtus.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Maquereau royal",
      "description": "À éviter en raison de sa teneur élevée en mercure.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Grande thonine",
      "description": "Consommation déconseillée à cause du mercure.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Hot-dog non réchauffé",
      "description": "Risque de contamination par Listeria.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Charcuterie froide",
      "description": "À éviter sauf si bien chauffée.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Salami",
      "description": "Peut contenir des bactéries ou parasites.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Pastrami froid",
      "description": "Risque de listériose.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Alcool",
      "description": "À éviter totalement pendant toute la grossesse.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Boissons énergétiques",
      "description": "Contiennent beaucoup de caféine et de stimulants.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Excès de caféine",
      "description": "Limiter à moins de 200 mg de caféine par jour.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Fruits non lavés",
      "description": "Risque de toxoplasmose et d'autres infections.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
    {
      "name": "Légumes non lavés",
      "description": "Peuvent contenir des parasites ou bactéries.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount =
        screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 2);

    return Scaffold(
      backgroundColor: kPageBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient SliverAppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            stretch: true,
            backgroundColor: kDeepViolet,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              title: const Text(
                'Aliments à Éviter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient rose → violet
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFC084FC),
                          Color(0xFFE879A0),
                          Color(0xFFFB7185),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Motif décoratif (cercles flous)
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
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
                  // Sous-titre
                  Positioned(
                    left: 20,
                    bottom: 52,
                    child: Text(
                      'Guide de sécurité alimentaire · ${foodData.length} aliments',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  // Arrondi bas
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 24,
                      decoration: const BoxDecoration(
                        color: kPageBg,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Compteur + intro pill ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4EF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFFBCFE8), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFE11D6A), size: 14),
                        SizedBox(width: 6),
                        Text(
                          'À éviter pendant la grossesse',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE11D6A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Grille de cartes ───────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: crossAxisCount == 1 ? 1.4 : 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final food = foodData[index];
                  return FoodCard(
                    name: food['name'] ?? '',
                    description: food['description'] ?? '',
                    imageUrl: food['imageUrl'] ?? '',
                  );
                },
                childCount: foodData.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FoodCard ──────────────────────────────────────────────────────────────────

class FoodCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;

  const FoodCard({
    super.key,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kCardBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB06AE3).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image ──────────────────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFFF3E8FF),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kDeepViolet,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF5F0FF), Color(0xFFFFF0F7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_outlined,
                        size: 36,
                        color: Color(0xFFD4AEFB),
                      ),
                    );
                  },
                ),
                // Dégradé bas sur l'image pour améliorer la lisibilité
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.18),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Badge "À ÉVITER"
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE879A0), Color(0xFF7C3AED)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.white, size: 11),
                        SizedBox(width: 4),
                        Text(
                          'À ÉVITER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Texte ──────────────────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: kTextHint,
                        height: 1.4,
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
}
