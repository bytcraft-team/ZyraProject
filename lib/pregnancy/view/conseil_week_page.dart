import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/pregnancy/viewmodels/pregnancy_view_model.dart';

class TipsWeekPage extends StatelessWidget {
  const TipsWeekPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8FB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFEC4899),
          ),
        ),
        title: const Text(
          "Conseils",
          style: TextStyle(
            color: Color(0xFFEC4899),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WEEK CONTAINER
            Consumer<PregnancyViewModel>(
              builder: (context, viewModel, child) {
                final currentWeek =
                    viewModel.pregnancyTracking?.currentWeek ?? 19;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEDED),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Semaine $currentWeek',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // IMAGE
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F7),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: AspectRatio(
                  aspectRatio: 0.78,
                  child: Image.asset(
                    'assets/images/baby_mom2.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // TITLE
            const Text(
              "Conseils pour la maman",
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 18),

            // DESCRIPTION
            Consumer<PregnancyViewModel>(
              builder: (context, viewModel, child) {
                return Text(
                  viewModel.currentWeekInfo?.motherTips ??
                      "Pendant cette période de grossesse, essayez de bien vous reposer et de boire suffisamment d’eau. Une alimentation équilibrée et des exercices légers peuvent aider votre corps à rester en bonne santé. N’oubliez pas de prendre du temps pour vous détendre et réduire le stress.",
                  style: const TextStyle(
                    color: Color(0xFF3F3F46),
                    fontSize: 18,
                    height: 1.8,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // TIPS CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFE4F1),
                    Color(0xFFFCE7F3),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEC4899),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Petit conseil 💡",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Dormez sur le côté gauche pour améliorer la circulation sanguine vers le bébé et réduire les douleurs du dos.",
                          style: TextStyle(
                            color: Color(0xFF5B5563),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
