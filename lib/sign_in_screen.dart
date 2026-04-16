// lib/screens/sign_in_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



// ─────────────────────────────────────────────────────────────────────────────
// SIGN-IN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late Animation<double>    _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset>    _slideAnimation;

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color kRoseQuartz  = Color(0xFFE8A0A8);
  static const Color kBlushBorder = Color(0xFFD4788A);
  static const Color kPetalWhite  = Color(0xFFFFF0F3);
  static const Color kDeepBerry   = Color(0xFF1A0A0E);
  static const Color kMutedPink   = Color(0xFFF5C6CE);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate network
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Background Image ─────────────────────────────────────────
          Image.asset(
            'assets/images/pink_moon.jpeg', // your uploaded image
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
          ),

          // ── 2. Gradient Overlay (readability) ───────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kDeepBerry.withOpacity(0.30),
                  kDeepBerry.withOpacity(0.62),
                  kDeepBerry.withOpacity(0.80),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // ── 3. Content ──────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 56),

                          // ── Logo / Moon Icon ─────────────────────────
                          _MoonCrescent(color: kRoseQuartz),
                          const SizedBox(height: 16),

                          // ── App Name ─────────────────────────────────
                          Text(
                            'zyra',
                            style: TextStyle(
                              fontSize: 42,
                              fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              color: kPetalWhite,
                              letterSpacing: 6,
                              shadows: [
                                Shadow(
                                  color: kBlushBorder.withOpacity(0.6),
                                  blurRadius: 24,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'your cycle, your rhythm',
                            style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 2.5,
                              color: kMutedPink.withOpacity(0.85),
                              fontWeight: FontWeight.w300,
                            ),
                          ),

                          const Spacer(),

                          // ── Frosted Glass Card ───────────────────────
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: kBlushBorder.withOpacity(0.35),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Greeting
                                    Text(
                                      'Welcome back',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Georgia',
                                        fontStyle: FontStyle.italic,
                                        color: kPetalWhite,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sign in to continue',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: kMutedPink.withOpacity(0.7),
                                        letterSpacing: 1.2,
                                      ),
                                    ),

                                    const SizedBox(height: 28),

                                    // Email field
                                    _LunaTextField(
                                      controller: _emailController,
                                      hint: 'Email address',
                                      icon: Icons.mail_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      borderColor: kPetalWhite,
                                      iconColor: kRoseQuartz,
                                      textColor: kPetalWhite,
                                      hintColor: const Color.fromARGB(255, 243, 241, 242).withOpacity(0.55),
                                    ),

                                    const SizedBox(height: 16),

                                    // Password field
                                    _LunaTextField(
                                      controller: _passwordController,
                                      hint: 'Password',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePassword,
                                      borderColor: kPetalWhite,
                                      iconColor: kRoseQuartz,
                                      textColor: kPetalWhite,
                                      hintColor: const Color.fromARGB(255, 246, 244, 244).withOpacity(0.55),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: kRoseQuartz.withOpacity(0.7),
                                          size: 20,
                                        ),
                                        onPressed: () => setState(
                                            () => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // Forgot password
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: kRoseQuartz.withOpacity(0.85),
                                            letterSpacing: 0.3,
                                            decoration: TextDecoration.underline,
                                            decorationColor:
                                                kRoseQuartz.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 28),

                                    // Sign-in button
                                    _SignInButton(
                                      isLoading: _isLoading,
                                      onTap: _handleSignIn,
                                      primaryColor: kBlushBorder,
                                      accentColor: kRoseQuartz,
                                      textColor: kPetalWhite,
                                    ),

                                    const SizedBox(height: 20),

                                    // Sign-up prompt
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: kMutedPink.withOpacity(0.65),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            'Create one',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: kPetalWhite,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Bottom tagline
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              '🌸  Track · Understand · Thrive',
                              style: TextStyle(
                                fontSize: 11,
                                color: kMutedPink.withOpacity(0.45),
                                letterSpacing: 1.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE: Luna Text Field
// ─────────────────────────────────────────────────────────────────────────────

class _LunaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color hintColor;
  final Widget? suffixIcon;

  const _LunaTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.hintColor,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor, fontSize: 14.5, letterSpacing: 0.3),
      cursorColor: borderColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor.withOpacity(0.45), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.6),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE: Sign-In Button
// ─────────────────────────────────────────────────────────────────────────────

class _SignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;

  const _SignInButton({
    required this.isLoading,
    required this.onTap,
    required this.primaryColor,
    required this.accentColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [primaryColor, accentColor.withOpacity(0.85)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.40),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : Text(
                  'Sign In',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DECORATIVE: Moon Crescent Widget (pure Flutter, no assets)
// ─────────────────────────────────────────────────────────────────────────────

class _MoonCrescent extends StatelessWidget {
  final Color color;
  const _MoonCrescent({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(54, 54),
      painter: _CrescentPainter(color: color),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  final Color color;
  const _CrescentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width * 0.48, size.height * 0.5),
          radius: size.width * 0.4))
      ..addOval(Rect.fromCircle(
          center: Offset(size.width * 0.62, size.height * 0.5),
          radius: size.width * 0.34));

    canvas.drawPath(
      Path.combine(PathOperation.difference, path.shift(Offset.zero),
          path..shift(Offset.zero)),
      paint,
    );

    // Simpler approach: draw filled circle minus offset circle
    final fullMoon = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width * 0.46, size.height * 0.5),
          radius: size.width * 0.40));

    final shadow = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width * 0.64, size.height * 0.5),
          radius: size.width * 0.36));

    final crescent = Path.combine(PathOperation.difference, fullMoon, shadow);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(crescent, glowPaint);
    canvas.drawPath(crescent, paint);
  }

  @override
  bool shouldRepaint(_CrescentPainter old) => old.color != color;
}