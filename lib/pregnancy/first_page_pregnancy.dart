import 'package:flutter/material.dart';
import 'package:zyra/pregnancy/pregnancy_tracker_screen.dart';

class ZyraLandingPage extends StatelessWidget {
  const ZyraLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌸 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/baby_mom.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🌫️ Soft overlay
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.15),
            ),
          ),

          // 🌸 Decorations
          Positioned(
            top: 80,
            left: 20,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.local_florist,
                size: 50,
                color: Color(0xFFE453B9),
              ),
            ),
          ),

          Positioned(
            top: 150,
            right: 30,
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                Icons.favorite,
                size: 40,
                color: Color(0xFFB405B1),
              ),
            ),
          ),

          Positioned(
            bottom: 120,
            left: 40,
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                Icons.favorite_border,
                size: 35,
                color: Color(0xFFE9A8D6),
              ),
            ),
          ),

          Positioned(
            bottom: 200,
            right: 20,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.local_florist,
                size: 45,
                color: Color(0xFF9D69B4),
              ),
            ),
          ),

          // 📱 CONTENT
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),

                // 💖 Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 247, 157, 220),
                      Color.fromARGB(255, 198, 93, 180),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'PREGNANCY',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 38,
                      
                      letterSpacing: 4,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "A journey of love that begins in your heart and lasts a lifetime.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6A3D6E),
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // 💖 BUTTON
                Center(
                  child: Container(
                    width: 260,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 219, 112, 187),
                          Color.fromARGB(255, 195, 54, 192),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9D69B4).withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PregnancyTrackerApp(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}