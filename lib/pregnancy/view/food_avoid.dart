import 'package:flutter/material.dart';

class FoodAvoidListScreen extends StatelessWidget {
  const FoodAvoidListScreen({super.key});

  // Vos données JSON typées en List<Map<String, String>>
  final List<Map<String, String>> foodData = const [
    {
      "name": "Viande crue ou insuffisamment cuite",
      "description": "Risque de toxoplasmose et d'infections bactériennes.",
      "imageUrl":
          "https://res.cloudinary.com/bf8hpkjr/image/upload/v1780176958/food_evite_tipps4.jpg",
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
      "description": "Risque de toxoplasmose et d'aures infections.",
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
    // Détecte la largeur de l'écran pour adapter le nombre de colonnes de la grille
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 900
        ? 3
        : (screenWidth > 600 ? 2 : 1);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Un AppBar moderne et dynamique qui se rétracte au défilement
          SliverAppBar.large(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.errorContainer.withOpacity(0.4),
            title: const Text(
              'Aliments à Éviter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            //subtitle: const Text(
              //'Guide de sécurité alimentaire pour la grossesse',
              //style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            //centerTitle: false,
          //),

          // Grille responsive de cartes d'aliments
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                // Ajuste la hauteur de la carte selon le format de l'écran
                childAspectRatio: crossAxisCount == 1 ? 1.2 : 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final food = foodData[index];
                return FoodCard(
                  name: food['name'] ?? '',
                  description: food['description'] ?? '',
                  imageUrl: food['imageUrl'] ?? '',
                );
              }, childCount: foodData.length),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de carte réutilisable pour chaque aliment
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
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Image avec indicateur de chargement et gestion des erreurs
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback élégant si l'image Cloudinary ne charge pas
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
                // Badge "Attention / Interdit" discret sur l'image
                PositionfulBadge(),
              ],
            ),
          ),
          // Section Textes (Nom + Description)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
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

// Petit badge décoratif "À éviter"
class PositionfulBadge extends StatelessWidget {
  const PositionfulBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10,),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              'À ÉVITER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
