import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DBHelper _db = DBHelper();

  bool _isLoading = false;
  String? _errorMessage;
  bool _passwordUpdated = false;
  String? _avatarPath;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get passwordUpdated => _passwordUpdated;
  String? get avatarPath => _avatarPath;

  User? get user => _authService.currentUser;

  // ───── PASSWORD UPDATE ─────
  Future<bool> updatePassword({
    required String ancienMdp,
    required String nouveauMdp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _passwordUpdated = false;
    notifyListeners();

    final result = await _authService.updatePassword(
      ancienMdp: ancienMdp,
      nouveauMdp: nouveauMdp,
    );

    _isLoading = false;

    if (result.success) {
      _passwordUpdated = true;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  // ───── AVATAR (FIXED METHODS) ─────
  Future<void> setAvatar(String path) async {
    final uid = user?.uid;
    if (uid == null) return;

    _avatarPath = path;
    notifyListeners();

    await _db.updateAvatar(uid, path);
  }

  Future<void> deleteAvatar() async {
    final uid = user?.uid;
    if (uid == null) return;

    _avatarPath = null;
    notifyListeners();

    await _db.updateAvatar(uid, '');
  }

  void clearError() {
    _errorMessage = null;
    _passwordUpdated = false;
    notifyListeners();
  }

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> loadUserData() async {
    final uid = user?.uid;
    if (uid != null) {
       _avatarPath = await _db.getAvatar(uid);
       notifyListeners();
    }
  }
}