import 'package:flutter/material.dart';

class MotherWeekPage extends StatelessWidget {
  const MotherWeekPage({super.key});

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
            color: Color(0xFFF06292),
          ),
        ),

        title: const Text(
          "Maman",

          style: TextStyle(
            color: Color(0xFFF06292),
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
            // TOP SLIDER
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
                mainAxisAlignment: MainAxisAlignment.center,

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

            // IMAGE
            Container(
              height: 520,
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),

                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/women.png',
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
              "Menstruation et fertilité",

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
              "Vous avez réellement vos dernières règles avant d'accoucher pendant la première semaine de grossesse. Étant donné que le premier jour de vos dernières règles sera utilisé pour calculer votre âge gestationnel estimé, techniquement le premier jour de votre grossesse sera le même que le premier jour où vous avez commencé à menstruer.",

              style: TextStyle(
                color: Color(0xFF3F3F46),
                fontSize: 18,
                height: 1.8,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}