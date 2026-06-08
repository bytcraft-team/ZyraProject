import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<AuthResult> updatePassword({
    required String ancienMdp,
    required String nouveauMdp,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null || user.email == null) {
        return AuthResult.error('Utilisateur non connecté.');
      }

      // 🔐 Re-authentication obligatoire
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: ancienMdp,
      );

      await user.reauthenticateWithCredential(credential);

      // 🔁 update password Firebase Auth
      await user.updatePassword(nouveauMdp);

      // 📩 EMAIL VERIFICATION AFTER CHANGE
      await user.sendEmailVerification();

      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getMessage(e.code));
    } catch (e) {
      return AuthResult.error('Erreur inattendue : $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _getMessage(String code) {
    switch (code) {
      case 'wrong-password':
        return 'Ancien mot de passe incorrect.';
      case 'weak-password':
        return 'Mot de passe trop faible.';
      case 'requires-recent-login':
        return 'Reconnecte-toi.';
      default:
        return 'Erreur : $code';
    }
  }
}

class AuthResult {
  final bool success;
  final String? errorMessage;

  AuthResult._(this.success, this.errorMessage);

  factory AuthResult.success() => AuthResult._(true, null);
  factory AuthResult.error(String msg) => AuthResult._(false, msg);
}