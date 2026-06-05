import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/auth/viewmodels/authentication_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 280),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('✦ ', style: TextStyle(color: Color(0xFF7B5EA7))),
                        Text(
                          'Bienvenue sur ',
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xFF3D2366),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'ZYRA',
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xFF3D2366),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(' ✦', style: TextStyle(color: Color(0xFF7B5EA7))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Connectez-vous pour continuer',
                      style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 30),

                    // Email
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Adresse email',
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                          prefixIcon: const Icon(
                            Icons.mail_outline,
                            color: Color(0xFF7B5EA7),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFB39DDB),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFF7B5EA7),
                              width: 2,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Color(0xFF3D2366)),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Password
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Mot de passe',
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF7B5EA7),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF7B5EA7),
                            ),
                            onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFB39DDB),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFF7B5EA7),
                              width: 2,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Color(0xFF3D2366)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Mot de passe oublié
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            if (_emailController.text.trim().isEmpty) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Entrez votre email d\'abord'),
                                ),
                              );
                              return;
                            }

                            if (!mounted) return;
                            final messenger = ScaffoldMessenger.of(context);

                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(
                                email: _emailController.text.trim(),
                              );
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Email de réinitialisation envoyé ✅',
                                  ),
                                ),
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Erreur : ${e.toString()}'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(
                              color: Color(0xFFD4799A),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Se connecter button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B5EA7), Color(0xFFD4799A)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final email = _emailController.text;
                            final password = _passwordController.text;
                            if (!mounted) return;
                            final authVm =
                                context.read<AuthenticationViewModel>();
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            final success =
                                await authVm.signIn(email, password);
                            if (success) {
                              navigator.pushReplacementNamed('/');
                              return;
                            }

                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  authVm.errorMessage ??
                                      'Email ou mot de passe incorrect ❌',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // S'inscrire
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Pas encore de compte ? ",
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text(
                            "S'inscrire",
                            style: TextStyle(
                              color: Color(0xFFD4799A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
