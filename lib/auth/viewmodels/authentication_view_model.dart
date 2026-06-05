import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../pregnancy/repositories/signup_request.dart';
import '../../pregnancy/repositories/user_repository.dart';

enum AuthStatus { initializing, authenticated, unauthenticated, error }

class AuthenticationViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  AuthenticationViewModel({required UserRepository userRepository})
      : _userRepository = userRepository {
    _listenAuthState();
  }

  AuthStatus _status = AuthStatus.initializing;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _user != null;

  void _listenAuthState() {
    _userRepository.authStateChanges().listen(
      (user) {
        _user = user;
        _status = user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _user = null;
        _status = AuthStatus.error;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.trim().isEmpty || password.trim().isEmpty) {
      _isLoading = false;
      _errorMessage = 'Veuillez remplir tous les champs';
      notifyListeners();
      return false;
    }

    try {
      await _userRepository.signIn(
          email: email.trim(), password: password.trim());
      _user = _userRepository.currentUser;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _status = AuthStatus.unauthenticated;
      _errorMessage = _interpretFirebaseError(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Erreur de connexion. Veuillez réessayer.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(SignupRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (request.username.trim().isEmpty ||
        request.email.trim().isEmpty ||
        request.password.trim().isEmpty) {
      _isLoading = false;
      _errorMessage = 'Veuillez remplir tous les champs';
      notifyListeners();
      return false;
    }

    if (request.password.length < 6) {
      _isLoading = false;
      _errorMessage = 'Le mot de passe doit contenir au moins 6 caractères';
      notifyListeners();
      return false;
    }

    try {
      await _userRepository.signUp(request);
      _user = _userRepository.currentUser;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _status = AuthStatus.unauthenticated;
      _errorMessage = _interpretFirebaseError(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Erreur lors de l\'inscription. Veuillez réessayer.';
      notifyListeners();
      return false;
    }
  }

  /// Interprète les codes d'erreur Firebase et retourne un message lisible
  String _interpretFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte n\'existe avec cet email';
      case 'wrong-password':
        return 'Le mot de passe est incorrect';
      case 'invalid-email':
        return 'L\'adresse email est invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email';
      case 'operation-not-allowed':
        return 'L\'inscription est désactivée';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'too-many-requests':
        return 'Trop de tentatives de connexion. Réessayez plus tard';
      case 'invalid-credential':
        return 'Les identifiants sont invalides';
      default:
        return 'Erreur d\'authentification. Veuillez réessayer.';
    }
  }

  Future<void> signOut() async {
    await _userRepository.signOut();
  }
}
