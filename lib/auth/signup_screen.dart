import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/auth/viewmodels/authentication_view_model.dart';
import 'package:zyra/pregnancy/repositories/signup_request.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/inscrip.jpeg',
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
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('✦ ', style: TextStyle(color: Color(0xFF7B5EA7))),
                        Text(
                          'Créer un compte ',
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
                      'Rejoignez-nous dès aujourd\'hui',
                      style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 35),

                    // Nom
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Nom complet',
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF7B5EA7),
                          ),
                          errorText: _nameError,
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
                          errorText: _emailError,
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
                          errorText: _passwordError,
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
                    const SizedBox(height: 15),

                    // Confirm Password
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_confirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Confirmer le mot de passe',
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF7B5EA7),
                          ),
                          errorText: _confirmPasswordError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF7B5EA7),
                            ),
                            onPressed: () => setState(
                              () => _confirmPasswordVisible =
                                  !_confirmPasswordVisible,
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
                    const SizedBox(height: 30),

                    // S'inscrire button
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
                            setState(() {
                              _nameError = _nameController.text.trim().isEmpty
                                  ? 'Le nom est obligatoire'
                                  : null;
                              _emailError = _emailController.text.trim().isEmpty
                                  ? 'L\'email est obligatoire'
                                  : !_emailController.text.contains('@')
                                      ? 'Email invalide'
                                      : null;
                              _passwordError =
                                  _passwordController.text.length < 6
                                      ? 'Minimum 6 caractères'
                                      : null;
                              _confirmPasswordError =
                                  _confirmPasswordController.text !=
                                          _passwordController.text
                                      ? 'Les mots de passe ne correspondent pas'
                                      : null;
                            });

                            if (_nameError != null ||
                                _emailError != null ||
                                _passwordError != null ||
                                _confirmPasswordError != null) {
                              return;
                            }

                            final request = SignupRequest(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              username: _nameController.text.trim(),
                            );
                            if (!mounted) return;
                            final authVm =
                                context.read<AuthenticationViewModel>();
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            final success = await authVm.signUp(request);
                            if (success) {
                              navigator.pushReplacementNamed('/');
                              return;
                            }

                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  authVm.errorMessage ??
                                      'Erreur lors de l\'inscription',
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
                                'S\'inscrire',
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

                    // Déjà un compte
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Déjà un compte ? ",
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(
                              color: Color(0xFFD4799A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
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
