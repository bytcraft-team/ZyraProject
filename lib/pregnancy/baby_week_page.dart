import 'package:flutter/material.dart';

class BabyWeekPage extends StatelessWidget {
  const BabyWeekPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F8),
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF8B5CF6),
          ),
        ),

        title: const Text(
          "Bébé",

          style: TextStyle(
            color: Color(0xFF8B5CF6),
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
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFEFEDED),
                borderRadius: BorderRadius.circular(22),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: const [
                  Text(
                    'Semaine 19',

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // BABY IMAGE
            Container(
              height: 520,
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),

                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/baby.png',
                  ),
                  fit: BoxFit.cover,
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // TITLE
            const Text(
              "Développement du bébé",

              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 18),

            // DESCRIPTION
            const Text(
              "À la semaine 19, votre bébé grandit rapidement. Ses bras et ses jambes sont maintenant bien proportionnés. Il commence également à développer ses sens, notamment l’ouïe. Votre bébé peut entendre votre voix et les sons autour de lui.",

              style: TextStyle(
                color: Color(0xFF3F3F46),
                fontSize: 18,
                height: 1.8,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 26),

            // INFO CARD
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEDE9FE),
                    Color(0xFFF5F3FF),
                  ],
                ),

                borderRadius: BorderRadius.circular(24),
              ),

              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,

                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5CF6),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: const [
                        Text(
                          "Taille du bébé",

                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          "Votre bébé a maintenant la taille d’une mangue 🥭",

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